using StanSample, Test

# Testing

a3d_array = rand(10, 5, 4)
cnames = [:a, Symbol("b[1]"), Symbol("b.2"), :bb, :sigma]

st2 = convert_a3d(a3d_array, cnames, Val(:table); start=6, chains=[1, 4])
df2 = DataFrame(st2)
#df2 |> display

rows = Tables.rows(st2)
let
    local rowvals
    for row in rows
        rowvals = [Tables.getcolumn(row, col) for col in Tables.columnnames(st2)]
    end
    @test typeof(rowvals) == Vector{Float64}
    @test size(rowvals) == (5,)
    @test rowvals == a3d_array[end, :, 4]
end

@test Tables.getcolumn(rows, Symbol("b.2")) == 
    vcat(a3d_array[6:10, 3, 1], a3d_array[6:10, 3, 4])

@test size(Tables.matrix(st2)) == (10, 5)

@test Tables.matrix(convert_a3d(a3d_array, cnames, Val(:table); start=6, chains=[2])) ==
    a3d_array[6:end, :, 2]

@test Tables.getcolumn(rows, Symbol("b.2")) == df2[:, "b.2"]

bt = matrix(st2, :b)

@test size(bt) == (10, 2)
