struct FFASTData <: DataSource 
    tables::Vector{NamedTuple{(:E, :TotalAttenuation, :EnergyLoss),NTuple{3,Array{Float64,1}}}}
end


const FFAST = load(FFASTData, Zs=1:92, dir=datapath("FFAST"))

default_data_source(mat, E, ::EnergyLoss) = FFAST
