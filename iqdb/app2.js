const barcodeDetector = new BarcodeDetector();

// streamを入力するvideoを作成する
const image = document.createElement("video");

// 画像を加工するcanvasを作成する
const offscreen_canvas = document.createElement("canvas");
const offscreen_context = offscreen_canvas.getContext("2d");

// 最終的に取得した画像を表示するcanvasを取得する
const canvas = document.querySelector("#result");
const context = canvas.getContext("2d");

//カメラと中間処理のキャンバスのサイズを最終的に表示するキャンバスを基準に設定
offscreen_canvas.width = canvas.width;
image.videoWidth = canvas.width;
offscreen_canvas.height = canvas.height;
image.videoHeight = canvas.height;

//取得結果は使いまわすので、外で定義する
let code = null;

window.onload = async () => {
  //カメラを取得
  const stream = await navigator.mediaDevices.getUserMedia({
    video: {
      facingMode: { exact: "environment" },
    },
  });

  //オブジェクトと関連付ける
  image.srcObject = stream;
  image.play();

  //バーコードの解析処理自体の実行
  analysis();

  //解析結果をdomに書き出す処理の定期呼び出しを設定
  setInterval(() => {
    reflesh();
  }, 800);
};

const analysis = async () => {
  offscreen_context.drawImage(image, 0, 0);

  try {
    code = await barcodeDetector.detect(image);
  } catch {
    window.requestAnimationFrame(analysis);
    return;
  }

  let state = true;

  if (code == null) {
    state = false;
  }
  if (state == true && code.length == 0) {
    state = false;
  }

  //バーコードの値が取れていた場合、赤い線で囲む
  if (state) {
    offscreen_context.strokeStyle = "rgb(255, 0, 0) ";
    offscreen_context.lineWidth = 10;
    offscreen_context.beginPath(
      code[0].cornerPoints[0].x,
      code[0].cornerPoints[0].y
    );
    offscreen_context.lineTo(
      code[0].cornerPoints[1].x,
      code[0].cornerPoints[1].y
    );
    offscreen_context.lineTo(
      code[0].cornerPoints[2].x,
      code[0].cornerPoints[2].y
    );
    offscreen_context.lineTo(
      code[0].cornerPoints[3].x,
      code[0].cornerPoints[3].y
    );
    offscreen_context.lineTo(
      code[0].cornerPoints[0].x,
      code[0].cornerPoints[0].y
    );
    offscreen_context.closePath();
    offscreen_context.stroke();
  }
  context.drawImage(offscreen_canvas, 0, 0, canvas.width, canvas.height);
  window.requestAnimationFrame(analysis);
};

//結果を文字で書き出す
const reflesh = () => {
  $("#result_text").empty();
  if (code == null) {
    $("#result_text").text("ERROR");
    return;
  }
  if (code.length == 0) {
    $("#result_text").text("ERROR");
    return;
  }
  let resultText = "";
  for (const barcode of code) {
    resultText += `
    <ul>
      <li>rawValue = ${barcode.rawValue}</li> 
      <li>format = ${barcode.format}</li> 
      <li>width = ${barcode.boundingBox.width}</li>
      <li>height = ${barcode.boundingBox.height}</li>
      <li>x = ${barcode.boundingBox.x}</li>
      <li>y = ${barcode.boundingBox.y}</li>
    </ul>
    `;
  }

  $("#result_text").html(resultText);
};