module NISTCrossSectionData
using ArgCheck
using Unitful
const UF = Unitful
using Unitful: MeV, g, cm

const uenergy  = MeV
const umassatt = cm^2/g
const umassrange = inv(umassatt)
const ustoppow = uenergy * umassatt
const unone    = Unitful.NoUnits

include("api.jl")
include("tables.jl")
include("csv.jl")
include("ffast.jl")
include("xcom.jl")
include("estar.jl")

end # module
