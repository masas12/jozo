var header = document.getElementById('header');
var modal = document.getElementById('modal');
var btn = document.getElementsByClassName('plus');
var selected = document.getElementById('selected-comment');
var defaultBtn = document.getElementById('default-btn');
var totalList = document.getElementById('total');
var aromaList = document.getElementById('aroma');
var tasteList = document.getElementById('taste');
var trendList = document.getElementById('trend');
var historyList = document.getElementById('history');

window.addEventListener('click', function(e) {
    if (e.target == modal) {
        header.style.display = 'flex';
        modal.style.display = 'none';
    }
  });

function modalReset() {
    var obj = document.getElementsByTagName('li');
    for(var i in obj) {
        if(obj[i].className === 'comment-word') {
            obj[i].style.color = 'var(--submenu-color)'
            obj[i].style.backgroundColor = 'var(--submenu-back-color)';
        }
    }    
    totalList.style.zIndex = '100'
    selected.value = '';
    defaultBtn.checked = true;
}

function modalShow(i) { 
    modalReset();
    var sampleId = document.getElementById('sample-id' + i);
    var selectedId = document.getElementById('selected-id');

    selectedId.value = sampleId.value;

    if(modal.style.display === 'none' || modal.style.display === '') { 
        header.style.display = 'none';
        modal.style.display = 'block';
    }else
    {
        header.style.display = 'flex'; 
        modal.style.display = 'none';    
    }    
}

function modalClose() { 
    header.style.display = 'flex'; 
    modal.style.display = 'none';    
}

function modalCommit() { 
    var sampleId = document.getElementById('selected-id').value;
    var pushComment = document.getElementById('selected-comment').value;

    var obj = document.getElementsByClassName('sample-id');
    for(var i in obj) {
        if(obj[i].value === sampleId) {
            var no = obj[i].id.slice(9);
        }
    } 
    
    var commentInput = document.getElementById('comment' + no);
    commentInput.value = pushComment + commentInput.value;
    modalClose();
}

function changeList(group) {
    var activeList = document.getElementById(group);

    totalList.style.zIndex = '10'
    aromaList.style.zIndex = '10'
    tasteList.style.zIndex = '10'
    trendList.style.zIndex = '10'
    historyList.style.zIndex = '10'
    activeList.style.zIndex = '100'
}

function commentPush(no, obj) {
    let commentBox = document.getElementById('selected-comment');
    let commentBoxText = commentBox.value;
    let ajustedText = commentBoxText.replace( / /g , ",");
    ajustedText = ajustedText.replace( /@/g , ",");
    ajustedText = ajustedText.replace( /A/g , ",");
    ajustedText = ajustedText.replace( /C/g , ",");
    if (ajustedText.slice(-1) !== ',') {
        ajustedText = ajustedText + ',';
    }

    if (! ajustedText) {
        commentBox.value = obj.innerText + ',';
        obj.style.color = '#ffffff';
        obj.style.backgroundColor = ' #e29930';
    }
    else if (ajustedText.indexOf(obj.innerText) === -1 ) {
        commentBox.value = commentBoxText + obj.innerText + ',';
        obj.style.color = '#ffffff';
        obj.style.backgroundColor = ' #e29930';
    }
    else {
        const regExp = new RegExp( obj.innerText + ',', "g" ) ;
        commentBox.value = commentBoxText.replace( regExp , "" );
        obj.style.color = '#211f30';
        obj.style.backgroundColor = '#e7f3fc';
    }
}