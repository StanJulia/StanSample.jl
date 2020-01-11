using StanSample, Random

Random.seed!(1233)

ProjDir = @__DIR__
cd(ProjDir)

include(joinpath(@__DIR__, "LBA_functions.jl"))

LBA_stan = "
functions{

     real lba_pdf(real t, real b, real A, real v, real s){
          //PDF of the LBA model

          real b_A_tv_ts;
          real b_tv_ts;
          real term_1;
          real term_2;
          real term_3;
          real term_4;
          real pdf;

          b_A_tv_ts = (b - A - t*v)/(t*s);
          b_tv_ts = (b - t*v)/(t*s);
          term_1 = v*Phi(b_A_tv_ts);
          term_2 = s*exp(normal_lpdf(b_A_tv_ts|0,1));
          term_3 = v*Phi(b_tv_ts);
          term_4 = s*exp(normal_lpdf(b_tv_ts|0,1));
          pdf = (1/A)*(-term_1 + term_2 + term_3 - term_4);

          return pdf;
     }

     real lba_cdf(real t, real b, real A, real v, real s){
          //CDF of the LBA model

          real b_A_tv;
          real b_tv;
          real ts;
          real term_1;
          real term_2;
          real term_3;
          real term_4;
          real cdf;

          b_A_tv = b - A - t*v;
          b_tv = b - t*v;
          ts = t*s;
          term_1 = b_A_tv/A * Phi(b_A_tv/ts);
          term_2 = b_tv/A   * Phi(b_tv/ts);
          term_3 = ts/A     * exp(normal_lpdf(b_A_tv/ts|0,1));
          term_4 = ts/A     * exp(normal_lpdf(b_tv/ts|0,1));
          cdf = 1 + term_1 - term_2 + term_3 - term_4;

          return cdf;

     }

     real lba_lpdf(matrix RT, real k, real A, vector v, real s, real tau){

          real t;
          real b;
          real cdf;
          real pdf;
          vector[rows(RT)] prob;
          real out;
          real prob_neg;

          b = A + k;
          for (i in 1:rows(RT)){
               t = RT[i,1] - tau;
               if(t > 0){
                    cdf = 1;

                    for(j in 1:num_elements(v)){
                         if(RT[i,2] == j){
                              pdf = lba_pdf(t, b, A, v[j], s);
                         }else{
                              cdf = (1-lba_cdf(t, b, A, v[j], s)) * cdf;
                         }
                    }
                    prob_neg = 1;
                    for(j in 1:num_elements(v)){
                         prob_neg = Phi(-v[j]/s) * prob_neg;
                    }
                    prob[i] = pdf*cdf;
                    prob[i] = prob[i]/(1-prob_neg);
                    if(prob[i] < 1e-10){
                         prob[i] = 1e-10;
                    }

               }else{
                    prob[i] = 1e-10;
               }
          }
          out = sum(log(prob));
          return out;
     }
}

data{
     int N;
     int Nc;
     vector[N] rt;
     vector[N] choice;
}

parameters {
     real<lower=0> k;
     real<lower=0> A;
     real<lower=0> tau;
     vector<lower=0>[Nc] v;
}

model {
     real s;
     matrix[N,2] RT;
     s=1;
     RT[:,1] = rt;
     RT[:,2] = choice;
     k ~ normal(.5,1)T[0,];
     A ~ normal(.5,1)T[0,];
     tau ~ normal(.5,.5)T[0,];
     for(n in 1:Nc){
          v[n] ~ normal(2,1)T[0,];
     }
     RT ~ lba(k,A,v,s,tau);
}
";

# First 2 runs are using the standard 2.19.1 version of cmdstan

# This run tests passing a data file name as data in the stan_sample() call

stanmodel = SampleModel("LBA", LBA_stan; 
  method = StanSample.Sample(adapt = StanSample.Adapt(delta = 0.95)));

N = 200
v = [1.0, 1.5]
Nc = length(v)
data = simulateLBA(;Nd=N,v=v,A=.8,k=.2,tau=.4)  

@time rc = stan_sample(stanmodel; data=data, n_chains=4)

if success(rc)
  # Use StanSamples to read a chain in NamedTupla format
  nt = read_samples(stanmodel.sm; chain = 3)

  # Convert to an MCMCChains.Chains object
  chns = read_samples(stanmodel)
  
  # Describe the MCMCChains using MCMCChains statistics
  display(describe(chns))

  # Show the same output in DataFrame format
  #sdf = StanSample.read_summary(stanmodel)
  #display(sdf)
end
