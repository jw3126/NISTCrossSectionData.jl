using Unitful
using Unitful: uconvert, NoUnits, cm, g, eV, MeV, u
using PeriodicTable: Element

function datapath(args...)
    datadir = joinpath(@__DIR__, "..", "data")
    abspath(joinpath(datadir, args...))
end
lower_material(Z::Int) = Z
lower_material(el::Element) = el.number
lower_energy(E) = Float64(uconvert(NoUnits, E/MeV))

_ucoalesce(unit, q::Quantity) = uconvert(unit, q)
_ucoalesce(unit, x::Number  ) = x*unit

_ustrip(x::Quantity) = uconvert(UF.NoUnits, x)
_ustrip(x) = x

function density(el::Element)
    _ucoalesce(g*cm^-3, el.density)
end

function linterpol(x, (x_lo, y_lo), (x_hi, y_hi))
    @assert x_lo <= x <= x_hi
    if x_lo == x_hi 
        @assert y_lo == y_hi
        return y_lo
    end
    w = x_hi - x_lo
    w_hi = _ustrip((x - x_lo) / w)
    w_lo = _ustrip((x_hi - x) / w)
    @assert w_lo + w_hi ≈ 1
    y_lo * w_lo + y_hi * w_hi
end

lower(s::DataSource, Z::Int)       = Z
lower(s::DataSource, el::Element)  = el.number
lower(s::DataSource, pt::Particle) = pt.energy
lower(s::DataSource, E::UF.Energy) = E

function lookup(s::DataSource,
                           mat, pt, p)
    E = lower(s, pt)
    Z   = lower(s, mat)
    _lookup(s, Z, E, p)
end

function _lookup(s::DataSource,Z::Int,E::UF.Energy, p::Process)
    table = s.tables[Z]
    Es = table.E
    Cs = getcol(table, p)
    E_min = first(Es)
    E_max = last(Es)
    @assert E_min <= E <= E_max
    E == E_min && return first(Cs)
    index_hi = searchsortedfirst(Es, E)
    index_lo = index_hi - 1
    E_lo = Es[index_lo]
    E_hi = Es[index_hi]
    # check for absorption edge
    absorption_edge = (E == E_hi) &&
        (get(Es, index_hi+1, nothing) == E_hi)
    if absorption_edge
        msg = "Element Z=$Z has an absorption edge at E=$(E)."
        throw(ArgumentError(msg))
    end
    c_lo = Cs[index_lo]
    c_hi = Cs[index_hi]
    linterpol(E, E_lo => c_lo, E_hi => c_hi)
end

function tabletype(pairs...)
    symbols = Symbol[]
    types   = Type[]
    for (s, u) in pairs
        push!(symbols, s)
        Q = typeof(1.0*u)
        @assert (Q <: Quantity) || Q == Float64
        push!(types, Vector{Q})
    end
    NamedTuple{tuple(symbols...), Tuple{types...}}
end

function columnnames(::Type{S}) where {S<:DataSource}
    NT = eltype(first(S.types))
    fieldnames(NT)
end

@generated function getcol(table, process::P) where {P}
    s = Symbol(string(process))
    :(table.$s)
end

empty_col(u) = typeof(1.0*u)[]

function load(::Type{S}; Zs, dir) where {S<:DataSource}
    header = map(string, columnnames(S))
    tables = asyncmap(Zs, ntasks=length(Zs)) do Z
        path = datapath(dir,"Z$Z.csv")
        out = emptytable(S)
        readcsv!(path, out, header=header)
    end
    S(tables)
end
