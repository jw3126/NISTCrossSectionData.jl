using InteractiveUtils
export mass_coeff, attenuation_coeff, mean_free_path, cross_section
export FFAST
export XCOM
export ESTAR

export EnergyLoss
export TotalAttenuation
export CoherentScattering
export IncoherentScattering
export PhotoelectricAbsorption
export PairProductionNuclearField
export PairProductionElectronField
export TotalAttenuationWithoutCoherentScattering

export Collision
export Radiative
export Total
export CSDA
export RadiationYield
export DensityEffect

"""
    lookup_mass_coeff(s::DataSource, E::E, m::Element, p::Process)

Must be implemented.
"""
abstract type DataSource end

abstract type Process end

# FFAST
struct EnergyLoss <: Process end
struct TotalAttenuation <: Process end

# XCOM
struct CoherentScattering <: Process end
struct IncoherentScattering <: Process end
struct PhotoelectricAbsorption <: Process end
struct PairProductionNuclearField <: Process end
struct PairProductionElectronField <: Process end
struct TotalAttenuationWithoutCoherentScattering <: Process end

# ESTAR
struct Collision      <: Process end
struct Radiative      <: Process end
struct Total          <: Process end # merge with TotalAttenuation?
struct CSDA           <: Process end
struct RadiationYield <: Process end
struct DensityEffect  <: Process end


function mass_coeff(mat, E, p::Process;
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

function stopping_power(mat, E, p::Process; datasource=default_data_source(mat,E,p))
    q = lookup_stopping_power(datasource,mat,E,p)
    uconvert(MeV*cm^2/g, q)
end

mean_free_path(args...;kw...) = uconvert(cm, 1 / attenuation_coeff(args...; kw...))
