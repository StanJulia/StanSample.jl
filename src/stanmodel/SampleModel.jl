import Base: show

mutable struct SampleModel <: CmdStanModels
    name::AbstractString;              # Name of the Stan program
    model::AbstractString;             # Stan language model program
    num_threads::Int64;                # Number of C++ threads

    check_num_chains::Bool;            # Enforce either C++ or Julia chains
    use_cpp_chains::Bool;              # Enable C++ threads and chains
    num_cpp_chains::Int64;             # Number of C++ chains in each exec process
    num_julia_chains::Int64;           # Number of julia chains ( == processes)
    num_chains::Int64;                 # Actual number of chains

    # Sample fields
    num_samples::Int;                  # Number of draws after warmup
    num_warmups::Int;                  # Number of warmup draws
    save_warmup::Bool;                 # Store warmup_samples
    thin::Int;                         # Thinning of draws
    seed::Int;                         # Seed section of cmd to run cmdstan
    refresh::Int                       # Display progress in output files
    init_bound::Int                    # Bound for initial param values

    # Adapt fields
    engaged::Bool;                     # Adaptation enganged?.
    gamma::Float64;                    # Adaptation regularization scale    
    delta::Float64;                    # Adaptation target acceptance statistic
    kappa::Float64;                    # Adaptation relaxation exponent
    t0::Int;                           # Adaptation iteration offset
    init_buffer::Int;                  # Width initial adaptation interval
    term_buffer::Int;                  # Width of final adaptation interval
    window::Int;                       # Initial width slow adaptation interval

    # Algorithm fields
    algorithm::Symbol;                 # :hmc or :fixed_param
    # HMC specific fields
    engine::Symbol;                    # :nuts or :static (default = :nuts)
    # NUTS specific field
    max_depth::Int;                    # Maximum tree depth (> 0, default=10)
    # Static specific field
    int_time::Float64;                 # Static integration time

    # HMC remaining fields
    metric::Symbol;                    # :diag_e, :unit_e, :dense_e
    metric_file::AbstractString;       # Precompiled Euclidean metric
    stepsize::Float64;                 # Stepsize for discrete evolution
    stepsize_jitter::Float64;          # Uniform random jitter of stepsize (%)

    # Output files
    output_base::AbstractString;       # Used for file paths to be created
    # Tmpdir setting
    tmpdir::AbstractString;            # Holds all created files
    # Cmdstan path
    exec_path::AbstractString;         # Path to the cmdstan excutable
    # BridgeStan path
    bridge_path::AbstractString;       # Path to the BridgeStan ..._model.so

    use_json::Bool;                    # Use JSON for data and init files

    # Data and init file paths
    data_file::Vector{AbstractString}; # Array of data files input to cmdstan
    init_file::Vector{AbstractString}; # Array of init files input to cmdstan
    # Generated command line vector
    cmds::Vector{Cmd};                 # Array of cmds to be spawned/pipelined
    # Files created by cmdstan
    sample_file::Vector{String};       # Sample file array (.csv)
    log_file::Vector{String};          # Log file array
    diagnostic_file::Vector{String};   # Diagnostic file array

    # Output control
    sig_figs::Int;                     # Number of significant digits for values in output files

    # Stansummary settings
    summary::Bool;                     # Store cmdstan's summary as a .csv file
    print_summary::Bool;               # Print the summary

    # CMDSTAN_HOME
    cmdstan_home::AbstractString;      # Directory where cmdstan can be found

    # Show logging in terminal
    show_logging::Bool;
end

