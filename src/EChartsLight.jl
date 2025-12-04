module EChartsLight

using EasyConfig: Config

using Cobweb
import Cobweb: h, preview

using JSON3  
using Random

export Config  # From EasyConfig
export preview # From Cobweb
# EasyConfig depends upon JSON3 once they migrate
# to JSON we should change this to JSON


# Path to ECharts Javascript files (local and remote)

using ECharts_jll

artifact_dir = ECharts_jll.artifact_dir
local_js_dir = joinpath(artifact_dir, "node_modules", "echarts", "dist")
local_echarts_min_js = joinpath(local_js_dir, "echarts.min.js")
local_echarts_js = joinpath(local_js_dir, "echarts.js")

local_themes_dir = joinpath(artifact_dir, "echarts", "theme")

echarts_version = "6.0.0"
remote_cdn_root = "https://cdnjs.cloudflare.com/ajax/libs/echarts/$(echarts_version)"
remote_js_path = joinpath(remote_cdn_root, "echarts.min.js")
remote_themes_root = joinpath(remote_cdn_root, "theme")



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

tooltip_defaults = Config(
        :show => true,
        :trigger => "item"
    )


export EChart,
       save
       
mutable struct EChart
    config::Config
    options::Config
    jsurl::String
end

function EChart(; width="800px", height="400px", renderer="svg", theme="vintage")
    opts = Config(:width => width, :height => height, :renderer => renderer, :theme => theme)
    config = Config(:toolbox => toolbox_defaults, :tooltip => tooltip_defaults)
    jsurl = remote_js_path
    return EChart(config, opts, jsurl)
end


include("render.jl")

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


function Base.show(io::IO, ::MIME"juliavscode/html", ec::EChart)
    # Embed Javascript in the HTML page when displaying the chart in VSCode
    # as VSCode would not have access to local file system
    page = _generate_html_page(ec; embedjs=true)     # Render to HTML
    return show(io, MIME"text/html"(), page)
end

"""
Write a complete HTML page with the EChart to the specified file path.

TODO: add options for handling reference to js files
    - local
    - remote (cdn)
    - embedded
"""
function save(ec::EChart, filepath::AbstractString; embedjs=true)
    page = _generate_html_page(ec; embedjs=embedjs)
    open(filepath, "w") do io
        write(io, page)
    end
    return nothing
end

end # module EChartsLight
