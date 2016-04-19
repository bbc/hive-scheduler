// Render count bar charts, expects an array of data
// of the form:
//   [ { "date": "jan", "count": 200 }, ... ]
// You also need to provide a destination svg element where
// the chart will be drawn
//
function renderD3BarChart(destination, data, primary, secondary) {  

  var svg = d3.select(destination)
  
  var margin = {top: 20, right: 30, bottom: 60, left: 60}
  var width = svg.node().clientWidth - margin.left - margin.right
  
  var height = svg.node().clientHeight - margin.top - margin.bottom;
  
  var svg = d3.select(destination)
  
  var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);  
    
  var y = d3.scale.linear()
    .range([height, 0]);
  
  var bar_width = width / data.length
  var max = d3.max( data, function(d) { return d.count })
  
  y.domain([0,max])
  x.domain(data.map(function(d) { return d.date; }));
  
  var bar = svg.selectAll('g').data(data).enter().append('g')
  
  bar.append('rect')
  .attr('width', x.rangeBand())
  .attr('fill', function(d,i) { return ( i == data.length - 1 ?  secondary :  primary ) } )
  .attr('x', function(d,i) { return margin.left + x(d.date) })
  .attr('height', 0 )
  .attr('y', margin.top + height)
  .transition()
  .duration(500)
  .ease("elastic")
  .delay( function(d, i) { return i * 100 })
  .attr('height', function(d) { return height - y(d.count)  } )
  .attr('y', function(d) { return margin.top + y(d.count) } )
  
  function x_text(d,i) {
    return margin.left + i * bar_width + bar_width/2 - 7;
  }
  
  function y_text(d,i) {
    return margin.top + height + 10;
  }
  
  var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");
  
  var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom")
  
  svg.append("g")
    .attr("class", "y axis")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
    .call(yAxis)
  
  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(" + margin.left + "," + (height + margin.top) + ")")
    .call(xAxis)
        .selectAll("text")	
            .style("text-anchor", "start")
            .attr("dx", '1em')
            .attr("transform", function(d) {
                return "rotate(45)" 
                })

}

