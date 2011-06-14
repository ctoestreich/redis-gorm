<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <meta name="layout" content="dataTest"/>
  <title>Simple GSP page</title>
</head>

<body>

<div id="container" class="highcharts-container" style="height:410px; margin: 0 2em; clear:both; min-width: 600px"></div>

<p></p>

<div id="container2" class="highcharts-container" style="height:410px; margin: 0 2em; clear:both; min-width: 600px"></div>

<BR>

<script type="text/javascript">
  $(function() {
    $("#container").ajaxgraph({
                                redisUrl: '/redis-gorm/dataTest/makeRedis',
                                gormUrl: '/redis-gorm/dataTest/makeGorm',
                                title: 'Redis vs. Gorm (H2 mem) Save Time',
                                increment: 2, //multiple by this number every run for records to process
                                limit: 128000 //stop after this number
                              });

    $("#container2").ajaxgraph({
                                 redisUrl: '/redis-gorm/dataTest/getRedis',
                                 gormUrl: '/redis-gorm/dataTest/getGorm',
                                 title: 'Redis vs. Gorm (H2 mem) Read Time',
                                 increment: 2,
                                 limit: 256000
                               });
  });

  (function($) {
    $.widget('tgid.ajaxgraph', {
               options: {
                 redisUrl: '/redis-gorm/dataTest/makeRedis',
                 gormUrl: '/redis-gorm/dataTest/makeGorm',
                 title: 'No Title',
                 increment: 2,
                 limit: 1000000
               },
               _create: function() {
                 console.log("created ajaxgraph");
                 var self = this;
                 self.chart = null;
                 self.running = "true";
                 self.recordCount = 2;
                 self.limit = self.options.limit;
                 self.id = self.element.attr("id");
                 self._createButtons();
                 $.when(self._createChart()).then(self._processData());
               },
//               start: function() {
//                 var self = this, id = self.id;
//                 $("#" + id + "stop").show();
//                 $("#" + id + "start").hide();
//                 self.running = "true";
//                 this._processData();
//               },
//               stop: function() {
//                 console.log("stopping");
//                 var self = this, id = self.id;
//                 $("#" + id + "stop").hide();
//                 $("#" + id + "start").show();
//                 self.running = "false";
//                 console.log(self.running);
//               },
//               reset: function() {
//                 var self = this, id = self.id;
//                 self.recordCount = 2;
//                 $("#" + id + "stop").hide();
//                 $("#" + id + "start").attr("value", "Start").show();
//               },
               _processData: function() {
                 var self = this;
                 $.when($.ajax({
                                 method: "POST",
                                 dataType: "html",
                                 url: this.options.redisUrl,
                                 data: "recordCount=" + self.recordCount
                               }),
                        $.ajax({
                                 method: "POST",
                                 dataType: "html",
                                 url: this.options.gormUrl,
                                 data: "recordCount=" + self.recordCount
                               })
                 ).then(function(rData, gData) {
                          self.recordCount = Math.ceil(self.recordCount *= self.options.increment);
                          $("#" + self.id + "recordCount").html(self.recordCount);
                          var x = (new Date()).getTime();
                          self.chart.series[0].addPoint([x, parseInt(gData)], true, true);
                          self.chart.series[1].addPoint([x, parseInt(rData)], true, true);
//                          if(self.running) self._processData();
                          console.log(self.recordCount < self.options.limit);
                          (self.recordCount < self.options.limit) ? self._processData() : $("#" + self.id + "recordCount").prepend("<p align=\"center\">Limit Reached(" + self.options.limit + ")</p>");
                        }, self._failure)
               },
               _failure: function() {
                 var self = this;
                 self.recordCount *= 2;
                 self._processData();
               },
               _createButtons:function() {
                 var self = this, id = self.id;
//                 $("<p align=\"center\"><input id=\"" + id + "start\" type=\"button\" value=\"Start\"/><input style=\"display:none;\" id=\"" + id + "stop\" type=\"button\" value=\"Stop\"/>&nbsp;&nbsp;<input id=\"" + id + "reset\" type=\"button\" value=\"Reset\"/></p>").insertBefore(self.element);
                 $("<p align=\"center\"><span id=\"" + id + "recordCount\">0</span> records processed</p>").insertBefore(self.element);
                 $("#" + id + "start").bind("click", self.start);
                 $("#" + id + "stop").bind("click", self.stop).hide();
                 $("#" + id + "reset").bind("click", self.reset);
               },
               _createChart: function() {
                 var dfd = new jQuery.Deferred();
                 var self = this;
                 console.log(self.element.attr("id"));
                 self.chart = new Highcharts.Chart({
                                                     plotOptions: {
                                                       spline: {
                                                         marker: {
                                                           enabled: false
                                                         }
                                                       }
                                                     },
                                                     chart: {
                                                       renderTo: self.element.attr("id"),
                                                       defaultSeriesType: 'spline',
                                                       marginRight: 1
                                                     },
                                                     title: {
                                                       text:  self.options.title
                                                     },
                                                     xAxis: {
                                                       type: 'datetime',
                                                       tickPixelInterval: 150
                                                     },
                                                     yAxis: {
                                                       title: {
                                                         text: 'Save Time (ms)'
                                                       }
                                                     },
                                                     tooltip: {
                                                       formatter: function() {
                                                         return '<b>' + this.series.name + '</b><br/>' +
                                                                Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) + '<br/>' +
                                                                Highcharts.numberFormat(this.y, 0) + "ms";
                                                       }
                                                     },
                                                     legend: {
                                                       enabled: true
                                                     },
                                                     exporting: {
                                                       enabled: false
                                                     },
                                                     series: [
                                                       {
                                                         name: 'GORM',
                                                         data: (function() {
                                                           // generate an array of random data
                                                           var data = [],
                                                                   time = (new Date()).getTime(),
                                                                   i;
                                                           for(i = -3; i <= 0; i++) {
                                                             data.push({
                                                                         x: time + i * 1000,
                                                                         y: 0
                                                                       });
                                                           }
                                                           return data;
                                                         })()
                                                       },
                                                       {
                                                         name: 'Redis',
                                                         data: (function() {
                                                           // generate an array of random data
                                                           var data = [],
                                                                   time = (new Date()).getTime(),
                                                                   i;

                                                           for(i = -3; i <= 0; i++) {
                                                             data.push({
                                                                         x: time + i * 1000,
                                                                         y: 0
                                                                       });
                                                           }
                                                           console.log(data);
                                                           return data;
                                                         })()
                                                       }
                                                     ]
                                                   });
                 return dfd;
               }
             });
  })(jQuery);
</script>
</body>
</html>