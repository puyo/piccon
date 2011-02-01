(function($, document, undefined){

  var bresenham = function(x0, y0, x1, y1, callback) {
    var t;
    var steep = Math.abs(y1 - y0) > Math.abs(x1 - x0);
    if (steep) {
      x0 ^= y0; y0 ^= x0; x0 ^= y0; // swap x0 and y0
      x1 ^= y1; y1 ^= x1; x1 ^= y1; // swap x1 and y1
    }
    if (x0 > x1) {
      x0 ^= x1; x1 ^= x0; x0 ^= x1; // swap x0 and x1
      y0 ^= y1; y1 ^= y0; y0 ^= y1; // swap y0 and y1
    }
    var dx = x1 - x0;
    var dy = Math.abs(y1 - y0);
    var error = -(dx + 1) / 2;
    var yi;
    if (y0 < y1) {
      yi = 1;
    } else {
      yi = -1;
    }
    for (; x0 <= x1; x0++) {
      if (steep) {
        callback(y0, x0);
      } else {
        callback(x0, y0);
      }
      error += dy;
      if (error >= 0) {
        y0 += yi;
        error -= dx;
      }
    }
  };

  Drawing = function(args) {
    var self = this;

    var defaults = {
      selector: '#drawing',
      scale: 3,
      width: 128,
      height: 128,
    };

    self.options = $.extend({}, defaults, args || {});

    self.options.element = $(self.options.selector);
    if (!self.options.element) return;

    self.options.pixelWidth = self.options.width*self.options.scale;
    self.options.pixelHeight = self.options.height*self.options.scale;
    self.options.brushCol = "black";

    self.options.element.attr('width', self.options.pixelWidth).attr('height', self.options.pixelWidth);
    self._context = self.options.element[0].getContext('2d');
    //context.drawImage(self.domElem, 0, 0, self.pixelWidth, self.pixelHeight, 0, 0, width, height);

    self._brushes = {
      pixel: [
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,1,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
      ],
      circle: [
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,1,1,0,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,0,1,1,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
      ],
      largeCircle: [
        0,0,0,1,1,0,0,0,
        0,1,1,1,1,1,1,0,
        0,1,1,1,1,1,1,0,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        0,1,1,1,1,1,1,0,
        0,1,1,1,1,1,1,0,
        0,0,0,1,1,0,0,0,
      ],
      largeSquare: [
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
      ],
    };

    self._brush = self._brushes.pixel;
    self._down = false;
    self._lastX = null;
    self._lastY = null;
    self._brushWidth = 8;
    self._brushHeight = 8;

    self.drawBrush = function(targetContext, data, tx, ty, col) {
      targetContext.fillStyle = col;

      tx = Math.floor(tx);
      ty = Math.floor(ty);
      for (var y = 0; y < self._brushHeight; ++y) {
        for (var x = 0; x < self._brushWidth; ++x) {
          if (data[y*self._brushWidth + x] === 1) {
            var drawX = (tx + x - self._brushWidth/2 - 1)*self.options.scale;
            var drawY = (ty + y - self._brushHeight/2 - 1)*self.options.scale;
            targetContext.fillRect(drawX, drawY, self.options.scale, self.options.scale);
          }
        }
      }
      // debugging:
      //targetContext.fillStyle = 'red';
      //targetContext.fillRect(tx*scale, ty*scale, 1, 1);
    }

    function setLastPos(event) {
      lastX = Math.floor(event.offsetX / self.options.scale);
      lastY = Math.floor(event.offsetY / self.options.scale);
    }

    function draw(event) {
      if (self._down) {
        var x = Math.floor(event.offsetX / self.options.scale);
        var y = Math.floor(event.offsetY / self.options.scale);
        if (x >= self.width) x = self.width - 1;
        if (y >= self.height) y = self.height - 1;
        if (lastX === null)
          lastX = x;
        if (lastY === null)
          lastY = y;
        bresenham(lastX, lastY, x, y, function(i, j) { self.drawBrush(self._context, self._brush, i, j, self.options.brushCol); });
        lastX = x;
        lastY = y;
      }
    }
    self.options.element.mousedown(function(event){
      //console.log('mouse down', event);
      self._down = true;
      setLastPos(event);
      draw(event);
      return false;
    }).mouseup(function(event){
      //console.log('mouse up', event);
      self._down = false;
    }).mouseenter(function(event){
      //console.log('mouse enter', event);
      setLastPos(event);
      draw(event);
    }).mouseleave(function(event){
      //console.log('mouse leave', event);
      draw(event);
    }).mousemove(function(event){
      //console.log('mouse move', event);
      draw(event);
    });

    $('button.pixel').click(function(){
      self._brush = self._brushes.pixel;
    });
    $('button.black').click(function(){
      self.options.brushCol = "black";
    });
    $('button.white').click(function(){
      self.options.brushCol = "white";
    });
    $('button.circle.small').click(function(){
      self._brush = self._brushes.circle;
    });
    $('button.circle.large').click(function(){
      self._brush = self._brushes.largeCircle;
    });
    $('button.square.large').click(function(){
      self._brush = self._brushes.largeSquare;
    });
    $('button.black.clear').click(function(){
      self._context.fillStyle = "black";
      self._context.fillRect(0, 0, self.options.pixelWidth, self.options.pixelHeight);
    });
    $('button.white.clear').click(function(){
      self._context.fillStyle = "white";
      self._context.fillRect(0, 0, self.options.pixelWidth, self.options.pixelHeight);
    });

    // icons on buttons
    $('.brush').html("<canvas width="+self._brushWidth*self.options.scale+" height="+self._brushHeight*self.options.scale+"></canvas>");
    self.drawBrush($('.brush.black.circle.small canvas')[0].getContext('2d'), self._brushes.circle, 5, 5, "black");
    self.drawBrush($('.brush.black.circle.large canvas')[0].getContext('2d'), self._brushes.largeCircle, 5, 5, "black");
    self.drawBrush($('.brush.white.circle.large canvas')[0].getContext('2d'), self._brushes.largeCircle, 5, 5, "white");
    self.drawBrush($('.brush.white.circle.small canvas')[0].getContext('2d'), self._brushes.circle, 5, 5, "white");
    self.drawBrush($('.brush.white.square.large canvas')[0].getContext('2d'), self._brushes.largeSquare, 5, 5, "white");
    self.drawBrush($('.brush.black.square.large canvas')[0].getContext('2d'), self._brushes.largeSquare, 5, 5, "black");
    self.drawBrush($('.brush.white.pixel canvas')[0].getContext('2d'), self._brushes.pixel, 5, 5, "white");
    self.drawBrush($('.brush.black.pixel canvas')[0].getContext('2d'), self._brushes.pixel, 5, 5, "black");
  };

})(jQuery, document);

$(document).ready(function(){
  var d = new Drawing({ domElem: $('#drawarea'), scale: 3, width: 128, height: 128 });
});
