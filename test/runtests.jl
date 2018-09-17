using NISTCrossSectionData
const P = NISTCrossSectionData
using Test
using PeriodicTable
using Unitful: cm, g, mg, MeV, eV

@testset "implementation details" begin
    @test P.linterpol(1.7, 1=>10, 2=>20) ≈ 17
    @test P.linterpol(1., 1=>10, 2=>20) ≈ 10
    @test P.linterpol(2., 1=>10, 2=>20) ≈ 20
end

@testset "FFAST" begin
    unit = cm^2/g
    O = elements[8]
    E = 1MeV
    @test mass_coeff(O, E, EnergyLoss(),datasource=FFAST     ) == 0.02794unit
    @test mass_coeff(O, E, EnergyLoss()) == 0.02794unit
end
@testset "XCOM" begin
    unit = cm^2/g
    V = elements[23]
    E = 2.044MeV
    for (PT, value) in [
        (CoherentScattering                       , 8.268E-05*cm^2/g)
        (IncoherentScattering                     , 3.934E-02*cm^2/g)
        (PhotoelectricAbsorption                  , 5.986E-05*cm^2/g)
        (PairProductionNuclearField               , 1.248E-03*cm^2/g)
        (PairProductionElectronField              , 0.000E+00*cm^2/g)
        (TotalAttenuation   , 4.073E-02*cm^2/g)
        (TotalAttenuationWithoutCoherentScattering, 4.065E-02*cm^2/g)]
        @test mass_coeff(V,E,PT(),datasource=XCOM) == value
        @test mass_coeff(V,E,PT()) == value
    end
end

@testset "mass_coeff" begin
    unit = cm^2/g
    O = elements[8]
    @test mass_coeff(O, 1MeV, EnergyLoss()) == 0.02794unit
    @test mass_coeff(O, 1MeV, EnergyLoss()) == 0.02794unit

    U = elements[92]
    # extremal energies
    E_min = 0.001MeV
    E_max = 20MeV
    @test mass_coeff(U, E_min, TotalAttenuation(), datasource=FFAST) == 6626.0unit
    @test mass_coeff(U, E_min, EnergyLoss()) == 6612.0unit
    
    @test mass_coeff(U, E_max, TotalAttenuation(), datasource=FFAST) == 6.512e-2unit
    @test mass_coeff(U, E_max, EnergyLoss()) == 3.662e-2unit

    # absorption edge
    E_K = 0.115606MeV
    @test_throws ArgumentError mass_coeff(U, E_K, TotalAttenuation(), datasource=FFAST)
    E_K₋ = E_K - 1eV
    E_K₊ = E_K + 1eV
    @test mass_coeff(U, E_K₋, TotalAttenuation(), datasource=FFAST) ≈ 1.378unit rtol=1e-2
    @test mass_coeff(U, E_K₋, EnergyLoss(), datasource=FFAST)       ≈ 1.027unit rtol=1e-2
    @test mass_coeff(U, E_K₊, TotalAttenuation(), datasource=FFAST) ≈ 4.893unit rtol=1e-2
    @test mass_coeff(U, E_K₊, EnergyLoss(), datasource=FFAST)       ≈ 1.382unit rtol=1e-2
end

@testset "api" begin
    oxygen = elements[8];
    @inferred mass_coeff(      oxygen,  1MeV, EnergyLoss())
    @inferred mean_free_path(  oxygen,  1MeV, TotalAttenuation())
    @inferred mean_free_path(  oxygen,  1MeV, TotalAttenuation(), density=1mg*cm^-3)
    @inferred attenuation_coeff(oxygen, 10MeV, EnergyLoss())
    @inferred cross_section(  oxygen,  1MeV, TotalAttenuation())
end
