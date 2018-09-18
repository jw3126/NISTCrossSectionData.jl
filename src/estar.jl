struct ESTARData  <: DataSource 
    tables::Vector{NamedTuple{(
    :E, 
    :Collision     ,
    :Radiative     ,
    :Total         ,
    :CSDA          ,
    :RadiationYield,
    :DensityEffect ,
    ),NTuple{7,Array{Float64,1}}}}
end
# 
const ESTAR  = load(ESTARData, Zs=1:100, dir=datapath("ESTAR"))

default_data_source(mat, E, ::CSDA) = ESTAR
