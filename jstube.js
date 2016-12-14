// tube downloader
// Respects: https://github.com/NFicano/pytube

function Tube(opt_url) {
    this.filename_ = "";
    this.video_url_ = "";
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
};
