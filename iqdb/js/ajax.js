//品質データの取得(data_search_ajax.aspを呼び出す)
function getData(){
    var data = '';
    var datas = document.forms.conditions;
    data = data + 'license=';
    var cnt = 0;
    for (let i = 0; i < datas.license.length; i++) {
        if (datas.license[i].checked === true) {
            cnt++;
            if (cnt != 1) {
                data = data + '_';
            }
            data = data + datas.license[i].value;
        }
    }
    var sampleDate = datas.sample_date.value.replace(/\s+/g, '');
    sampleDate = sampleDate.replace(/-/g, '');
    sampleDate = sampleDate.replace(/to/, '_');
    data = data + '&';
    data = data + 'sample_date=' + sampleDate + '&';
    data = data + 'lot=' + datas.lot_number.value.replace(/\s+/g, '') + '&';
    data = data + 'material_code=' + datas.material_code.value.replace(/\s+/g, '') + '&';
    data = data + 'process_code=' + datas.process_code.value + '&';
    data = data + 'record_count=' + datas.record_count.value;
    console.log(data);
    var url = encodeURI('data_search_ajax.asp?' + data);
    xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.send();
    xhr.onreadystatechange = getDataCallBack;
}

// XMLの要素を返す
function getDataCallBack(){
    if (xhr.readyState == 4) {
        if (xhr.status == 200) {
            if (xhr.responseText == 'No Record') {
                alert('該当するデータがありません')
            }else{
            var target = document.getElementById('results');
            target.innerHTML = xhr.responseText;
            var conditions = document.getElementById('conditions');
            conditions.checked = false;
            }
        }
    }
}

function getTemperatureData(){
    alert('作成中')

    
}