function empty_ffast_table()
    (E                = empty_col(uenergy ), 
     TotalAttenuation = empty_col(umassatt),
     EnergyLoss       = empty_col(umassatt))
end

struct FFASTData <: DataSource 
    tables::Vector{typeof(empty_ffast_table())}
end

emptytable(::Type{FFASTData}) = empty_ffast_table()

const FFAST = load(FFASTData, Zs=1:92, dir=datapath("FFAST"))

default_data_source(mat, E, ::EnergyLoss) = FFAST
