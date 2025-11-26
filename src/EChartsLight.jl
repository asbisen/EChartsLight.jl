module EChartsLight

using HTTP
using EasyConfig: Config

using Cobweb
import Cobweb: h, preview

using JSON3  
using Random

export Config  # From EasyConfig
export preview # From Cobweb
# EasyConfig depends upon JSON3 once they migrate
# to JSON we should change this to JSON

echarts_version = "6.0.0"
remote_cdn_root = "https://cdnjs.cloudflare.com/ajax/libs/echarts/$(echarts_version)"
remote_js_path = joinpath(remote_cdn_root, "echarts.min.js")
remote_themes_root = joinpath(remote_cdn_root, "theme")

local_js_path = normpath(joinpath(@__DIR__, "..", "assets", "js", "echarts.js"))
local_themes_dir = normpath(joinpath(@__DIR__, "..", "assets", "themes"))



toolbox_defaults = Config(
        :show => true,
        :orient => "vertical",
        :feature => Config(
            :saveAsImage => Config(:show => true),
            :dataZoom    => Config(:show => true),
            :brush       => Config(:show => false),
            :magicType   => Config(:show => false),
            :dataView    => Config(:show => false),
            :restore     => Config(:show => true)
            )
    )


export EChart
Base.@kwdef mutable struct EChart
    config::Config   = Config(:toolbox => toolbox_defaults)
    options::Config  = Config(:width => "800px", :height => "400px", :renderer => "svg", :theme => "vintage")
    jsurl::String    = remote_js_path 
end


include("render.jl")
export _render_html_page

include("utils.jl")


function Base.show(io::IO, ::MIME"text/html", ec::EChart)
    # check if we are in a quarto notebook
    # if we are in quarto, generate HTML that works with "requirejs" loader
    # otherwise generate a full HTML page
    in_quarto = contains.(lowercase.(string.(names(Main))), "quarto") |> any
    if in_quarto
        page = _generate_html_div(ec; target="requirejs")
        return show(io, MIME"text/html"(), page)
    else
        page = _generate_html_page(ec)     # Render to HTML
        return show(io, MIME"text/html"(), page)
    end
end


end # module EChartsLight
