using DataFrames
using Unitful
using Unitful: uconvert, NoUnits, cm, g, eV, MeV, u
using PeriodicTable: Element
import CSV

function datapath(args...)
    datadir = joinpath(@__DIR__, "..", "data")
    abspath(joinpath(datadir, args...))
end

function load_mu_en_tables()
    map(1:92) do Z
        path = datapath("mass_energy_absorption","Z$Z.csv")
        CSV.read(path, allowmissing=:none)
    end
end

const MU_EN_TABLES = load_mu_en_tables()

function lower_coeff(c::Coeff)
    if c == TotalAttenuation
        :mu
    else
        @assert c == EnergyAbsorption
        :mu_en
    end
end

lower_material(Z::Int) = Z
lower_material(el::Element) = el.number
# const MeV = 10^6eV
lower_energy(E) = Float64(uconvert(NoUnits, E/MeV))

_ucoalesce(unit, q::Quantity) = uconvert(unit, q)
_ucoalesce(unit, x::Number  ) = x*unit

function density(el::Element)
    _ucoalesce(g*cm^-3, el.density)
end

# function number_density(el::Element)
#     q = density(el) / _ucoalesce(u, el.atomic_mass)
# end

function lookup_mass_coeff(Z::Int,E::Float64, col::Symbol)
    table = MU_EN_TABLES[Z]
    Es = table[:E]
    Cs = table[col]
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
