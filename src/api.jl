export mass_coeff, attenuation_coeff, mean_free_path, cross_section
export FFAST
export EnergyLoss, TotalAttenuation

"""
    lookup_mass_coeff(s::DataSource, E::Energy, m::Element, p::Process)

Must be implemented.
"""
abstract type DataSource end

abstract type Process end

struct EnergyLoss <: Process end
struct TotalAttenuation <: Process end

function mass_coeff(mat, E, p::Process,
                    datasource = default_data_source(mat, E, p))

    lookup_mass_coeff(datasource, mat, E, p)
end

function attenuation_coeff(mat, args...; density=density(mat), kw...)
    q = mass_coeff(mat, args...;kw...) * density
    uconvert(inv(cm), q)
end

function cross_section(mat, args...; kw...)
    q = mass_coeff(mat, args...;kw...) * mat.atomic_mass
    uconvert(cm^2, q)
end

mean_free_path(args...;kw...) = uconvert(cm, 1 / attenuation_coeff(args...; kw...))
