if (!navigator.mediaDevices) {
    document.querySelector('#js-unsupported').classList.add('is-show')
}

const video  = document.querySelector('#js-video')
const canvas = document.querySelector('#js-canvas')
const ctx    = canvas.getContext('2d')

const checkImage = () => {
    // �擾���Ă��铮���Canvas�ɕ`��
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height)

    // Canvas����f�[�^���擾
    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)

    // isQR�ɓn��
    const code = jsQR(imageData.data, canvas.width, canvas.height)

    // QR�R�[�h�̓ǂݎ��ɐ��������烂�[�_�����J��
    // ���s������ēx���s
    if (code) {
        openModal(code.data)
    } else {
        setTimeout(() => { checkImage() }, 200)
    }
}

const openModal = function(url) {
    document.querySelector('#js-result').innerText = url
    document.querySelector('#js-link').setAttribute('href', url)
    document.querySelector('#js-modal').classList.add('is-show')
}

document.querySelector('#js-modal-close')
    .addEventListener('click', () => {
        document.querySelector('#js-modal').classList.remove('is-show')
        checkImage()
    })

navigator.mediaDevices
    .getUserMedia({
         audio: false,
         video: {
             facingMode: {
                exact: 'environment'
                }
           }
    })
    .then(function(stream) {
        video.srcObject = stream
        video.onloadedmetadata = function(e) {
            video.play()
            checkImage()
        }
    })
    .catch(function(err) {
        alert('Error!!')
    })