const video = document.getElementById('player');
let videoTracks;
let localStream = null;
let captureTimer = null;
const fps = 10;
let medias = {
    video:
    {
        width: 500,
        height: 500,
        facingMode:
        { exact: "environment"}
    },
    audio: false
};

const qrArea = document.getElementById('qr-reader-area');
const playerArea = document.getElementById('player');
const startBtn = document.getElementById('qr-start-button');
const stopBtn = document.getElementById('qr-stop-button');

playerArea.style.display = "none";
startBtn.style.display = "block";
stopBtn.style.display = "none";

startBtn.onclick = function() {
    document.getElementById('rawValue').innerHTML = "";
    navigator.mediaDevices.getUserMedia(medias)
        .then(function(stream) {
            video.srcObject = stream;
            localStream = stream;

            if (window.BarcodeDetector) {
                const detector = new BarcodeDetector();
                captureTimer = setInterval(function(){
                    detector.detect(video)
                    .then(
                        function(barcodes) {
                            let barcode = null;
                            for (barcode of barcodes) {
                                console.log("value : " + barcode.rawValue);
                                console.log(barcode);
                                document.getElementById('rawValue').innerHTML = convertLink(barcode.rawValue);
                            }
                            if (barcode) {
                                stopVideo();
                                qrArea.style.display ="none"
                            }
                    })
                    .catch(function(err) {
                        console.log(err);
                    });
                }, 1000 / fps);
            }
            else {
                console.error('BarcodeDetection is not enable!');
            }
            playerArea.style.display = "block";
            startBtn.style.display = "none";
            stopBtn.style.display = "block";
        })
        .catch(function(err) {
            console.log(err);
            medias = {
                video:
                {
                    width: 500,
                    height: 500,
        facingMode:
        { exact: "environment"}
                },
                audio: false
            };
        });
    
};

function stopVideo() {
    clearInterval(captureTimer);
    localStream.getTracks().forEach(function(track) {
        track.stop();
    });
    localStream = null;
    video.srcObject = null;
    playerArea.style.display = "none";
    startBtn.style.display = "block";
    stopBtn.style.display = "none";
};

stopBtn.onclick = function() {
    stopVideo();
};

function convertLink(str) {
    const regexpUrl = /((h?)(ttps?:\/\/[a-zA-Z0-9.\-_@:/~?%&;=+#',()*!]+))/g; // ']))/;
    const regexpLink = function(all, url, h, href) {
        return '<a href="h' + href + '">' + url + '</a>';
    }
    
    return str.replace(regexpUrl, regexpLink);
};

// load時にstart状態にする
startBtn.click();
