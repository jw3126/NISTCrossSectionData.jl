struct FFASTData <: DataSource 
    tables::Vector{NamedTuple{(:E, :mu, :mu_en),Tuple{Array{Float64,1},Array{Float64,1},Array{Float64,1}}}}
end

function load(::Type{FFASTData})
    header = ["E","mu","mu_en"]
    data = asyncmap(1:92, ntasks=100) do Z
        path = datapath("FFAST","Z$Z.csv")
        out = (E=Float64[], mu=Float64[], mu_en=Float64[])
        readcsv!(path, out, header=header)
    end
    FFASTData(data)
end

default_data_source(mat, E, ::EnergyLoss) = FFAST
default_data_source(mat, E, ::TotalAttenuation) = FFAST

const FFAST = load(FFASTData)

lower(s::FFASTData,::EnergyLoss) = :mu_en
lower(s::FFASTData,::TotalAttenuation) = :mu
