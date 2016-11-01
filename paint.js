function Color(r, g, b, opt_a) {
    this.r = r;
    this.g = g;
    this.b = b;
    if(opt_a) this.a = opt_a;
}

Color.fromArray = function(arr) {
    return arr[3] ? new Color(arr[0], arr[1], arr[2], arr[3])
	: new Color(arr[0], arr[1], arr[2]);
};

Color.eq = function(c1, c2) {
    return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b;
};

Color.prototype.toString = function() {
    return this.a ? "rgba(" + this.r + "," + this.g + "," + this.b + "," + this.a + ")"
	: "rgb(" + this.r + "," + this.g + "," + this.b + ")";
};

CanvasEdit.prototype.WIDTH = 400;
CanvasEdit.prototype.HEIGHT = 300;

function CanvasEdit(canvas1, canvas2) {
    this.canvas = canvas1;
    this.context = canvas1.getContext("2d");
    this.width = CanvasEdit.prototype.WIDTH;
    this.height = CanvasEdit.prototype.HEIGHT;
    this.grid = { w: 40, h: 30 };
    this.mas_size = { w: this.width / this.grid.w, h: this.height / this.grid.h };
    this.selectedColor = null;
    this.colors = [new Color(255, 127, 80), new Color(255, 165, 0),
		   new Color(127, 255, 212), new Color(138, 43, 226),
		   new Color(175, 238, 238), new Color(60, 179, 113),
		   new Color(255, 0, 0), new Color(174, 71, 88)];
    this.init();
    this.dropper = new Dropper(canvas2, this.colors, this.width,
			       CanvasEdit.prototype.select.bind(this));
}

CanvasEdit.prototype.init = function() {
    this.canvas.width = this.width;
    this.canvas.height = this.height;
    var handlerBounding = CanvasEdit.prototype.handler.bind(this);
    this.canvas.addEventListener('click', handlerBounding, false);
    this.fillRandomly();
};

CanvasEdit.prototype.fillRect = function(color, x, y, w, h) {
    this.context.beginPath();
    this.context.fillStyle = color.toString();
    this.context.fillRect(x, y, w, h);
};

CanvasEdit.prototype.fillRectij = function(color, i, j) {
    this.fillRect(color, this.mas_size.w * j, this.mas_size.h * i,
		  this.mas_size.w, this.mas_size.h);
};

CanvasEdit.prototype.fillRandomly = function() {
    for(var i = 0; i < this.grid.h; i++) {
	for(var j = 0; j < this.grid.w; j++) {
	    var rand = Math.floor(Math.random() * this.colors.length);
	    var color = this.colors[rand];
	    this.fillRectij(color, i, j);
	}
    }
};

CanvasEdit.prototype.select = function(color) {
    this.selectedColor = color;
};

CanvasEdit.prototype.handler = function(event) {
    if(!this.selectedColor) return;
    var x = event.layerX;
    var y = event.layerY;

    var i = j = 0;
    while(this.mas_size.w * j <= x) j++;
    while(this.mas_size.h * i <= y) i++;
    j--;
    i--;
    this.paintFill(this.selectedColor, i, j);
};

CanvasEdit.prototype.paintFill = function(color, si, sj) {
    var checked = new Array(this.grid.h);
    for(var x = 0; x < this.grid.h; x++) {
	checked[x] = new Array(this.grid.w);
    }
    function recur(i, j) {
	if(i < 0 || this.grid.h <= i ||
	   j < 0 || this.grid.w <= j || checked[i][j]) return;
	checked[i][j] = true;
	var c = this.getColor(i, j);
	if(!Color.eq (color, c)) {
	    this.fillRectij(color, i, j);
	    return;
	}
	setTimeout(function() {
	    recur.call(this, i - 1, j);
	    recur.call(this, i, j - 1);
	    recur.call(this, i + 1, j);
	    recur.call(this, i, j + 1);
	}.bind(this), 100);
    }
    recur.call(this, si, sj);
};

CanvasEdit.prototype.getColor = function(i, j) {
    var imagedata = this.context.getImageData(
	this.mas_size.w * j, this.mas_size.h * i, 1, 1);
    var rgb = Array.prototype.slice.call(imagedata.data, 0, -1);
    return Color.fromArray(rgb);
};

Dropper.prototype.SPAN = 20;
Dropper.prototype.HEIGHT = 100;

function Dropper(canvas, colors, width, setter) {
    this.canvas = canvas;
    canvas.width = width;
    canvas.height = Dropper.prototype.HEIGHT;

    this.context = canvas.getContext("2d");
    this.colors = colors;
    this.setter = setter;
    this.span = Dropper.prototype.SPAN;
    this.selectedIndex = -1;

    var w = (width - this.span * (colors.length + 1)) / colors.length;
    var h = Dropper.prototype.HEIGHT - this.span * 2;
    this.mas_size = { w: w, h: h };
    
    this.init();
}

Dropper.prototype.init = function() {
    var handlerBounding = Dropper.prototype.handler.bind(this);
    this.canvas.addEventListener('click', handlerBounding, false);
    this.clear();
};

Dropper.prototype.clear = function() {
    this.fillRect(Dropper.prototype.OFF, 0, 0,
		  this.canvas.width, this.canvas.height);
    var x = y = this.span;
    for(var j = 0; j < this.colors.length; j++) {
	this.fillRect(this.colors[j], x, y, this.mas_size.w, this.mas_size.h);
	x += this.mas_size.w + this.span;
    }
};

Dropper.prototype.fillRect = function(color, x, y, w, h) {
    this.context.beginPath();
    this.context.fillStyle = color.toString();
    this.context.fillRect(x, y, w, h);
};

Dropper.prototype.ON = new Color(0, 0, 0);
Dropper.prototype.OFF = new Color(255, 255, 255);

Dropper.prototype.rect = function(on, x, y, w, h) {
    var color = on ? Dropper.prototype.ON : Dropper.prototype.OFF;
    this.context.beginPath();
    this.context.strokeStyle = color.toString();
    this.context.rect(x, y, w, h);
    this.context.stroke();
};

Dropper.prototype.select = function(index) {
    if(this.selectedIndex == index) return; 
    if(this.selectedIndex != -1) {
	this.clear();
    }
    var x = this.span + (this.span + this.mas_size.w) * index;
    this.rect(true, x, this.span, this.mas_size.w, this.mas_size.h);
    this.selectedIndex = index;
};

Dropper.prototype.handler = function(event) {
    var x = event.layerX;
    var y = event.layerY;
    var w = j = 0;

    if(y < this.span || this.span + this.mas_size.h < y) return;
    while(w <= x) {
	if(x < w + this.span) return; 
	w += this.span + this.mas_size.w;
	j++;
    }
    j--;
    this.select(j);
    this.setter(this.colors[j]);
};

window.onload = function() {
    var main = document.querySelector("#main");
    main.style.width = CanvasEdit.prototype.WIDTH + 'px';
    var canvas1 = document.createElement("canvas");
    var canvas2 = document.createElement("canvas");
    main.appendChild(canvas1);
    main.appendChild(canvas2);
    var edit = new CanvasEdit(canvas1, canvas2);
};
