// 移動前にアラート出す
window.addEventListener('beforeunload', (event) => {
    event.preventDefault();
    event.returnValue = '';
});

// 変更フラグのイベント追加
var tastingForms = document.querySelectorAll(".tasting-form");
for(var i = 0,len = tastingForms.length; i < len; ++i){
  tastingForms[i].addEventListener('change', function(){
        let tastingForm = this;
        let formNo = tastingForm.id.replace("form-", "");
        let flag = document.getElementById('flag-' + formNo);

        tastingForm.classList.add("border-primary");
        flag.checked = true;
    })
}

// コメント選択時のイベント追加
var list = document.querySelectorAll(".comment-word");
for(var i = 0,len = list.length; i < len; ++i){
    list[i].addEventListener('click', function(){
        let commentBox = document.getElementById('selected-comment');
        let selectedComment = commentBox.value;
        let str = this.innerText + ',';

        if (this.classList.contains('active') == false) {
            if (selectedComment.indexOf(str) == -1){
                selectedComment += str;
                commentBox.value = selectedComment;
            }
        }
        else {
          selectedComment = selectedComment.replace(str, '');
          commentBox.value = selectedComment;
        }
    })
}

// 利き酒結果のリセット関数
function radioReset(no) {
    const sampleId = document.getElementById('id-' + no).value;
    const result = window.confirm('サンプルID: ' + sampleId + ' の結果をリセットします。');
    
    if (result === true) {
        for (const e of document.getElementsByName('score-' + no)) {
            e.checked = false;
        }
        document.getElementById('comment-' + no).value = null;
    }
};

// モーダル表示時に実行
$('#selectComment').on('show.bs.modal', function (event) {
    const button = $(event.relatedTarget);
    const no = button.data('whatever');

    const sampleId = document.getElementById('id-' + no).value;
    let activeComment = document.getElementById('comment-' + no).value;

    activeComment = activeComment.replace('、', ',');
    activeComment = activeComment.replace(' ', ',');
    activeComment = activeComment.replace(' ', ',');
    if (activeComment.length !== 0 & activeComment.slice(-1) !==',') {
      activeComment += ',';
    }

    document.getElementById('active-id').value = sampleId;
    document.getElementById('selected-comment').value = activeComment;
    document.getElementById('active-no').value = no;

    const buttons = document.querySelectorAll('.comment-word');
    for (var i = 0,len = buttons.length; i < len; ++i) {
        buttons[i].classList.remove('active');
    }
});

// コメント追加関数
function setSelectedComment() {
    const selectComment = document.getElementById('selected-comment').value;

    const activeNo = document.getElementById('active-no').value;
    const comment = document.getElementById('comment-' + activeNo);
    const form = document.getElementById('form-' + activeNo);
    const flag = document.getElementById('flag-' + activeNo);

    comment.value = selectComment;
    form.classList.add("border-primary");
    flag.checked = true;
};

// 利き酒結果の取得
function getResult() {
    let tastingResult = '';
    
    for (let i = 1; i < document.forms.length; i++) {
        var radios = document.getElementsByName('score-' + i);
        var flag = document.getElementById('flag-' + i);

        var score = null;
        for (var no = 0; no < radios.length; no++) {
            if (radios[no].checked === true) {
                var score = radios[no].value;
                break;
            }
        }
        if (flag.checked === true) {
            tastingResult += '_i' + document.getElementById('id-' + i).value;
            tastingResult += 's' + score;
            if (document.getElementById('comment-' + i).value.length !== 0) {
                tastingResult += 'c' + document.getElementById('comment-' + i).value;
            }
        }
    }
    return tastingResult;
};

// 利き酒結果よりQRを作成
function qrCreate() {
    let qrData = getResult();

    if (qrData == '') {
        alert('結果がありません！');
    }
    else {
        const qrImgId = 'qrimg';
        document.getElementById('qrimg').innerHTML = '';
        
        for(var i = 1,len = 3; i < len; ++i) {

            const qrText = Encoding.convert(qrData, 'SJIS');
            $('#' + qrImgId).qrcode({
                width: 500,
                height: 500,
                text: qrText
              });
            
            var canvases = document.querySelectorAll('#' + qrImgId + ' canvas');
            
            for (var i = 0,cnt = canvases.length; i < cnt; ++i) {
                canvases[i].id = 'qr-' + (i + 1);
                canvases[i].style.display = 'none';
            }
        }
        canvases[0].style.display = 'block';

        // document.querySelector('#qr-' + qrNo + 'canvas').style.width = 'min(100%, 500px)';
        document.getElementById('forms').style.display = 'none';
        document.getElementById('finish-button').style.display = 'none';
        document.getElementById('qr').style.display = 'block';
        document.getElementById('fix-button').style.display = 'block';
    }
};

// 利き酒結果の修正
function fixResult() {
    document.getElementById('forms').style.display = 'block';
    document.getElementById('finish-button').style.display = 'block';
    document.getElementById('qr').style.display = 'none';
    document.getElementById('fix-button').style.display = 'none';
};