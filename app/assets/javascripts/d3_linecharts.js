function renderD3LineChart(destination, data) {

  // set the dimensions and margins of the graph
  var margin = {top: 20, right: 20, bottom: 30, left: 50},
      width = 960 - margin.left - margin.right,
      height = 500 - margin.top - margin.bottom;

  // parse the date / time
  //var parseTime = d3.timeParse("%Y-%m-%d");
  var parseDate = d3.time.format("%Y-%m-%d").parse;


  // set the ranges
  var x = d3.time.scale().range([0, width]);
  var y = d3.scale.linear().range([height, 0]);

  // Define the axes
  var xAxis = d3.svg.axis().scale(x)
      .orient("bottom").ticks(5);

  var yAxis = d3.svg.axis().scale(y)
      .orient("left").ticks(5);

  // define the lines
  var passline = d3.svg.line()
      .x(function(d) { return x(d.date); })
      .y(function(d) { return y(d.passed); });
  var failline = d3.svg.line()
      .x(function(d) { return x(d.date); })
      .y(function(d) { return y(d.failed); });
  var errorline = d3.svg.line()
      .x(function(d) { return x(d.date); })
      .y(function(d) { return y(d.errored); });

  // append the svg obgect to the body of the page
  // appends a 'group' element to 'svg'
  // moves the 'group' element to the top left margin
  var svg = d3.select(destination)
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform",
            "translate(" + margin.left + "," + margin.top + ")");

  // format the data
  data.forEach(function(d) {
      d.date = parseDate(d.date);
      d.passed = +d.passed;
      d.failed = +d.failed;
      d.errored = +d.errored;
  });

  // Scale the range of the data
  x.domain(d3.extent(data, function(d) { return d.date; }));
  y.domain([0, 100]);

  // Add the valueline path.
  svg.append("path")
      .data([data])
      .attr("class", "pass-line")
      .attr("d", passline);
  svg.append("path")
      .data([data])
      .attr("class", "fail-line")
      .attr("d", failline);
  svg.append("path")
      .data([data])
      .attr("class", "error-line")
      .attr("d", errorline);

  // Add the X Axis
  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

  // Add the Y Axis
  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis);
}
