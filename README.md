# NISTCrossSectionData

## Usage
```julia
using Unitful: MeV
using PeriodicTable
using NISTCrossSectionData

oxygen = elements[8];
mass_coeff(      oxygen,  1MeV, EnergyLoss())
mean_free_path(  oxygen,  1MeV, TotalAttenuation())
attenuation_coeff(oxygen, 10MeV, EnergyLoss())
cross_section(  oxygen,  1MeV, EnergyLoss())
```
