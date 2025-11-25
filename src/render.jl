

"""
Returns the path of the [theme].min.js file if it exists in the package path.
"""
function _asset_theme(theme::AbstractString)
  theme_path = joinpath(remote_themes_root, "$(theme).min.js")

  if startswith(theme_path, "http://") || startswith(theme_path, "https://")
    try
      HTTP.get(theme_path)  # Check if the file is accessible
    catch e
      @warn("Theme file at $theme_path is not accessible. Using the provided path.")
    end
  end
  return theme_path
end





function _render_html_head(ec::EChart)
  theme_path = _asset_theme(ec.options.theme)
  jsurl = ec.jsurl
  h.head(
    h.meta(charset="utf-8"),
    h.script(src=jsurl),
    h.script(src=theme_path)
  )
end





function _render_html_body(ec::EChart; div_id=nothing)
  if div_id === nothing
    div_id = "echart-" * randstring()
  end

  jscrpt = """
    var myChart = echarts.init(document.getElementById('$div_id'), '$(ec.options.theme)', {renderer: '$(ec.options.renderer)'});
    var option = JSON.parse('$(JSON3.write(ec.config))');
    myChart.setOption(option);
  """
    
  body = h.body(
    h.div(id="$div_id", style="width: $(ec.options.width);height: $(ec.options.height);"),
    h.script(type="text/javascript", jscrpt)
  )

  return body
end





"""
Generate a complete standalone html page consisting of the chart
"""
function _render_html_page(ec::EChart)
  div_id = "echart-" * randstring()
  page = h.html(
    # TODO: 
    #   - refactor to make identification of JS more robust
    #   - can we embed the echarts.min.js
    _render_html_head(ec),
    _render_html_body(ec; div_id=div_id)
    )
    page
end




