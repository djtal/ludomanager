var RemotePieChart = Class.create({
  initialize: function(elm, url, readyCallback){
    if (!$(elm) || url == "") return;
    if (!readyCallback)
      readyCallback = K();
    new Ajax.Request(url, {method: "get", onSuccess: function(response){
      this.chart = new Proto.Chart(elm, response.responseJSON,
      	{pies: {show: true, radius: 80, autoScale: false}, legend: {show: true, noColumns: 3, container:"chart-legend"}});
      readyCallback(this.chart);
    }});
  },
  
})


var RemoteBreakdownPlayChart = Class.create({
  initialize: function(elm, url){
    if (!$(elm) || url == "") return;
    this.wrapper = $(elm);
    this.dataUrl = url;
    game_id = this.wrapper.select("#game_id").first().innerHTML;
    new Ajax.Request(this.dataUrl, {parameters: {game_id: game_id},
                                    method: "get", onSuccess: this.loadChart.bind(this),
                                    onFailure: this.displayError.bind(this)});
  },
  
  loadChart: function(response){
      data = response.responseJSON
      this.chart = new Proto.Chart( this.wrapper,
                                    data,
                                    { bars: {show: true},
                                      xaxis: {'min': 1, 'max': 12, 'tickSize': 1},
                                      yaxis: {min: 0, 'tickSize': 1},
                                      legend: {show: true}});
  },
  
  displayError: function(methsArgs){
      alert("error")
  },
})

var ACGamePage = Class.create({
  initialize: function(){
    this.targetChart = new RemotePieChart("ac_games_piechart", "/account_games/group.json", this.colorizeLabel.bind(this)); 
  },
  
  colorizeLabel: function(chart){
    labels = chart.getLabels();
    labels.each(function(label){
      css = label.label.toLowerCase().gsub(/\s+/, "_");
      $$("strong.#{target}".interpolate({target: css })).invoke("writeAttribute", {style: "color: #{color};".interpolate({color: label.color})});
      
    })
  },
})

document.observe("dom:loaded", function() {
  new ACGamePage();
  new RemotePieChart("parties_piechart", "/parties/group.json");
  new RemoteBreakdownPlayChart("breakdown-play", "/parties/breakdown.json")
  
})