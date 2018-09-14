using NISTCrossSectionData
const P = NISTCrossSectionData
using Test
using PeriodicTable
using Unitful: cm, g, MeV, eV

@testset "implementation details" begin
    @test P.linterpol(1.7, 1=>10, 2=>20) ≈ 17
    @test P.linterpol(1., 1=>10, 2=>20) ≈ 10
    @test P.linterpol(2., 1=>10, 2=>20) ≈ 20
end

@testset "mass_coeff" begin
    unit = cm^2/g
    O = elements[8]
    @test mass_coeff(O, 1MeV, EnergyAbsorption) == 0.02794unit
    @test mass_coeff(O, 1MeV, TotalAttenuation) == 6.372e-2unit
    
    U = elements[92]
    @test mass_coeff(U, 20MeV, TotalAttenuation) == 6.512e-2unit
    @test mass_coeff(U, 20MeV, EnergyAbsorption) == 3.662e-2unit
    # absorption edge
    E_K = 1.15606E-01MeV
    E_K₋ = E_K - 1eV
    E_K₊ = E_K + 1eV
    @test mass_coeff(U, E_K₋, TotalAttenuation) ≈ 1.378unit rtol=1e-2
    @test mass_coeff(U, E_K₋, EnergyAbsorption) ≈ 1.027unit rtol=1e-2
    @test mass_coeff(U, E_K₊, TotalAttenuation) ≈ 4.893unit rtol=1e-2
    @test mass_coeff(U, E_K₊, EnergyAbsorption) ≈ 1.382unit rtol=1e-2
end

@testset "api" begin
    oxygen = elements[8];
    mass_coeff(      oxygen,  1MeV, EnergyAbsorption)
    mean_free_path(  oxygen,  1MeV, TotalAttenuation)
    attenuation_coeff(oxygen, 10MeV, EnergyAbsorption)
    cross_section(  oxygen,  1MeV, TotalAttenuation)
end
