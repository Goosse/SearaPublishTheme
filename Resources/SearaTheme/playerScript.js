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
var streamFullTime = 0 //in seconds
var scrubUpdater
stream.volume = 0.5;


function toggleLiveStream(playButton){
    if (stream.paused){
        addClass(playButton.id, "playing");
        //  stream.load();
        stream.play();
    }
    else{
        removeClass(playButton.id, "playing");
        stream.pause();
    }
}

function toggleStream(playButton){
    if (stream.paused){
        playStream(playButton.id)
    }
    else{
        pauseStream(playButton.id)
    }
}
function playStream(buttonId){
    addClass(buttonId, "playing");
    //  stream.load();
    stream.play();
    scrubUpdater = window.setInterval(updateScrubber, 1000);
}

function pauseStream(buttonId){
    removeClass(buttonId, "playing");
    stream.pause();
    clearInterval(scrubUpdater) 
}

function playEpisode(audioUrl, title, time){
    removeClass("bar-player-wrapper", "closed");
    var player = document.getElementById("player")
    var playerTitle = document.getElementById("bar-player-title")
    var totalTime = document.getElementById("total-time")

    player.getElementsByTagName('source')[0].setAttribute('src', audioUrl)
    playerTitle.innerHTML = title
    var formattedTime = new Date(time * 1000).toISOString().substr(11, 8)
    if (formattedTime.substr(0,2) == "00") {
        formattedTime = formattedTime.substr(3, formattedTime.length - 3)
    }
    totalTime.innerHTML = formattedTime
    streamFullTime = time
    stream.load();
    playStream("bar-play-button")
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
    button.parentElement.parentElement.classList.add("hidden");
}

function closePlayer(button){
    button.parentElement.classList.add("closed");
    pauseStream("bar-play-button");
}


function addClass(id, newclass){
    document.getElementById(id).classList.add(newclass);
}

function removeClass(id, oldclass){
    document.getElementById(id).classList.remove(oldclass);
}

/*Begin scrubber slider code*/
//const scrubberWrapper = document.getElementById("scrubber");
const scrubberActiveRange = document.getElementById("scrubber-active-range");
const scrubberContainer = document.getElementById("scrubber-slider");
const scrubberHandle = document.getElementById("scrubber-handle");
const scrubberHandleDiameter = scrubberHandle.getBoundingClientRect().width - 2; 

function updateScrubber(){
    var scrubberRect = scrubberContainer.getBoundingClientRect();  //We set this everytime because it can change depending on episode title length.
    let x = stream.currentTime / streamFullTime * (scrubberRect.width - scrubberHandleDiameter) + scrubberHandleDiameter
    scrubberActiveRange.style.width = x + "px"
    displayFormattedCurrentTime(stream.currentTime)
}

function displayFormattedCurrentTime(seconds){
    
    var currentTime = document.getElementById("current-time")
    var formattedTime = new Date(seconds * 1000).toISOString().substr(11, 8)
    if (formattedTime.substr(0,2) == "00") {
        formattedTime = formattedTime.substr(3, formattedTime.length - 3)
    }
    currentTime.innerHTML = formattedTime
}

//var scrubberRect = scrubberContainer.getBoundingClientRect();

var scrubberMouseIsDown = false;

window.addEventListener("mouseup", scrubberUp);
scrubberContainer.addEventListener("mousedown", scrubberDown);
scrubberContainer.addEventListener("mousedown", scrubberSlide);
scrubberContainer.addEventListener("mousemove", scrubberSlide);
window.addEventListener("mousemove", scrubberSlide);

function scrubberDown() {
    scrubberMouseIsDown = true;
}

function scrubberUp() {
    scrubberMouseIsDown = false;
}

function scrubberSlide(event) {
    if (scrubberMouseIsDown) {
        var scrubberRect = scrubberContainer.getBoundingClientRect();  //We set this everytime because it can change depending on episode title length.
        console.log("scrubberRect: " + scrubberRect.left)
        console.log("event.clientX: " + event.clientX)
        let x = Math.floor(event.clientX - scrubberRect.left + scrubberHandleDiameter/2);
        console.log("x start:" + x)
        if (x < scrubberHandleDiameter) x = scrubberHandleDiameter; // check if it's too far left
        if (x > scrubberRect.width) x = scrubberRect.width; // check if it's too far right
        scrubberActiveRange.style.width = x + 'px';
        stream.currentTime = Math.floor((x -  scrubberHandleDiameter)/(scrubberRect.width - scrubberHandleDiameter)* streamFullTime)
       // scrubberActiveRange.style.width = "calc("+ (stream.currentTime/streamFullTime*100) + "% + " + scrubberHandleDiameter/2 + "px)"
        displayFormattedCurrentTime(stream.currentTime)
        console.log("x:" + x)
        console.log("currentTime: " + stream.currentTime)
    }
}

/*End scrubber slider code*/

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
    if (mouseIsDown || scrubberMouseIsDown){
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
        if (volumeWrapper.classList.contains("horizontal") && document.body.clientWidth >= 768){            
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


