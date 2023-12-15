function find_nested_columns(df::DataFrame)
    n = string.(names(df))
    nested_columns = String[]
    for (i, s) in enumerate(n)
        r = split(s, ['.', ':'])
        if length(r) > 1
            append!(nested_columns, [r[1]])
        end
    end
    unique(nested_columns)
end

function select_nested_column(df::DataFrame, var::Union{Symbol, String})
    n = string.(names(df))
    sym = string(var)
    sel = String[]
    for (i, s) in enumerate(n)
		splits = findall(c -> c in ['.', ':'], s)
		if length(splits) > 0
			#println((splits, sym, s, length(s), s[1:splits[1]-1]))
	        if length(splits) > 0 && sym == s[1:splits[1]-1]
	            append!(sel, [n[i]])
	        end
		end
    end
    length(sel) == 0 && @warn "$sym not in $n"
    #println(sel)
    df[:, sel]
end

@enum VariableType SCALAR=1 TUPLE

"""

$TYPEDEF

$FIELDS

This class represents a single output variable of a Stan model.

It contains information about the name, dimensions, and type of the
variable, as well as the indices of where that variable is located in
the flattened output array Stan models write.

Generally, this class should not be instantiated directly, but rather
created by the `parse_header()` function.

Not exported.
"""
struct Variable
    name::AbstractString # Name as in Stan .csv file. For nested fields, just the initial part.
    # For arrays with nested parameters, this will be for the first element
    # and is relative to the start of the parent
    start_idx::Int # Where to start (resp. end) reading from the flattened array.
    end_idx::Int
    # Rectangular dimensions of the parameter (e.g. (2, 3) for a 2x3 matrix)
    # For nested parameters, this will be the dimensions of the outermost array.
    dimensions::Tuple
    type::VariableType # Type of the parameter
    contents::Vector{Variable} # Array of possibly nested variables
end

function columns(v::Variable)
	return v.start_idx:v.end_idx-1
end

function num_elts(v::Variable)
	return prod(v.dimensions)
end

function elt_size(v::Variable)
	return v.end_idx - v.start_idx
end

function _munge_first_tuple(fld::AbstractString)
	return "dummy_" * String(split(fld, ":"; limit=2)[2])
end

function _get_base_name(fld::AbstractString)
	return String(split(fld, [':', '.'])[1])
end

function _from_header(hdr)
	header = String.(vcat(strip.(hdr), "__dummy"))
	entries = header
	params = Variable[]
	var_type = SCALAR
	start_idx = 1
	name = _get_base_name(entries[1])
	for i in 1:length(entries)-1
		entry = entries[i]
		next_name = _get_base_name(entries[i+1])
		if next_name !== name
			if isnothing(findfirst(':', entry))
				splt = split(entry, ".")[2:end]
				dims = isnothing(splt) ? () : Meta.parse.(splt)
				var_type = SCALAR
				contents = Variable[]
				append!(params, [Variable(name, start_idx, i+1, tuple(dims...), var_type, contents)])
			elseif !isnothing(findfirst(':', entry))
				dims = Meta.parse.(split(entry, ":")[1] |> x -> split(x, ".")[2:end])
				munged_header = map(_munge_first_tuple, entries[start_idx:i])
				if length(dims) > 0
					munged_header = munged_header[1:(Int(length(munged_header)/prod(dims)))]
				end
				var_type = TUPLE
				append!(params, [Variable(name, start_idx, i+1, tuple(dims...), var_type, 
					_from_header(munged_header))])
			end
			start_idx = i + 1
			name = next_name
		end
	end
	return params
end
	

function dtype(v::Variable, top=TRUE)
	if v.type == TUPLE
		elts = [("$(i + 1)", dtype(p, false)) for (i, p) in enumerate(v.contents)]
	end
	return elts
end

"""

$SIGNATURES

Given a comma-separated list of names of Stan outputs, like
that from the header row of a CSV file, parse it into a 
(ordered) dictionary of `Variable` objects.

Parameters
----------
header::Vector{String}

    Comma separated list of Stan variables, including index information.
    For example, an `array[2] real foo` would be represented as
    `..., foo.1, foo.2, ...` in Stan's .csv file.

Returns
-------
OrderedDict[String, Variable]

    A dictionary mapping the base name of each variable to a struct `Variable`.

Exported.
"""
function parse_header(header::Vector{String})
	d = OrderedDict{String, Variable}()
	for param in _from_header(header)
		d[param.name] = param
	end
	d
end

function _extract_helper(v::Variable, df::DataFrame, offset=0)
	the_start = v.start_idx + offset
	the_end = v.end_idx - 1 + offset
	if v.type == SCALAR
		if length(v.dimensions) == 0
			return Array(df[:, the_start])
		else
			return [reshape(Array(df[i, the_start:the_end]), v.dimensions...) for i in 1:size(df, 1)]
		end
	elseif v.type == TUPLE
		elts = fill(0.0, nrow(df))
		for idx in 1:num_elts(v)
			off = Int((idx - 1) * elt_size(v)//num_elts(v) - 1)
			for param in v.contents
				elts = hcat(elts, _extract_helper(param, df, the_start + off))
			end
		end
		return [Tuple(elts[i, 2:end]) for i in 1:nrow(df)]
	end
end

"""

$SIGNATURES

Given the output of a Stan modelas a DataFrame, 
reshape variable `v` to the correct type and dimensions.


Parameters
----------

v::Variable

	Variable object to use to extract draws.

df::DataFrame

    The DataFrame to extract from. 

Returns
-------

    The extracted variable, reshaped to the correct
    dimensions. If the variable is a tuple, this
    will be an array of tuples.

Not exported.
"""
function extract_helper(v::Variable, df::DataFrame, offset=0; object=true)
	out = _extract_helper(v, df)
	if v.type == TUPLE
		if v.type == TUPLE
			atr = []
			elts = [p -> p.dimensions == () ? (1,) : p.dimensions for p in v.contents]
			for j in 1:length(out)
				at = Tuple[]
				for i in 1:length(elts):length(out[j])
					append!(at, [(out[j][i], out[j][i+1],)])
				end
				if length(v.dimensions) > 0
					append!(atr, [reshape(at, v.dimensions...)])
				else
					append!(atr, at)
				end
			end
			return convert.(typeof(atr[1]), atr)
		end
	else
		return out
	end
end

"""

$SIGNATURES

Given a dictionary of `Variable` objects and a source 
DataFrame, extract the variables from the source array
and reshape them to the correct dimensions.

Parameters
----------
parameters::OrderedDict{String, Variable}

    A dictionary of `Variable` objects, 
    like that returned by `parse_header()`.

df::DataFrame

    A DataFrame (as returned from `read_csvfiles()`
    or `read_samples(model, :dataframe)`) to 
    extract the draws from.


Returns
-------

    A, possibly nested, DataFrame with reshaped fields. 

Exported.
"""
function stan_variables(dct::OrderedDict{String, Variable}, df::DataFrame)
	res = DataFrame()
	for key in keys(dct)
		res[!, dct[key].name] = extract_helper(dct[key], df)
	end
	res
end
