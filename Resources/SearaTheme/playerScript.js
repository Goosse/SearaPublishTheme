var es = new EventSource('https://api.radioseara.fm/updates/current-song-stream');

es.onmessage = function (event) {
    console.log("on message: " + event.data)
};

es.addEventListener('new-song', function (event) {
    console.log(event.data)
    var parsedData = JSON.parse(event.data)
    console.log(parsedData)
    //    document.getElementById("artist").innerHTML = parsedData.artist ? parsedData.artist : ""
    //    document.getElementById("live-track-title").innerHTML = parsedData.title ? parsedData.title : ""
    document.getElementById("live-track-title").innerHTML = parsedData.title ? parsedData.title : ""
    document.getElementById("live-track-artist").innerHTML = parsedData.artist ? parsedData.artist : ""

    // document.getElementById("artwork").setAttribute("src", parsedData.artwork ? 'http://localhost:3000/' + parsedData.artwork : "/recursos/missingArtwork.jpg")
    // document.getElementById("lyrics").innerHTML = parsedData.lyrics ? parsedData.lyrics : ""
});

var stream = document.getElementById("player");

function toggleStream(){
    if (stream.paused){
        playStream()
    }
    else{
        pauseStream()
    }
}

function playStream(){
    addClass("live-play-button", "playing");
    stream.load();
    stream.play();
}

function pauseStream(){
    removeClass("live-play-button", "playing");
    stream.pause();
}

function addClass(id, newclass){
    document.getElementById(id).classList.add(newclass);
}

function removeClass(id, oldclass){
    document.getElementById(id).classList.remove(oldclass);
}

/*Begin volume slider code*/

const volumeWrapper = document.getElementById("volume");
const volumeActiveRange = document.getElementById("volume-active-range");
const volumeContainer = document.getElementById("volume-slider");
const handle = document.getElementById("volume-handle");
const handleWidth = handle.getBoundingClientRect().width - 2; 


const volumeRangeWidth = volumeContainer.getBoundingClientRect().width; 
const volumeRangeHeight = volumeContainer.getBoundingClientRect().height;
var rect = volumeContainer.getBoundingClientRect();

let mouseIsDown = false;

window.addEventListener("mouseup", up);
volumeContainer.addEventListener("mousedown", down);
volumeContainer.addEventListener("mousedown", volumeSlide);
volumeContainer.addEventListener("mousemove", volumeSlide);
window.addEventListener("mousemove", volumeSlide);
document.onselectstart = () => {
  if (mouseIsDown){
        return false;// cancel selection
    } 
};

function down() {
    mouseIsDown = true;
}

function up() {
    mouseIsDown = false;
}

function volumeSlide(event) {
    if (mouseIsDown) {
        if (volumeWrapper.classList.contains("horizontal")){            
            let x = Math.floor(event.clientX - rect.left + handleWidth/2);
            if (x < handleWidth) x = handleWidth; // check if it's too low
            if (x > volumeRangeWidth) x = volumeRangeWidth; // check if it's too high
            volumeActiveRange.style.width = x + 'px';
        }
        else{   
            let y = Math.floor(event.clientY - rect.top - handleWidth/2);
            if (y < 0) y = 0; // check if it's too low
            if (y > volumeRangeHeight - handleWidth) y = volumeRangeHeight - handleWidth; // check if it's too high
            volumeActiveRange.style.height = volumeRangeHeight - y + 'px';
        }
    }
}
/*End volume slider code*/


