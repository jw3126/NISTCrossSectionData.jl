function empty_xaamdi_table()
    (E                = empty_col(uenergy ),
     TotalAttenuation = empty_col(umassatt),
     EnergyLoss       = empty_col(umassatt))
end

const XAAMDITable = typeof(empty_xaamdi_table())
struct XAAMDIData <: DataSource
    element_tables::Vector{XAAMDITable}
    compound_tables::Dict{Symbol, XAAMDITable}
end

emptytable(::Type{XAAMDIData}) = empty_xaamdi_table()

const XAAMDI = load(XAAMDIData, Zs=1:92, compounds=[:H2O], dir=datapath("XAAMDI"))

default_data_source(mat, E, ::EnergyLoss) = XAAMDI

function get_table(s::XAAMDIData, key::Symbol)::XAAMDITable
    res = get(s.compound_tables, key, nothing)
    if res === nothing
        get_element_table(s, key)
    else
        res
    end
end
