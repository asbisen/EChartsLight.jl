module EChartsLight

using EasyConfig: Config

using Cobweb
import Cobweb: h, preview

using JSON3  
using Random
using Downloads
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
local_themes_root = joinpath(artifact_dir, "node_modules", "echarts", "theme")

echarts_version = "6.0.0"
remote_cdn_root = "https://cdnjs.cloudflare.com/ajax/libs/echarts/$(echarts_version)"
remote_echarts_js = joinpath(remote_cdn_root, "echarts.js")
remote_echarts_min_js = joinpath(remote_cdn_root, "echarts.min.js")
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
    init::Config
    option::Config
end

function EChart(; width="800px", height="400px", renderer="svg", theme="vintage")
    init = Config(:width => width, :height => height, :renderer => renderer, :theme => theme)
    option = Config(:toolbox => toolbox_defaults, :tooltip => tooltip_defaults)
    return EChart(init, option)
end

include("utils.jl")


function Base.show(io::IO, ::MIME"text/html", ec::EChart)
    # check if we are in a quarto notebook
    # if we are in quarto, generate HTML that works with "requirejs" loader
    # otherwise generate a full HTML page
    in_quarto = contains.(lowercase.(string.(names(Main))), "quarto") |> any
    if in_quarto 
        page = _render_html_div(ec; target="requirejs")
        return show(io, MIME"text/html"(), page)
    else
        page = _render_html_page(ec)     # Render to HTML
        return show(io, MIME"text/html"(), page)
    end
end


function Base.show(io::IO, ::MIME"juliavscode/html", ec::EChart)
    # Embed Javascript in the HTML page when displaying the chart in VSCode
    # as VSCode would not have access to local file system
    page = _render_html_page(ec; embed=true)     # Render to HTML
    return show(io, MIME"text/html"(), page)
end

"""
Write a complete HTML page with the EChart to the specified file path.

TODO: add options for handling reference to js files
    - local
    - remote (cdn)
    - embedded
"""
function save(ec::EChart, filepath::AbstractString; embed=true, remote=false, minified=true)
    page = _render_html_page(ec; embed=embed, remote=remote, minified=minified)
    open(filepath, "w") do io
        write(io, page)
    end
    return nothing
end

end # module EChartsLight
