function empty_ffast_table()
    (E                = empty_col(uenergy ),
     TotalAttenuation = empty_col(umassatt),
     EnergyLoss       = empty_col(umassatt))
end

struct XAAMDIData <: DataSource
    element_tables::Vector{typeof(empty_ffast_table())}
end

emptytable(::Type{XAAMDIData}) = empty_ffast_table()

const XAAMDI = load(XAAMDIData, Zs=1:92, dir=datapath("XAAMDI"))

default_data_source(mat, E, ::EnergyLoss) = XAAMDI
