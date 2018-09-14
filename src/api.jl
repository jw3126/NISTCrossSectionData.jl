export mass_coeff, attenuation_coeff, mean_free_path
export Coeff
@enum Coeff EnergyAbsorption TotalAttenuation

function mass_coeff(mat, E, c::Coeff)
    lookup_mass_coeff(lower_material(mat),
        lower_energy(E),
        lower_coeff(c))
end

function attenuation_coeff(mat, E, c::Coeff)
    q = mass_coeff(mat, E, c) / density(mat)
    uconvert(inv(cm), q)
end

mean_free_path(args...) = uconvert(cm, 1 / attenuation_coeff(args...))
