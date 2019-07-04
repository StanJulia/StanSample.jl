abstract type AbstractModels end

struct Model1 <: AbstractModels end
struct Model2 <: AbstractModels end

m1 = Model1()
m2 = Model2()

data_union = Union{Missing, AbstractString, Dict, Array{T, 1} where T, NamedTuple}
init_union = Union{Missing, AbstractString, Dict, Array{T, 1} where T, NamedTuple}

function method2(model, data::Union{NamedTuple, Dict})
  
  println("Method 2 called.\n")
end

function method1(model::AbstractModels; kwargs...)
    println("Method 1 called.")
    :init in keys(kwargs) && println("$(kwargs[:init])")
    :init in keys(kwargs) && println("$(kwargs[:init].v)")
    :data in keys(kwargs) && println("$(kwargs[:data])")
    :data in keys(kwargs) && println("$(kwargs.data)")
    println()
end


method1(m1)
method1(m2, data=(z=12,))
method1(m1; data = (x=2, z=13))
method1(m1; init = (v=2,))
method1(m1; init = (v=2,), data = (y=3,))

method2(m2, (x=2,))
method2(m1, Dict(:x=>2))
