using DataFrames
using Unitful
using Unitful: uconvert, NoUnits, cm, g, eV, MeV
using PeriodicTable: Element
import CSV
const TABLE_PRE  = "_________________"
const TABLE_POST = "</PRE></TD>"

function url(Z::Int)
    if Z < 10
        s = "0$Z"
    else
        s = string(Z)
    end
    "https://physics.nist.gov/PhysRefData/XrayMassCoef/ElemTab/z$(s).html"
end

function parse_html(path)
    Es     = Float64[]
    mus    = Float64[]
    mus_en = Float64[]
    insidetable = false
    for line in eachline(path)
        l = strip(line)
        if insidetable
            if occursin(TABLE_POST, l)
                break
            end
            isempty(l) && continue
            numbers = split(l,' ', keepempty=false)
            if length(numbers) == 4  # sometimes shell info in first column
                popfirst!(numbers)
            end
            @assert length(numbers) == 3 "$numbers"
            E,mu,mu_en = map(numbers) do s
                parse(Float64, s)
            end
            push!(Es, E)
            push!(mus,mu)
            push!(mus_en,mu_en)
        end
        if startswith(l, TABLE_PRE)
            insidetable=true
        end
    end
    if !insidetable
        @show path
    end
    @assert issorted(Es)
    @assert !isempty(Es)
    df = DataFrame(:E => Es, :TotalAttenuation => mus, :EnergyLoss => mus_en)
end

datadir = "../../data/FFAST"
function download_table(Z::Int, csvpath = joinpath(datadir, "Z$Z.csv"))
    df = Z |> 
    url |>
    download |>
    parse_html
    mkpath(splitdir(csvpath)[1])
    CSV.write(csvpath, df)
end

asyncmap(download_table, 1:92, ntasks=200)
