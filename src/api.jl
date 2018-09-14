export mass_coeff, attenuation_coeff, mean_free_path, cross_section
export Coeff, EnergyAbsorption, TotalAttenuation
@enum Coeff EnergyAbsorption TotalAttenuation

function mass_coeff(mat, E, c::Coeff)
    lookup_mass_coeff(lower_material(mat),
        lower_energy(E),
        lower_coeff(c))
end

function attenuation_coeff(mat, args...; density=density(mat))
    q = mass_coeff(mat, args...) * density
    uconvert(inv(cm), q)
end

function cross_section(mat, args...)
    q = mass_coeff(mat, args...) * mat.atomic_mass
    uconvert(cm^2, q)
end

mean_free_path(args...;kw...) = uconvert(cm, 1 / attenuation_coeff(args...; kw...))
