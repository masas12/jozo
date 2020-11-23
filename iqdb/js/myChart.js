
// 2) CSVから２次元配列に変換
function csv2Array(str) {
  var csvData = [];
  var lines = str.split("\n");
  for (var i = 0; i < lines.length; ++i) {
    var cells = lines[i].split(",");
    csvData.push(cells);
  }
  return csvData;
}

function drawChartKoji(data) {
  // 3)chart.jsのdataset用の配列を用意
  var tmpLabels = [], tmpData1 = [], tmpData2 = [], tmpData3 = [],
      tmpData4 = [], tmpData5 = [], tmpData6 = [], tmpData7 = [],
      tmpData8 = [], tmpData9 = [], tmpData10 = [], tmpData11 = [],
      tmpData12 = [], tmpData13 = [], tmpData14 = [];
  for (var row in data) {
    tmpLabels.push(data[row][0])
    tmpData1.push(data[row][1])
    tmpData2.push(data[row][2])
    tmpData3.push(data[row][3])
    tmpData4.push(data[row][4])
    tmpData5.push(data[row][5])
    tmpData6.push(data[row][6])
    tmpData7.push(data[row][7])
    tmpData8.push(data[row][8])
    tmpData9.push(data[row][9])
    tmpData10.push(data[row][10])
    tmpData11.push(data[row][11])
    tmpData12.push(data[row][12])
    tmpData13.push(data[row][13])
    tmpData14.push(data[row][14])
  };

  // 4)chart.jsで描画
  var ctx = document.getElementById("myChart").getContext("2d");
  ctx.canvas.height = 400;
  var myChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: tmpLabels,
      datasets: [
        { type:'line', label: "平均品温", yAxisID: "y1", data: tmpData8, fill: false, borderWidth: 3,pointBorderWidth: 1, pointRadius: 0},
        { type:'line', label: "設定品温", yAxisID: "y1", data: tmpData1, fill: false, borderWidth: 3,pointBorderWidth: 1, pointRadius: 0},
        // { type:'line', label: "実測品温1", yAxisID: "y1", data: tmpData2, fill: false, pointRadius: 0},
        // { type:'line', label: "実測品温2", yAxisID: "y1", data: tmpData3, fill: false, pointRadius: 0},
        // { type:'line', label: "実測品温3", yAxisID: "y1", data: tmpData4, fill: false, pointRadius: 0},
        // { type:'line', label: "実測品温4", yAxisID: "y1", data: tmpData5, fill: false, pointRadius: 0},
        // { type:'line', label: "実測品温5", yAxisID: "y1", data: tmpData6, fill: false, pointRadius: 0},
        // { type:'line', label: "実測品温6", yAxisID: "y1", data: tmpData7, fill: false, pointRadius: 0},
        { type:'line', label: "平均室温", yAxisID: "y1", data: tmpData14, fill: false, borderWidth: 3,pointBorderWidth: 1, pointRadius: 0},
        { type:'line', label: "設定室温", yAxisID: "y1", data: tmpData11, fill: false, borderWidth: 3,pointBorderWidth: 1, pointRadius: 0},
        // { type:'line', label: "実測室温1", yAxisID: "y1", data: tmpData12, fill: false, pointRadius: 0},
        // { type:'line', label: "実測室温2", yAxisID: "y1", data: tmpData13, fill: false, pointRadius: 0},
        { type:'line', label: "実測湿度", yAxisID: "y2", data: tmpData10, fill: false, borderWidth: 3,pointBorderWidth: 1, pointRadius: 0},
        { type:'line', label: "設定湿度", yAxisID: "y2", data: tmpData9, fill: false, borderWidth: 3,pointBorderWidth: 1, pointRadius: 0}
      ]
    },
    options: {
            plugins: {
              colorschemes: {
                scheme: 'tableau.Tableau20'
              }
            },
            responsive: true,
            maintainAspectRatio: false,
            stepSize: 1,
            callback: function(value, index, values){
              return  value +  '℃'
            },
            scales: {
              //Y軸のオプション
              yAxes: [{
                  id: "y1",
                  scaleLabel: {
                      fontColor: "black"
                  },
                  gridLines: {
                      color: "rgba(126, 126, 126, 0.4)",
                      zeroLineColor: "black"
                  },
                  ticks: {
                      fontColor: "black",
                      beginAtZero: true,
                      max: 50,
                      min: 20,
                      stepSize: 5,
                      callback: function(value, index, values){
                        return  value +  '℃'
                      }
                  }
              },
              {
                  id: "y2",
                  position: "right",
                  autoSkip: true,
                  gridLines: {
                      display: false
                  },
                  ticks: {
                      fontColor: "black",
                      beginAtZero: true,
                      max: 100,
                      stepSize: 20,
                      callback: function(val) {
                          return val + '%';
                      }
                  }
              }]
            }
        }
    });
  }

function drawChartMoromi(data) {
  // 3)chart.jsのdataset用の配列を用意
  var tmpLabels = [], tmpData1 = [], tmpData2 = [], tmpData3 = [];
  for (var row in data) {
    tmpLabels.push(data[row][0])
    tmpData1.push(data[row][1])
    tmpData2.push(data[row][2])
    tmpData3.push(data[row][3])
  };

  // 4)chart.jsで描画
  var ctx = document.getElementById("myChart").getContext("2d");
  ctx.canvas.height = 400;
  var myChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: tmpLabels,
      datasets: [
        { label: "設定温度", data: tmpData1, fill: false, borderWidth: 2,pointBorderWidth: 1, pointRadius: 0},
        { label: "実測値（上）", data: tmpData2, fill: false, borderWidth: 2,pointBorderWidth: 1, pointRadius: 0},
        { label: "実測値（下）", data: tmpData3, fill: false, borderWidth: 2,pointBorderWidth: 1, pointRadius: 0}
      ]
    },
    options: {
            responsive: true,
            maintainAspectRatio: false,
            stepSize: 1,
            callback: function(value, index, values){
              return  value +  '℃'
            },
            plugins: {
              colorschemes: {
                scheme: 'tableau.Tableau20'
              }
            }
          }
  });
}

function main(path) {
  // 1) ajaxでCSVファイルをロード
  var req = new XMLHttpRequest();
  var filePath = path;
  req.open("GET", filePath, true);
  
  req.onload = function() {
    // 2) CSVデータ変換の呼び出し
    data = csv2Array(req.responseText);

    // 3) chart.jsデータ準備、4) chart.js描画の呼び出し
    if(filePath.indexOf( 'koji' ) !== -1) {
      drawChartKoji(data);
    }else if(filePath.indexOf( 'moromi' ) !== -1) {
      drawChartMoromi(data);
    }

    try {      
      if(this.status != 200) {
        alert('該当のデータがありません。');  
        main('http://srv-160/Gekkeikan/Jozo/data/moromi/ginjo/dummy.csv') ; 
      }
    } catch (e) {
      alert(e.message);
    }
  }
  req.send(null);
}