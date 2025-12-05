using Test

# load the module source relative to this test file
using EChartsLight

@testset "EChartsLight" begin
    ec = EChart()
    @test ec.init.width == "800px"
    @test ec.init.height == "400px"
    @test ec.init.renderer == "svg"
    @test occursin("echarts", ec.jsurl)

    # Render body with a fixed div id and inspect HTML
    body = EChartsLight._generate_html_page(ec; div_id="testdiv")
    io = IOBuffer()
    show(io, MIME"text/html"(), body)
    html = String(take!(io))

    @test occursin("id=\"testdiv\"", html) || occursin("id='testdiv'", html)
    @test occursin("echarts.init(document.getElementById('testdiv')", html) || occursin("echarts.init(document.getElementById(\"testdiv\")", html)
    @test occursin("renderer: 'svg'", html) || occursin("renderer: \"svg\"", html)
    @test occursin("width: 800px;height: 400px", html)

    # Full page contains external script src and script tag
    page = EChartsLight._generate_html_page(ec)
    io2 = IOBuffer()
    show(io2, MIME"text/html"(), page)
    page_html = String(take!(io2))
    @test occursin(ec.jsurl, page_html)
    @test occursin("<script", page_html)

    # Base.show for EChart produces HTML output
    io3 = IOBuffer()
    show(io3, MIME"text/html"(), ec)
    shown = String(take!(io3))
    @test occursin("echarts", shown)
end