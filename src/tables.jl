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
    @assert w > 0
    w_hi = (x - x_lo) / w
    w_lo = (x_hi - x) / w
    @assert w_lo + w_hi ≈ 1
    y_lo * w_lo + y_hi * w_hi
end

_ustrip(unit, x::Quantity) = uconvert(NoUnits, x/unit)
_ustrip(unit, x) = x
lower(s::DataSource, E) = Float64(_ustrip(MeV, E))
lower(s::DataSource, Z::Int) = Z
lower(s::DataSource, el::Element) = el.number

function lookup_mass_coeff(s::DataSource,
                           mat, E, p)
    col = lower(s,p)
    E0  = lower(s,E)
    Z   = lower(s, mat)
    _lookup_mass_coeff(s, Z, E0, col)
end

function _lookup_mass_coeff(s::DataSource,Z::Int,E::Float64, col::Symbol)
    unit = cm^2/g
    table = s.tables[Z]
    Es::Vector{Float64} = table.E
    Cs::Vector{Float64} = getfield(table, col)
    E_min = first(Es)
    E_max = last(Es)
    @assert E_min <= E <= E_max
    E == E_min && return first(Cs) * unit
    index_hi = searchsortedfirst(Es, E)
    index_lo = index_hi - 1
    E_lo = Es[index_lo]
    E_hi = Es[index_hi]
    # check for absorption edge
    absorption_edge = (E == E_hi) &&
        (get(Es, index_hi+1, NaN) == E_hi)
    if absorption_edge
        msg = "Element Z=$Z has an absorption edge at E=$(E)MeV."
        throw(ArgumentError(msg))
    end
    c_lo = Cs[index_lo]
    c_hi = Cs[index_hi]
    linterpol(E, E_lo => c_lo, E_hi => c_hi) * unit
end
