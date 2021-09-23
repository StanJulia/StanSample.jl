using StanSample, Tables, Test

# Testing

mat = [1 4.0 "7"; 2 5.0 "8"; 3 6.0 "9"]
stantbl = Tables.table(mat)

# first, create a MatrixTable from our matrix input
mattbl = Tables.table(mat)
# test that the MatrixTable `istable`
@test Tables.istable(typeof(mattbl))
# test that it defines row access
@test Tables.rowaccess(typeof(mattbl))
@test Tables.rows(mattbl) === mattbl
# test that it defines column access
@test Tables.columnaccess(typeof(mattbl))
@test Tables.columns(mattbl) === mattbl
# test that we can access the first "column" of our matrix table by column name
@test mattbl.Column1 == [1,2,3]
# test our `Tables.AbstractColumns` interface methods
@test Tables.getcolumn(mattbl, :Column1) == [1,2,3]
@test Tables.getcolumn(mattbl, 1) == [1,2,3]
@test Tables.columnnames(mattbl) == [:Column1, :Column2, :Column3]
# now let's iterate our MatrixTable to get our first MatrixRow
matrow = first(mattbl)
@test eltype(mattbl) == typeof(matrow)
# now we can test our `Tables.AbstractRow` interface methods on our MatrixRow
@test matrow.Column1 == 1
@test Tables.getcolumn(matrow, :Column1) == 1
@test Tables.getcolumn(matrow, 1) == 1
@test propertynames(mattbl) == propertynames(matrow) == [:Column1, :Column2, :Column3]

rt = [(a=1, b=4.0, c="7"), (a=2, b=5.0, c="8"), (a=3, b=6.0, c="9")]
ct = (a=[1,2,3], b=[4.0, 5.0, 6.0])

# let's turn our row table into a plain Julia Matrix object
mat = Tables.matrix(rt)
# test that our matrix came out like we expected
@test mat[:, 1] == [1, 2, 3]
@test size(mat) == (3, 3)
@test eltype(mat) == Any
# so we successfully consumed a row-oriented table,
# now let's try with a column-oriented table
mat2 = Tables.matrix(ct)
@test eltype(mat2) == Float64

# now let's take our matrix input, and make a column table out of it
tbl = Tables.table(mat) |> Tables.columntable
@test keys(tbl) == (:Column1, :Column2, :Column3)
@test tbl.Column1 == [1, 2, 3]
# and same for a row table
tbl2 = Tables.table(mat2) |> Tables.rowtable
@test length(tbl2) == 3
@test map(x->x.Column1, tbl2) == [1.0, 2.0, 3.0]

@test Tables.istable(tbl2) == true

