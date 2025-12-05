# EChartsLight.jl

A light-weight Julia wrapper for [Apache ECharts](https://echarts.apache.org/en/index.html). Heavily inspired by [PlotlyLight.jl](https://github.com/JuliaComputing/PlotlyLight.jl)

Here are some [sample charts](https://asbisen.github.io/EChartsLight.jl/) rendered using quarto notebook.

![Example Line Chart](examples/exampleLineChart.png)

## Features

- **Simple API**: Create interactive charts with minimal boilerplate
- **ECharts Configuration**: Direct access to ECharts options through Julia's `Config` objects
- **Multiple Environments**: Works in Jupyter notebooks, Pluto, VS Code, and Quarto documents
- **Flexible Rendering**: Choose between SVG and Canvas renderers

## Quick Start

```julia
using EChartsLight

# Create a simple line chart
x = ["Mon", "Tue", "Wed", "Thu", "Fri"]
y = [150, 230, 224, 218, 135]
data = zip(x,y) |> collect

ec = EChart()
ec.config.title.text = "My First Chart"
ec.config.xAxis = Config(type="category")
ec.config.yAxis = Config(type="value")
ec.config.series = [Config(type="line", data=data)]

# Display the chart
# depending upon your environment you may
# have to use `preview(ec)`
ec  
```

## Basic Usage

### Creating Charts

The main type is `EChart`, which has three key fields:

- `init`: Rendering options (width, height, renderer, theme)
- `option`: ECharts option configuration (chart data, axes, series, etc.)
- `jsurl`: URL to the ECharts JavaScript library

```julia
# Create an EChart with custom dimensions and theme
ec = EChart()
ec.init.width = "600px"
ec.init.height = "400px"
ec.init.theme = "vintage"
ec.init.renderer = "canvas"  # or "svg"
```

### Using Config Objects

The `Config` object (from EasyConfig.jl) allows you to set ECharts options using Julia syntax:

```julia
ec.option.title = Config(text="Sales Data", subtext="Q4 2025")
ec.option.legend.show = true
ec.option.tooltip.show = true
```

### Multiple Series

```julia
ec = EChart()
ec.option.xAxis = Config(type="category", data=["A", "B", "C"])
ec.option.yAxis = Config(type="value")
ec.option.series = [
    Config(type="bar", data=[10, 20, 30], name="Series 1"),
    Config(type="bar", data=[15, 25, 35], name="Series 2")
]
ec.option.legend.show = true
```

## Core Dependencies

- EasyConfig.jl: Configuration object handling
- Cobweb.jl: HTML generation
- JSON3.jl: JSON serialization
