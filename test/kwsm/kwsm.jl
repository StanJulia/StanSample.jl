mutable struct Adapt
    engaged::Int
    gamma::Float64
end

Adapt() = Adapt(1, 0.05)

mutable struct KWSM
    n_chains::Int         # Number of chains
    seed::Int               # Seed section of cmd to run cmdstan
    summary::Bool            # Store cmdstan's summary as a .csv file
    printsummary::Bool       # Print the summary
    adapt::Adapt
end

KWSM() = KWSM(1, 1, false, false, Adapt())

sm = KWSM()

sm.adapt.engaged = 0

sm |> display
