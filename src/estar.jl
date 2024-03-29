function empty_estar_table()
    (
    E             = empty_col(uenergy ),
    Collision     = empty_col(ustoppow),
    Radiative     = empty_col(ustoppow),
    Total         = empty_col(ustoppow),
    CSDA          = empty_col(umassrange),
    RadiationYield= empty_col(unone   ),
    DensityEffect = empty_col(unone   ),
   )
end

struct ESTARData  <: DataSource
    element_tables::Vector{typeof(empty_estar_table())}
end
emptytable(::Type{ESTARData}) = empty_estar_table()

const ESTAR  = load(ESTARData, Zs=1:100, dir=datapath("ESTAR"))

for P in columnnames(ESTARData)
    P == :E && continue
    @eval default_data_source(mat, pt::Electron, ::$P) = ESTAR
end
