using DataFrames
using Unitful
using Unitful: uconvert, NoUnits, cm, g, eV, MeV, u
using PeriodicTable: Element
import CSV

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
    x_lo == x_hi && return y_lo
    w = x_hi - x_lo
    @assert w > 0
    w_hi = (x - x_lo) / w
    w_lo = (x_hi - x) / w
    @assert w_lo + w_hi ≈ 1
    y_lo * w_lo + y_hi * w_hi
end

_ustrip(unit, x::Quantity) = uconvert(NoUnits, x/unit)
_ustrip(unit, x) = x
lower(s::DataSource, E) = _ustrip(MeV, E)
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
    table = s.tables[Z]
    Es::Vector{Float64} = table[:E]
    Cs::Vector{Float64} = table[col]
    E_min = first(Es)
    E_max = last(Es)
    @assert E_min <= E <= E_max
    E == E_min && return first(Cs)
    index_hi = searchsortedfirst(Es, E)
    index_lo = index_hi - 1
    E_lo = Es[index_lo]
    E_hi = Es[index_hi]
    c_lo = Cs[index_lo]
    c_hi = Cs[index_hi]
    unit = cm^2/g
    linterpol(E, E_lo => c_lo, E_hi => c_hi) * unit
end