"""

Create a SampleModel and compile Stan Language Model.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `name::AbstractString`               # Name for the model
* `model::AbstractString`              # Stan model source
```

### Optional positional argument
```julia
* `tmpdir`                             # Directory where output files are stored
                                       # Default: `mktempdir()`
```

Note: On Windows I have seen issues using `tmpdir`.

"""
function SampleModel(name::AbstractString, model::AbstractString,
    tmpdir=mktempdir())
  
    !isdir(tmpdir) && mkdir(tmpdir)

    update_model_file(joinpath(tmpdir, "$(name).stan"), strip(model))

    output_base = joinpath(tmpdir, name)
    exec_path = executable_path(output_base)

    cmdstan_home = CMDSTAN_HOME

    bridge_path = isdir(BRIDGESTAN_HOME) ? joinpath(BRIDGESTAN_HOME) : ""

    error_output = IOBuffer()
    is_ok = cd(cmdstan_home) do
        success(pipeline(`$(make_command()) -f $(cmdstan_home)/makefile -C $(cmdstan_home) $(exec_path)`;
            stderr = error_output))
    end

    if !is_ok
        throw(StanModelError(name, String(take!(error_output))))
    end

    if length(bridge_path) > 0
        is_ok = cd(bridge_path) do
            bridge_output = IOBuffer()
            target = tmpdir * "/$(name)_model.so"
            success(pipeline(`$(make_command())  -f $(bridge_path)/Makefile $(target)`;
                stderr = bridge_output))
        end
        if !is_ok
            @warn "BridgeStan compilation of model failed."
            throw(StanModelError(String(take!(bridge_output))))
        end
    end

    SampleModel(name, model, 
        # num_threads
        4,
        # check_num_chains, use_cpp_chains
        true, false, 
        # num_cpp_chains
        1,
        # num_julia_chains
        4,
        # num_chains
        4,
        # num_samples, num_warmups, save_warmups
        1000, 1000, false,
        # thin, seed, refresh, init_bound
        1, -1, 100, 2,
        # Adapt fields
        # engaged, gamma, delta, kappa, t0, init_buffer, term_buffer, window
        true, 0.05, 0.8, 0.75, 10, 75, 50, 25,
        # algorithm fields
        :hmc,                          # or :static
        # engine, max_depth
        :nuts, 10,
        # Static engine specific fields
        2pi,
        # metric, metric_file, stepsize, stepsize_jitter
        :diag_e, "", 1.0, 0.0,

        # Ouput settings
        output_base,                   # Output base
        tmpdir,                        # Tmpdir settings
        exec_path,                     # exec_path
        bridge_path,                   # BridgeStan path

        true,                          # Use JSON for cmdstan input files
        AbstractString[],              # Data files
        AbstractString[],              # Init files

        Cmd[],                         # Command lines
        String[],                      # Sample .csv files 
        String[],                      # Log files
        String[],                      # Diagnostic files
        6,                             # Default number of sig_figs
        true,                          # Create stansummary result
        false,                         # Display stansummary result
        cmdstan_home,
        false
    )
end

function Base.show(io::IO, ::MIME"text/plain", m::SampleModel)
    println("\nModel name:")
    println(io, "  name =                    $(m.name)")
    println("\nC++ threads per forked process:")
    println(io, "  num_threads =             $(m.num_threads)")
    println(io, "  use_cpp_chains =          $(m.use_cpp_chains)")
    println(io, "  check_num_chains =        $(m.check_num_chains)")
    println("\nC++ chains per forked process:")
    println(io, "  num_cpp_chains =          $(m.num_cpp_chains)")
    println("\nNo of forked Julia processes:")
    println(io, "  num_julia_chains =        $(m.num_julia_chains)")
    println("\nActual number of chains:")
    println(io, "  num_chains =              $(m.num_chains)")

    println(io, "\nSample section:")
    println(io, "  num_samples =             ", m.num_samples)
    println(io, "  num_warmups =             ", m.num_warmups)
    println(io, "  save_warmup =             ", m.save_warmup)
    println(io, "  thin =                    ", m.thin)
    println(io, "  seed =                    ", m.seed)
    println(io, "  refresh =                 ", m.refresh)
    println(io, "  init_bound =              ", m.init_bound)
    println(io, "\nAdapt section:")
    println(io, "  engaged =                 ", m.engaged)
    println(io, "  gamma =                   ", m.gamma)
    println(io, "  delta =                   ", m.delta)
    println(io, "  kappa =                   ", m.kappa)
    println(io, "  t0 =                      ", m.t0)
    println(io, "  init_buffer =             ", m.init_buffer)
    println(io, "  term_buffer =             ", m.term_buffer)
    println(io, "  window =                  ", m.window)
    if m.algorithm ==:hmc
        println("\nAlgorithm section:")
        println(io, "\n  algorithm =               $(m.algorithm)")
        if m.engine == :nuts
            println(io, "\n    NUTS section:")
            println(io, "      engine =              $(m.engine)")
            println(io, "      max_depth =           ", m.max_depth)
        elseif m.engine == :static
            println(io, "\n  STATIC section:")
            println(io, "    engine =               :static")
            println(io, "    int_time =             ", m.int_time)
        end
        println(io, "\n  Metric section:")
        println(io, "    metric =                ", m.metric)
        println(io, "    stepsize =              ", m.stepsize)
        println(io, "    stepsize_jitter =       ", m.stepsize_jitter)
    else
        if m.algorithm == :fixed_param
            println(io, "    algorithm =         :fixed_param")
        else
            println(io, "    algorithm =         Unknown")
        end
    end
    println(io, "\nData and init files:")
    println(io, "  use_json =                ", m.use_json)
    println(io, "\nOutput control:")
    println(io, "  sig_figs =                ", m.sig_figs)
    println(io, "\nStansummary section:")
    println(io, "  summary                   ", m.summary)
    println(io, "  print_summary             ", m.print_summary)
    println(io, "  show_logging              ", m.show_logging)
    println(io, "\nOther:")
    println(io, "  output_base =             ", m.output_base)
    println(io, "  tmpdir =                  ", m.tmpdir)
end
