push!(LOAD_PATH,"Y:/_raspberry/")

using Documenter, LEDStrip

makedocs(
    sitename = "LEDStrip Documentation",
    modules = [LEDStrip],
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/metelkin/LEDStrip.jl.git",
    target = "build",
)