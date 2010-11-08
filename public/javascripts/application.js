/*
function raphael_canvas() {
  var canvas_length = 128;
  var pixel_size = 4;
  var paper = Raphael("canvas", pixel_size*canvas_length, pixel_size*canvas_length);
  var white = "#ccc";
  var black = "#444";
  var down = false;
  var set = paper.set();
  var current_color = black;

  function draw(node){
    if (down) {
      node.attr({fill: current_color});
    }
  }

  for (var y = 0; y != canvas_length; ++y) {
    for (var x = 0; x != canvas_length; ++x) {
      var c = paper.rect(x*pixel_size, y*pixel_size, pixel_size, pixel_size).attr({fill: white, stroke: "none"});
      $(c.node).mousedown(function(){
        console.log('down');
        down = true;
        draw(this);
      });
      $(c.node).mouseup(function(){
        console.log('up');
        down = false;
      });
      c.mouseover(function(event){
        draw(this);
      });
      set.push(c);
    }
  }
}
*/

function canvas_canvas() {
  var canvas = document.getElementById('canvas');
  if (!canvas) return;

  var scale = 4;
  var canvas_length = 128;
  var width = scale*canvas_length;
  var height = scale*canvas_length;

  $(canvas).attr('width', canvas_length).attr('height', canvas_length);
  var ctx = canvas.getContext('2d');
  ctx.strokeStyle = "rgb(0,0,0)";
  ctx.strokeWidth = "1px";

  var render = document.getElementById('render');
  $(render).attr('width', width).attr('height', height);
  rctx = render.getContext('2d');
  rctx.drawImage(canvas, 0, 0, canvas_length, canvas_length, 0, 0, width, height);

  var col = [0, 0, 0];
  var down = false;
  var last_x = null;
  var last_y = null;

  function set_last_pos(event) {
    last_x = event.offsetX / scale;
    last_y = event.offsetY / scale;
  }

  function draw(event) {
    if (down) {
      var x = event.offsetX / scale;
      var y = event.offsetY / scale;
      if (x >= canvas_length) x = canvas_length - 1;
      if (y >= canvas_length) y = canvas_length - 1;
      if (last_x === null)
        last_x = x;
      if (last_y === null)
        last_y = y;
      ctx.moveTo(last_x, last_y);
      ctx.lineTo(x, y);
      ctx.stroke();
      last_x = x;
      last_y = y;
      rctx.clearRect(0, 0, width, height);
      rctx.drawImage(canvas, 0, 0, canvas_length, canvas_length, 0, 0, width, height);
    }
  }
  
  $(render).mousedown(function(event){
    console.log('mouse down', event);
    down = true;
    set_last_pos(event);
    draw(event);
    return false;
  }).mouseup(function(event){
    //console.log('mouse up', event);
    down = false;
  }).mouseenter(function(event){
    //console.log('mouse enter', event);
    set_last_pos(event);
    draw(event);
  }).mouseleave(function(event){
    //console.log('mouse leave', event);
    draw(event);
  }).mousemove(function(event){
    //console.log('mouse move', event);
    draw(event);
  });
}

$(document).ready(function(){
  canvas_canvas();
});
