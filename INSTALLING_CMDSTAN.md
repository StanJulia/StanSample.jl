# Installing cmdstan.

```
# Clone cmdstan (currently cmdstan-2.29.0)

git clone https://github.com/stan-dev/cmdstan.git --recursive cmdstan

# Switch to the cmdstan build directory (later on pointed to by CMDSTAN from Julia)

cd cmdstan

# Create a ./make/local file (see below, derived from ./make/local-example)

make -j9 build   # or make clean-all
                 # 9 is the number of threads used for compiling cmdstan

# Compile the Bernoulli example

make examples/bernoulli/bernoulli

# Run the example using cmdstan

./examples/bernoulli/bernoulli num_threads=6 sample num_chains=4 data
        file=examples/bernoulli/bernoulli.data.json

# Test the stanssummary binary

bin/stansummary output_1.csv
```

Below an example of the `make/local` file mentioned above.

```
# To use this template, make a copy from make/local.example to make/local
# and uncomment options as needed.

# Be sure to run `make clean-all` before compiling a model to make sure
# everything gets rebuilt.

# Change the C++ compiler if needed
CXX=clang++                    # Only needed on macOS.

# Enable threading
STAN_THREADS=true

# Enable the MPI backend (requires also setting (replace gcc with clang on Mac)
# STAN_MPI=true
# CXX=mpicxx
# TBB_CXX_TYPE=gcc
```