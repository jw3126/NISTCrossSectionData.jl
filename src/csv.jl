colcount(table) = length(table)

function addrow!(table, row)
    @assert colcount(table) == length(row)
    foreach(table, row) do col, val
        push!(col, val*unit(eltype(col)))
    end
    table
end

function readcsv!(io::IO, table::NamedTuple; header=nothing, sep=',')
    ncols = colcount(table)
    if header != nothing
        line = readline(io)
        pieces = split(line, sep)
        @assert length(pieces) == length(header) == ncols
        @argcheck collect(header) == map(strip, pieces)
    end
    while !eof(io)
        line = readline(io)
        pieces = split(line, sep)
        @assert length(pieces) == ncols
        vals = map(s -> parse(Float64, s), pieces)
        addrow!(table, vals)
    end
    table
end

function readcsv!(path::AbstractString, out::NamedTuple; kw...)
    open(path) do io
        readcsv!(io, out; kw...)
    end
end
