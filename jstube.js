// tube downloader
// Respects: https://github.com/NFicano/pytube

function Tube(opt_url) {
  this.filename_ = "";
  this.video_url_ = "";
  this.title_ = "";
  this.videos_ = [];
  if(opt_url)
	  this.from_url_(opt_url);
};

Tube.prototype.url = function() {
    return this.video_url_;
};

Tube.prototype.url = function(url) {
    this.from_url_(url);
};

Tube.prototype.from_url_ = function(url) {
  this.vide_url = url;
  this.filename_ = "";
  this.videos_ = [];

  var video_data = this.get_video_data_();
};

Tube.prototype.get_video_data_ = function() {
  this.title_ = "";
  var url = this.url();
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
    if(this.readyState == 4) {
      if(xhr.status == 200) {
        // success
      } else {
        console.error("failed");
      }
    } else {
      console.error("cannot open " + url);
    }
  };
  xhr.open('GET', url, true);
  xhr.send(null);
};
