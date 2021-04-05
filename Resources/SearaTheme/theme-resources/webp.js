const imagemin = require('imagemin'),
      webp = require('imagemin-webp'),
      pngToJpeg = require('png-to-jpeg');
const outputFolder = './'
const produceWebP = async () => {
    await imagemin(['./*.png'], {
        destination: outputFolder,
        plugins: [
            webp({
                quality: 100
            })
        ]
    })
    console.log('PNGs processed')
//    await imagemin(['./*.{jpg,jpeg}'], {
//        destination: outputFolder,
//        plugins: [
//            webp({
//                quality: 65
//            })
//        ]
//    })
//    console.log('JPGs and JPEGs processed')
}
produceWebP()