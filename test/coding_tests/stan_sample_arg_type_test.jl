input_union = Union{Dict, NamedTuple, Vector, AbstractString}

function ss(data::S, init::T) where {T <: input_union, S <: input_union}
  
  println([typeof(data), typeof(init)])
  println()
  [data, init]
end

dct = Dict(:one => 1)
nt = (one = 1, two = 2,)
vct = [Dict(:one => 1), Dict(:two => 2)]
fname = "file_name"

ss(dct, nt) |> display
println()

ss(nt, fname) |> display
println()

ss(vct, vct) |> display
println()

ss(fname, dct) |> display
println()
