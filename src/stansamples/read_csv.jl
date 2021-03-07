function read_csv(
    file_name::String,
    n_chains = 4,
    n_samples = 1000,
    output_format=:namedtuple;
    include_internals=false,
    kwargs...)
  
    local a3d, monitors, index, idx, indvec, ftype, noofsamples

    # First samples number returned
    start = (:start in keys(kwargs)) ? values(kwargs).start : 1

    # Read .csv files and return a3d[n_samples, parameters, n_chains]
    for i in 1:n_chains
        if isfile(file_name * "_$i.csv")
            fname = file_name * "_$i.csv"
            instream = open(fname)
            
            # Skip initial set of commented lines, e.g. containing cmdstan version info, etc.      
            skipchars(isspace, instream, linecomment='#')
            
            # First non-comment line contains names of variables
            line = Unicode.normalize(readline(instream), newline2lf=true)
            idx = split(strip(line), ",")
            index = [idx[k] for k in 1:length(idx)]      
            indvec = 1:length(index)
            n_parameters = length(indvec)
            
            # Allocate a3d as we now know number of parameters
            if i == 1
                a3d = fill(0.0, n_samples, n_parameters, n_chains)
            end
            
            skipchars(isspace, instream, linecomment='#')
            for j in 1:n_samples
                skipchars(isspace, instream, linecomment='#')
                line = Unicode.normalize(readline(instream), newline2lf=true)
                if eof(instream) && length(line) < 2
                    close(instream)
                    break
                else
                    flds = parse.(Float64, split(strip(line), ","))
                    flds = reshape(flds[indvec], 1, length(indvec))
                    a3d[j,:,i] = flds
                end
            end   # read in samples
        end   # read in next file if it exists
    end   # read in file for each chain
    
    cnames = convert.(String, idx[indvec])
    if include_internals
        snames = [Symbol(cnames[i]) for i in 1:length(cnames)]
        indices = 1:length(cnames)
    else
        pi = filter(p -> length(p) > 2 && p[end-1:end] == "__", cnames)
        snames = filter(p -> !(p in  pi), cnames)
        indices = Vector{Int}(indexin(snames, cnames))
    end 

    res = convert_a3d(a3d[:, indices, :], snames, Val(output_format))

    (res, snames) 
end
