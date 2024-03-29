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

const XCOMTable = typeof(empty_xcom_table())
struct XCOMData  <: DataSource
    element_tables::Vector{XCOMTable}
    compound_tables::Dict{Symbol, XCOMTable}
end

emptytable(::Type{XCOMData}) = empty_xcom_table()

const XCOM  = load(XCOMData, Zs=1:100, compounds=[:H2O],
                   dir=datapath("XCOM"))

function get_table(s::XCOMData, key::Symbol)::XCOMTable
    res = get(s.compound_tables, key, nothing)
    if res === nothing
        get_element_table(s, key)
    else
        res
    end
end

for P in columnnames(XCOMData)
    P == :E && continue
    @eval default_data_source(mat, E, ::$P) = XCOM
end
