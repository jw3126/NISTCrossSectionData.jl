# NISTCrossSectionData

[![Build Status](https://travis-ci.org/jw3126/NISTCrossSectionData.jl.svg?branch=master)](https://travis-ci.org/jw3126/NISTCrossSectionData.jl)
[![codecov.io](https://codecov.io/github/jw3126/NISTCrossSectionData.jl/coverage.svg?branch=master)](http://codecov.io/github/jw3126/NISTCrossSectionData.jl?branch=master)

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

## Datasets

The following datasets taken from [NIST](https://www.nist.gov/) are available:

* [FFAST](https://physics.nist.gov/PhysRefData/XrayMassCoef/tab3.html)
* [XCOM](https://physics.nist.gov/PhysRefData/Xcom/html/xcom1.html)
