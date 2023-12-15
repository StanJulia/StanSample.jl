using StanSample, Test

stan = "
generated quantities {
  real base = normal_rng(0, 1);
  int base_i = to_int(normal_rng(10, 10));

  tuple(real, real) pair = (base, base * 2);

  tuple(real, tuple(int, complex)) nested = (base * 3, (base_i, base * 4.0i));
  array[2] tuple(real, real) arr_pair = {pair, (base * 5, base * 6)};

  array[3] tuple(tuple(real, tuple(int, complex)), real) arr_very_nested
    = {(nested, base*7), ((base*8, (base_i*2, base*9.0i)), base * 10), (nested, base*11)};

  array[3,2] tuple(real, real) arr_2d_pair = {{(base * 12, base * 13), (base * 14, base * 15)},
                                              {(base * 16, base * 17), (base * 18, base * 19)},
                                              {(base * 20, base * 21), (base * 22, base * 23)}};

  real basep1 = base + 1, basep2 = base + 2;
  real basep3 = base + 3, basep4 = base + 4, basep5 = base + 5;
  array[2,3] tuple(array[2] tuple(real, vector[2]), matrix[4,5]) ultimate =
    {
      {(
        {(base, [base *2, base *3]'), (base *4, [base*5, base*6]')},
        to_matrix(linspaced_vector(20, 7, 11), 4, 5) * base
        ),
       (
        {(basep1, [basep1 *2, basep1 *3]'), (basep1 *4, [basep1*5, basep1*6]')},
        to_matrix(linspaced_vector(20, 7, 11), 4, 5) * basep1
        ),
        (
          {(basep2, [basep2 *2, basep2 *3]'), (basep2 *4, [basep2*5, basep2*6]')},
          to_matrix(linspaced_vector(20, 7, 11), 4, 5) * basep2
       )
     },
     {(
        {(basep3, [basep3 *2, basep3 *3]'), (basep3 *4, [basep3*5, basep3*6]')},
        to_matrix(linspaced_vector(20, 7, 11), 4, 5) * basep3
        ),
       (
        {(basep4, [basep4 *2, basep4 *3]'), (basep4 *4, [basep4*5, basep4*6]')},
        to_matrix(linspaced_vector(20, 7, 11), 4, 5) * basep4
        ),
        (
          {(basep5, [basep5 *2, basep5 *3]'), (basep5 *4, [basep5*5, basep5*6]')},
          to_matrix(linspaced_vector(20, 7, 11), 4, 5) * basep5
       )
     }};

 }
";

sm = SampleModel("brian_data", stan)
rc = stan_sample(sm)

df = read_samples(sm, :dataframe)
ndf = read_samples(sm, :nesteddataframe)
nnt = convert(NamedTuple, ndf)

lr = 1:size(df, 1)

pair_df = StanSample.select_nested_column(df, :pair)
nested_df = StanSample.select_nested_column(df, :nested)
arr_pair_df = StanSample.select_nested_column(df, :arr_pair)
avn_df = StanSample.select_nested_column(df, :arr_very_nested)
a2d_df = StanSample.select_nested_column(df, :arr_2d_pair)
u_df = StanSample.select_nested_column(df, :ultimate)

@testset "Pair" begin
    for i in rand(lr, 10)
        @test ndf.pair[i] == (pair_df[i, 1], pair_df[i, 2])
    end
end

@testset "Nested" begin
    for i in rand(lr, 15)
        @test ndf.nested[i][1] == nested_df[i, 1]
        @test ndf.nested[i][2] == (nested_df[i, 2], nested_df[i, 3])
    end
end

@testset "Arr_pair" begin
    for i in rand(lr, 15)
        @test ndf.arr_pair[i] == [(arr_pair_df[i, 1], arr_pair_df[i, 2]),
          (arr_pair_df[i, 3], arr_pair_df[i, 4])]
    end
end

@testset "Arr_very_nested" begin
    for i in rand(lr, 15)
        @test ndf.arr_very_nested[i][3][1][1] == avn_df[i, 1]
        @test ndf.arr_very_nested[i][3][1][2] == (avn_df[i, 2], avn_df[i, 3])
        @test ndf.arr_very_nested[i][3][2] == avn_df[i, 12]
    end
end

@testset "Arr_2d_pair" begin
    for i in rand(lr, 15)
        @test ndf.arr_2d_pair[i][3, 2] == (a2d_df[i, 11], a2d_df[i, 12])
    end
end
@testset "Ultimate" begin
    for i in rand(lr, 15)
      @test ndf.ultimate[i][2, 3][1][4] == Array(u_df[i, 135:136])
        @test ndf.ultimate[i][2, 3][2] == reshape(Array(u_df[i, (end-19):end]), 4, 5)
    end
end
