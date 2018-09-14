using DataFrames
using Unitful
using Unitful: uconvert, NoUnits, cm, g, eV, MeV
using PeriodicTable: Element
import CSV
const TABLE_PRE  = "_________________"
const TABLE_POST = "</PRE></TD>"

function mu_en_url(Z::Int)
    if Z < 10
        s = "0$Z"
    else
        s = string(Z)
    end
    "https://physics.nist.gov/PhysRefData/XrayMassCoef/ElemTab/z$(s).html"
end

function mu_en_parse_html(path)
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
    df = DataFrame(:E => Es, :mu => mus, :mu_en => mus_en)
end

datadir = "../data/mass_energy_absorption"
function mu_en_download(Z::Int, csvpath = joinpath(datadir, "Z$Z.csv"))
    df = Z |> 
    mu_en_url |>
    download |>
    mu_en_parse_html
    mkpath(splitdir(csvpath)[1])
    CSV.write(csvpath, df)
end

asyncmap(mu_en_download, 1:92, ntasks=200)
