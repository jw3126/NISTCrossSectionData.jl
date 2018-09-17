struct  XCOMData  <: DataSource 
    tables::Vector{NamedTuple{(
    :E, 
    :CoherentScattering,
    :IncoherentScattering,
    :PhotoelectricAbsorption,
    :PairProductionNuclearField,
    :PairProductionElectronField,
    :TotalAttenuation,
    :TotalAttenuationWithoutCoherentScattering),NTuple{8,Array{Float64,1}}}}
end
# 
const XCOM  = load(XCOMData, Zs=1:100, dir=datapath("XCOM"))

for P in columnnames(XCOMData)
    P == :E && continue
    @eval default_data_source(mat, E, ::$P) = XCOM
end
