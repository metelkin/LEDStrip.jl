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
