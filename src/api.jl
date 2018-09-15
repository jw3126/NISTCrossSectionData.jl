export mass_coeff, attenuation_coeff, mean_free_path, cross_section
export FFAST
export EnergyAbsorption, TotalAttenuation

"""
    lookup_mass_coeff(s::DataSource, E::Energy, m::Element, p::Process)

Must be implemented.
"""
abstract type DataSource end

abstract type Process end

struct EnergyAbsorption <: Process end
struct TotalAttenuation <: Process end

function mass_coeff(mat, E, p::Process,
                    datasource=nothing)
    mat0 = lower_material(mat)
    E0 = lower_energy(E)
    p0 = p
    if datasource == nothing
        datasource0 = default_data_source(mat0, E0, p0)
    else
        datasource0 = datasource
    end
    lookup_mass_coeff(datasource0, mat0, E0, p0)
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
