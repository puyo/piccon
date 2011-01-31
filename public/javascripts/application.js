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

    self.options.pixelWidth = self.width*self.scale;
    self.options.pixelHeight = self.height*self.scale;
    self.options.brushCol = "black";

    self.options.element.attr('width', self.options.pixelWidth).attr('height', self.options.pixelWidth);
    var context = self.options.element[0].getContext('2d');
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

    self.drawBrush = function(targetContext, data, tx, ty, col) {
      targetContext.fillStyle = col;

      tx = Math.floor(tx);
      ty = Math.floor(ty);
      var w = 8, h = 8;
      for (var y = 0; y < h; ++y) {
        for (var x = 0; x < w; ++x) {
          if (data[y*w + x] === 1) {
            targetContext.fillRect((tx + x - w/2 - 1)*drawing.scale, (ty + y - h/2 - 1)*drawing.scale, drawing.scale, drawing.scale);
          }
        }
      }
      // debugging:
      //targetContext.fillStyle = 'red';
      //targetContext.fillRect(tx*scale, ty*scale, 1, 1);
    }

    function setLastPos(event) {
      lastX = Math.floor(event.offsetX / scale);
      lastY = Math.floor(event.offsetY / scale);
    }

    function draw(event) {
      if (down) {
        var x = Math.floor(event.offsetX / scale);
        var y = Math.floor(event.offsetY / scale);
        if (x >= canvasLength) x = canvasLength - 1;
        if (y >= canvasLength) y = canvasLength - 1;
        if (lastX === null)
          lastX = x;
        if (lastY === null)
          lastY = y;
        bresenham(lastX, lastY, x, y, function(i, j) { drawing.drawBrush(context, brush, i, j, brushCol); });
        lastX = x;
        lastY = y;
      }
    }
    self.options.element.mousedown(function(event){
      //console.log('mouse down', event);
      down = true;
      setLastPos(event);
      draw(event);
      return false;
    }).mouseup(function(event){
      //console.log('mouse up', event);
      down = false;
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
      brush = pixelBrush;
    });
    $('button.black').click(function(){
      brushCol = "black";
    });
    $('button.white').click(function(){
      brushCol = "white";
    });
    $('button.circle.small').click(function(){
      brush = circleBrush;
    });
    $('button.circle.large').click(function(){
      brush = largeCircleBrush;
    });
    $('button.square.large').click(function(){
      brush = largeSquareBrush;
    });
    $('button.black.clear').click(function(){
      context.fillStyle = "black";
      context.fillRect(0, 0, width, height);
    });
    $('button.white.clear').click(function(){
      context.fillStyle = "white";
      context.fillRect(0, 0, width, height);
    });

    // icons on buttons
    $('.brush').html("<canvas width="+8*self.options.scale+" height="+8*self.options.scale+"></canvas>");
    self.drawBrush($('.brush.black.circle.small canvas')[0].getContext('2d'), self._brushes.circle, 5, 5, "black");
    self.drawBrush($('.brush.black.circle.large canvas')[0].getContext('2d'), self._brushes.largeCircle, 5, 5, "black");
    self.drawBrush($('.brush.white.circle.large canvas')[0].getContext('2d'), self._brushes.largeCircleBrush, 5, 5, "white");
    self.drawBrush($('.brush.white.circle.small canvas')[0].getContext('2d'), self._brushes.circleBrush, 5, 5, "white");
    self.drawBrush($('.brush.white.square.large canvas')[0].getContext('2d'), self._brushes.largeSquareBrush, 5, 5, "white");
    self.drawBrush($('.brush.black.square.large canvas')[0].getContext('2d'), self._brushes.largeSquareBrush, 5, 5, "black");
    self.drawBrush($('.brush.white.pixel canvas')[0].getContext('2d'), self._brushes.pixelBrush, 5, 5, "white");
    self.drawBrush($('.brush.black.pixel canvas')[0].getContext('2d'), self._brushes.pixelBrush, 5, 5, "black");
  };

})(jQuery, document);

$(document).ready(function(){
  var d = new Drawing({ domElem: $('#drawarea'), scale: 3, width: 128, height: 128 });
});
