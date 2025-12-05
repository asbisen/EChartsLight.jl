
"""
Returns a list of known themes
"""
function known_themes()
  themes = ["azul", "bee-inspired", "blue", "caravan", "carp",
    "cool", "dark-blue", "dark-bold", "dark-digerati", "dark-fresh-cut",
    "dark-mushroom", "dark", "eduardo", "forest", "fresh-cut", "fruit",
    "gray", "green", "helianthus", "infographic", "inspired", "jazz", "london",
    "macarons", "macarons2", "mint", "rainbow", "red-velvet", "red", "roma",
    "royal", "sakura", "shine", "tech-blue", "v5", "vintage"]
  themes
end



# ---------------- Rendering Chart Utilities ----------------------------------- #

"""
  _echart_js_url(; remote::Bool=false, minified::Bool=true)::AbstractString

Returns the path of the echarts.[min].js, either local or remote.
"""
function _echart_js_url(; remote::Bool=false, minified::Bool=true)
  res = ""
  if remote == true
    if minified == true
      res = remote_echarts_min_js
    else
      res = remote_echarts_js
    end
  elseif remote == false
    if minified == true
      res = local_echarts_min_js
    else
      res = local_echarts_js
    end
  end
  return res
end  



"""
  _echart_theme_url(theme::AbstractString; remote::Bool=false)::AbstractString

Returns the path of the [theme].js, either local or remote.
"""
function _echart_theme_url(theme::AbstractString; remote::Bool=false)::AbstractString
  base = remote ? remote_themes_root : local_themes_root
  theme_path = joinpath(base, "$(theme).js")
  return theme_path
end


"""
  read_js(url::AbstractString)::AbstractString

Reads Javascript code from either a local file or a remote URL and returns it as a string.
"""
function read_js(url::AbstractString)::AbstractString
  if startswith(url, "http://") || startswith(url, "https://")
    data = read(Downloads.download(url), String)
  else
    data = read(url, String)
  end
  return data
end



"""
  _render_jscode(ec::EChart; div_id=nothing, target="default", minified=true, remote=true)::AbstractString

Emit Javascript code for plotting charts. This would be embedded in the
html. If the `target` is "requirejs", the code will be wrapped in a requirejs
define block, which is required for properly plotting in some environments like
Quarto notebooks.
"""
function _render_jscode(ec::EChart; div_id=nothing, target="default", minified=true, remote=true)::AbstractString
  @assert target in ["default", "requirejs"] "target must be either 'default' or 'requirejs'"
  div_id = isnothing(div_id) ? div_id = "echart-" * randstring() : div_id

  echart_js = """
    var myChart = echarts.init(document.getElementById('$div_id'), '$(ec.init.theme)', {renderer: '$(ec.init.renderer)'});
    var option = JSON.parse('$(JSON3.write(ec.option))');
    myChart.setOption(option);
    """

  res = echart_js # use this if target is "default"

  # if target == "requirejs", we need to strip the .js suffix and generate requirejs code
  if target == "requirejs"
    # Get the Javascript URLs for echarts and theme
    @show echarts_jsurl = _echart_js_url(; remote=remote, minified=minified)
    echarts_jsurl = replace(echarts_jsurl, ".js" => "") # strip .js suffix for requirejs
    echarts_theme_jsurl = _echart_theme_url(ec.init.theme; remote=remote)
    echarts_theme_jsurl = replace(echarts_theme_jsurl, ".js" => "") # strip .js suffix for requirejs
    
    res = """
      require.config({
        paths: {
          'echarts': '$(echarts_jsurl)',
          'theme/$(ec.init.theme)': '$(echarts_theme_jsurl)'
        }
      });
      require(['echarts', 'theme/$(ec.init.theme)'], function(echarts) {$(echart_js)});
    """
  end

  return res
end




"""
  _render_html_header(ec::EChart; embed=false, remote=true, minified=true)
Generate HTML within <head>...</head> tags, including the necessary
<script> tags to load ECharts and the selected theme.
"""
function _render_html_header(ec::EChart; embed=false, remote=true, minified=true)
  echarts_jsurl = _echart_js_url(; remote=remote, minified=minified)
  echarts_theme_jsurl = _echart_theme_url(ec.init.theme; remote=remote)


  if embed
    return h.head(
        h.meta(charset="utf-8"),
        h.script(read_js(echarts_jsurl)),
        h.script(read_js(echarts_theme_jsurl))
    )
  else
    return h.head(
        h.meta(charset="utf-8"),
        h.script(src=echarts_jsurl),
        h.script(src=echarts_theme_jsurl)
    )
  end
end



"""
  _render_html_div(ec::EChart; div_id=nothing, target="default")
  
Only generate the HTML <div>...</div> block for embedding in an existing
HTML document.
"""
function _render_html_div(ec::EChart; div_id=nothing, target="default", remote=true, minified=true)
  div_id = isnothing(div_id) ? "echart-" * randstring() : div_id

  jscript = _render_jscode(ec; div_id=div_id, target=target, remote=remote, minified=minified)
  node = h.div(id="$div_id", style="width: $(ec.init.width);height: $(ec.init.height);")
  push!(node, h.script(type="text/javascript", jscript))

  return node
end


"""
  _render_html_page(ec::EChart; div_id=nothing, embed=true, remote=false, minified=true)

Generate a complete HTML page including <html>, <head>, and <body> tags.
"""
function _render_html_page(ec::EChart; div_id=nothing, embed=true, remote=false, minified=true)
  div_id = isnothing(div_id) ? "echart-" * randstring() : div_id
  page = h.html(
    _render_html_header(ec; embed=embed, remote=remote, minified=minified),
    h.body(
      _render_html_div(ec; div_id=div_id, target="default", remote=remote, minified=minified)
    )
  )
  return page
end