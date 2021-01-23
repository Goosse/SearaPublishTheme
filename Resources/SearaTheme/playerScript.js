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
stream.volume = 0.5;

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

function shareUrl(url, title){
    var dialog = document.getElementById("share-dialog")
    var fb = document.getElementById("fb-share")
    var wa = document.getElementById("wa-share")
    var twitter = document.getElementById("twitter-share")
    var email = document.getElementById("email-share")
    var titleSpan = document.getElementById("share-title")
    
    fb.href = "https://www.facebook.com/sharer/sharer.php?u=" + encodeURI(url)
    wa.href = "whatsapp://send?text=" + url
    twitter.href = "https://twitter.com/intent/tweet?text=" + encodeURI(url)
    email.href = "mailto:?subject=Veja%20o%20que%20eu%20descrobi!&body=" + url
    titleSpan.innerHTML = title
    
    dialog.classList.remove("hidden")
}


function closeDialog(button){
    console.log(button);
    button.parentElement.parentElement.classList.add("hidden");
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
const handleDiameter = handle.getBoundingClientRect().width - 2; 



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
            let x = Math.floor(event.clientX - rect.left + handleDiameter/2);
            if (x < handleDiameter) x = handleDiameter; // check if it's too low
            if (x > volumeRangeWidth) x = volumeRangeWidth; // check if it's too high
            volumeActiveRange.style.width = x + 'px';
            stream.volume = (x - handleDiameter)/(volumeRangeWidth - handleDiameter)
        }
        else{   
            let y = Math.floor(event.clientY - rect.top - handleDiameter/2);
            if (y < 0) y = 0; // check if it's too low
            if (y > volumeRangeHeight - handleDiameter) y = volumeRangeHeight - handleDiameter; // check if it's too high
            volumeActiveRange.style.height = volumeRangeHeight - y + 'px';
            stream.volume = (volumeRangeHeight - y - handleDiameter)/(volumeRangeHeight - handleDiameter)
        }
    }
}
/*End volume slider code*/


