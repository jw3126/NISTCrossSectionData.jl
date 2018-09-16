function readcsv!(io::IO, out::NamedTuple; header=nothing, sep=',')
    ncols = length(out)
    if header != nothing
        line = readline(io)
        pieces = split(line, sep)
        @assert length(pieces) == length(header) == ncols
        @assert header == map(strip, pieces)
    end
    while !eof(io)
        line = readline(io)
        pieces = split(line, sep)
        @assert length(pieces) == length(out)
        for i in 1:ncols
            x = parse(Float64, popfirst!(pieces))
            push!(out[i], x)
        end
        @assert isempty(pieces)
    end
    out
end

function readcsv!(path::AbstractString, out::NamedTuple; kw...)
    open(path) do io
        readcsv!(io, out; kw...)
    end
end
