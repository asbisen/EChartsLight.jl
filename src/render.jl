

"""
Returns the path of the [theme].min.js
"""
function _asset_theme(theme::AbstractString)
  theme_path = joinpath(remote_themes_root, "$(theme).min.js")
  return theme_path
end


"""
Emit Javascript code for plotting charts. This would be embedded in the
html. If the `target` is "requirejs", the code will be wrapped in a requirejs
define block, which is required for properly plotting in some environments like
Quarto notebooks.
"""
function _generate_js(ec::EChart; div_id=nothing, target="plainjs")
  div_id = isnothing(div_id) ? div_id = "echart-" * randstring() : div_id

  echart_js = """
    var myChart = echarts.init(document.getElementById('$div_id'), '$(ec.options.theme)', {renderer: '$(ec.options.renderer)'});
    var option = JSON.parse('$(JSON3.write(ec.config))');
    myChart.setOption(option);
    """

  # requirejs adds the .js suffix automatically so we need to strip it here
  jsurl_strip = replace(ec.jsurl, ".js" => "")
  if target == "requirejs"
    res = """
      require.config({
        paths: {
          'echarts': '$(jsurl_strip)',
          'theme/$(ec.options.theme)': '$(replace(_asset_theme(ec.options.theme), ".js" => "" ))'
        }
      });
      require(['echarts', 'theme/$(ec.options.theme)'], function(echarts) {$(echart_js)});
    """
  else
    res = echart_js
  end

  return res
end



"""
Generate HTML within <head>...</head> tags, including the necessary
<script> tags to load ECharts and the selected theme.
"""
function _generate_html_header(ec::EChart; embedjs=false)
  theme_path = _asset_theme(ec.options.theme)

  if embedjs
    return h.head(
        h.meta(charset="utf-8"),
        h.script(read(ec.jsurl, String)),
        h.script(src=theme_path)
    )
  else
    return h.head(
        h.meta(charset="utf-8"),
        h.script(src=ec.jsurl),
        h.script(src=theme_path)
    )
  end
end


"""
Only generate the HTML <div>...</div> block for embedding in an existing
HTML document.
"""
function _generate_html_div(ec::EChart; div_id=nothing, target="plainjs")
  div_id = isnothing(div_id) ? "echart-" * randstring() : div_id

  jscript = _generate_js(ec; div_id=div_id, target=target)
  node = h.div(id="$div_id", style="width: $(ec.options.width);height: $(ec.options.height);")
  push!(node, h.script(type="text/javascript", jscript))

  return node
end


"""
Generate a complete HTML page including <html>, <head>, and <body> tags.
"""
function _generate_html_page(ec::EChart; div_id=nothing, embedjs=false)
  div_id = isnothing(div_id) ? "echart-" * randstring() : div_id
  page = h.html(
    _generate_html_header(ec; embedjs=embedjs),
    h.body(
      _generate_html_div(ec; div_id=div_id, target="plainjs")
    )
  )
  return page
end