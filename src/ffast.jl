struct FFASTData <: DataSource 
    tables::Vector{DataFrame}
end

function load(::Type{FFASTData})
    data = map(1:92) do Z
        path = datapath("FFAST","Z$Z.csv")
        CSV.read(path, allowmissing=:none)
    end
    FFASTData(data)
end

default_data_source(mat, E, ::EnergyLoss) = FFAST
default_data_source(mat, E, ::TotalAttenuation) = FFAST

const FFAST = load(FFASTData)

lower(s::FFASTData,::EnergyLoss) = :mu_en
lower(s::FFASTData,::TotalAttenuation) = :mu
