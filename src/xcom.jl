function empty_xcom_table()
    (
     E                                        = empty_col(uenergy ),
     CoherentScattering                       = empty_col(umassatt),
    IncoherentScattering                      = empty_col(umassatt),
    PhotoelectricAbsorption                   = empty_col(umassatt),
    PairProductionNuclearField                = empty_col(umassatt),
    PairProductionElectronField               = empty_col(umassatt),
    TotalAttenuation                          = empty_col(umassatt),
    TotalAttenuationWithoutCoherentScattering = empty_col(umassatt),
    )
end

struct  XCOMData  <: DataSource 
    tables::Vector{typeof(empty_xcom_table())}
end

emptytable(::Type{XCOMData}) = empty_xcom_table()

const XCOM  = load(XCOMData, Zs=1:100, dir=datapath("XCOM"))

for P in columnnames(XCOMData)
    P == :E && continue
    @eval default_data_source(mat, E, ::$P) = XCOM
end
