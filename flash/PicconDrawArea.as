package {
	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;

	public class PicconDrawArea extends Sprite {

		private var _canvas:Bitmap;
		private var _canvasData:BitmapData;
		private var _canvasSprite:Sprite; 
		private var _drawingOn:Boolean;
		private var _lastX:int;
		private var _lastY:int;
		private var _controls:Controls;
		private var	_whitePointButton:BrushButton;
		private var	_blackPointButton:BrushButton;
		private var	_whiteCircleButton:BrushButton;
		private var	_blackCircleButton:BrushButton;
		private var	_whiteSquareButton:BrushButton;
		private var	_blackSquareButton:BrushButton;
		private var	_whiteBigCircleButton:BrushButton;
		private var	_blackBigCircleButton:BrushButton;
		private var	_whiteSprayButton:BrushButton;
		private var	_blackSprayButton:BrushButton;
		private var	_buttons:Array;
		private var	_buttonsRow1:Array;
		private var	_buttonsRow2:Array;
		private var _controlsBackground:Shape;
		private var	_brush:Bitmap;

		private static var SCALE:int = 4;

		public function PicconDrawArea() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			_canvasData = new BitmapData(128, 128, false, 0xffffffff);
			_canvas = new Bitmap(_canvasData);

			_canvasSprite = new Sprite();
			_canvasSprite.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_canvasSprite.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			_canvasSprite.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			_canvasSprite.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_canvasSprite.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			_canvasSprite.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			_canvasSprite.addChild(_canvas);
			_canvasSprite.scaleX = SCALE;
			_canvasSprite.scaleY = SCALE;

			initExternalInterface();

			function mouseDownHandler(event:MouseEvent):void {
				//mylog("mouseDownHandler");
				if (event.shiftKey) { // Line tool.
					drawLine(_lastX, _lastY, event.localX, event.localY, 0x000000);
				}
				// Mouse button is down. Flag drawing on.
				setDrawingOn(true, event);
				drawAt(event.localX, event.localY);
			}

			function mouseMoveHandler(event:MouseEvent):void {
				if (_drawingOn) {
					var localX:int = int(event.localX);
					var localY:int = int(event.localY);
					if (localX != _lastX || localY != _lastY){
						drawLine(_lastX, _lastY, localX, localY, 0x000000);
						//mylog("line", _lastX, _lastY, "==>", localX, localY);
						_lastX = localX;
						_lastY = localY;
					}
				}
			}

			function mouseOutHandler(event:MouseEvent):void {
				//mylog("mouseOutHandler", event.localX, event.localY);
				setDrawingOn(false, event);
			}

			function mouseOverHandler(event:MouseEvent):void {
				//mylog("mouseOverHandler");
				//Check if we are still drawing when the mouse re-enters the stage
				setDrawingOn(event.buttonDown, event);
			}

			function mouseWheelHandler(event:MouseEvent):void {
				//mylog("mouseWheelHandler delta: " + event.delta);
			}

			function mouseUpHandler(event:MouseEvent):void {
				//mylog("mouseUpHandler");
				//Mouse button is up. Flag drawing off.
				setDrawingOn(false, event);
			}

			var transparentOn:Boolean = true;
			var transparentCol:uint = 0x00000000;

			var whitePointBrush:Bitmap = new Bitmap(new BitmapData(8, 8, transparentOn, transparentCol));
			whitePointBrush.bitmapData.setPixel32(3, 3, 0xffffffff);

			var blackPointBrush:Bitmap = new Bitmap(new BitmapData(8, 8, transparentOn, transparentCol));
			blackPointBrush.bitmapData.setPixel32(3, 3, 0xff000000);

			var whiteCircleBrush:Bitmap = new Bitmap(new BitmapData(8, 8, transparentOn, transparentCol));
			with(whiteCircleBrush){
				drawCircle(bitmapData, 0xffffffff);
			}

			var blackCircleBrush:Bitmap = new Bitmap(new BitmapData(8, 8, transparentOn, transparentCol));
			with(blackCircleBrush){
				drawCircle(bitmapData, 0xff000000);
			}

			var whiteSquareBrush:Bitmap = new Bitmap(new BitmapData(8, 8, transparentOn, transparentCol));
			with(whiteSquareBrush){
				bitmapData.fillRect(new Rectangle(0, 0, 8, 8), 0xffffffff);
			}
			var blackSquareBrush:Bitmap = new Bitmap(new BitmapData(8, 8, transparentOn, transparentCol));
			with(blackSquareBrush){
				bitmapData.fillRect(new Rectangle(0, 0, 8, 8), 0xff000000);
			}

			var whiteBigCircleBrush:Bitmap = new Bitmap(new BitmapData(8, 8, transparentOn, transparentCol));
			with(whiteBigCircleBrush){
				drawBigCircle(bitmapData, 0xffffffff);
			}

			var blackBigCircleBrush:Bitmap = new Bitmap(new BitmapData(8, 8, transparentOn, transparentCol));
			with(blackBigCircleBrush){
				drawBigCircle(bitmapData, 0xff000000);
			}

			var whiteSprayBrush:Bitmap = new Bitmap(new BitmapData(8, 8, transparentOn, transparentCol));
			with(whiteSprayBrush){
				drawSpray(bitmapData, 0xffffffff);
			}

			var blackSprayBrush:Bitmap = new Bitmap(new BitmapData(8, 8, transparentOn, transparentCol));
			with(blackSprayBrush){
				drawSpray(bitmapData, 0xff000000);
			}

			function drawSpray(bitmapData:BitmapData, col:int):void{
				bitmapData.setPixel32(0, 1, col);
				bitmapData.setPixel32(1, 5, col);
				bitmapData.setPixel32(2, 2, col);
				bitmapData.setPixel32(3, 7, col);
				bitmapData.setPixel32(5, 4, col);
				bitmapData.setPixel32(6, 0, col);
				bitmapData.setPixel32(7, 6, col);
			}

			function drawCircle(bitmapData:BitmapData, col:int):void{
				bitmapData.setPixel32(2, 3, col);
				bitmapData.setPixel32(2, 4, col);

				bitmapData.setPixel32(3, 2, col);
				bitmapData.setPixel32(3, 3, col);
				bitmapData.setPixel32(3, 4, col);
				bitmapData.setPixel32(3, 5, col);

				bitmapData.setPixel32(4, 2, col);
				bitmapData.setPixel32(4, 3, col);
				bitmapData.setPixel32(4, 4, col);
				bitmapData.setPixel32(4, 5, col);

				bitmapData.setPixel32(5, 3, col);
				bitmapData.setPixel32(5, 4, col);
			}

			function drawBigCircle(bitmapData:BitmapData, col:int):void{
				bitmapData.setPixel32(0, 3, col);
				bitmapData.setPixel32(0, 4, col);

				bitmapData.setPixel32(1, 1, col);
				bitmapData.setPixel32(1, 2, col);
				bitmapData.setPixel32(1, 3, col);
				bitmapData.setPixel32(1, 4, col);
				bitmapData.setPixel32(1, 5, col);
				bitmapData.setPixel32(1, 6, col);

				bitmapData.setPixel32(2, 1, col);
				bitmapData.setPixel32(2, 2, col);
				bitmapData.setPixel32(2, 3, col);
				bitmapData.setPixel32(2, 4, col);
				bitmapData.setPixel32(2, 5, col);
				bitmapData.setPixel32(2, 6, col);

				bitmapData.setPixel32(3, 0, col);
				bitmapData.setPixel32(3, 1, col);
				bitmapData.setPixel32(3, 2, col);
				bitmapData.setPixel32(3, 3, col);
				bitmapData.setPixel32(3, 4, col);
				bitmapData.setPixel32(3, 5, col);
				bitmapData.setPixel32(3, 6, col);
				bitmapData.setPixel32(3, 7, col);

				bitmapData.setPixel32(4, 0, col);
				bitmapData.setPixel32(4, 1, col);
				bitmapData.setPixel32(4, 2, col);
				bitmapData.setPixel32(4, 3, col);
				bitmapData.setPixel32(4, 4, col);
				bitmapData.setPixel32(4, 5, col);
				bitmapData.setPixel32(4, 6, col);
				bitmapData.setPixel32(4, 7, col);

				bitmapData.setPixel32(5, 1, col);
				bitmapData.setPixel32(5, 2, col);
				bitmapData.setPixel32(5, 3, col);
				bitmapData.setPixel32(5, 4, col);
				bitmapData.setPixel32(5, 5, col);
				bitmapData.setPixel32(5, 6, col);

				bitmapData.setPixel32(6, 1, col);
				bitmapData.setPixel32(6, 2, col);
				bitmapData.setPixel32(6, 3, col);
				bitmapData.setPixel32(6, 4, col);
				bitmapData.setPixel32(6, 5, col);
				bitmapData.setPixel32(6, 6, col);

				bitmapData.setPixel32(7, 3, col);
				bitmapData.setPixel32(7, 4, col);
			}

			_whitePointButton = new BrushButton(whitePointBrush);
			_blackPointButton = new BrushButton(blackPointBrush);
			_whiteCircleButton = new BrushButton(whiteCircleBrush);
			_blackCircleButton = new BrushButton(blackCircleBrush);
			_whiteSquareButton = new BrushButton(whiteSquareBrush);
			_blackSquareButton = new BrushButton(blackSquareBrush);
			_whiteBigCircleButton = new BrushButton(whiteBigCircleBrush);
			_blackBigCircleButton = new BrushButton(blackBigCircleBrush);
			_whiteSprayButton = new BrushButton(whiteSprayBrush);
			_blackSprayButton = new BrushButton(blackSprayBrush);

			_buttons = [
				_whitePointButton,
				_blackPointButton,
				_whiteCircleButton,
				_blackCircleButton,
				_whiteSquareButton,
				_blackSquareButton,
				_whiteBigCircleButton,
				_blackBigCircleButton,
				_whiteSprayButton,
				_blackSprayButton,
				];
			_buttonsRow1 = [
				_blackPointButton,
				_blackCircleButton,
				_blackSquareButton,
				_blackBigCircleButton,
				_blackSprayButton,
				];
			_buttonsRow2 = [
				_whitePointButton,
				_whiteCircleButton,
				_whiteSquareButton,
				_whiteBigCircleButton,
				_whiteSprayButton,
				];

			for each (var but:BrushButton in _buttons) {
				but.addEventListener(MouseEvent.CLICK, handleButtonClick);
			}

			function handleButtonClick(event:MouseEvent):void {
				var clicked:BrushButton = event.target as BrushButton;
				//mylog("handleButtonClick");
				_brush = clicked.brush;
				for each (var b:BrushButton in _buttons) {
					if (b != clicked) {
						b.turnOff();
					}else {
						b.turnOn();
					}
				}
			}

			// Set default brush
			_blackPointButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));

			_controlsBackground = new Shape();
			_controlsBackground.graphics.beginFill(0x5d7cba);
			_controlsBackground.graphics.drawRect(0, 0, 1, 1);
			_controlsBackground.graphics.endFill();

			_controls = new Controls();
			_controls.addChild(_controlsBackground);
			for each (var b:BrushButton in _buttons) {
				_controls.addChild(b);
			}

			addChild(_canvasSprite);
			addChild(_controls);

			stage.addEventListener("resize", handleResize);
			arrange();

			function handleResize(event:Event):void {
				arrange();
			}
		} // constructor

		private function initExternalInterface():void {
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("getImageData", getImageData);
				ExternalInterface.addCallback("setImageData", setImageData);
				ExternalInterface.call("drawAreaReady");
			}
			function getImageData():String {
				var result:String = "";
				var pixel:uint;
				var j:int;
				var i:int;
				for(j = 0; j < _canvasData.height; j++) {
					for(i = 0; i < _canvasData.width; i++) {
						pixel = _canvasData.getPixel(i, j);
						result += (pixel != 0 ? "1" : "0");
					}
				}
				return result;
			}
			function setImageData(data:String):void {
				//mylog("setImageData", data);
				var index:uint = 0;
				var j:int;
				var i:int;
				var white:uint = 16777215;
				for(j = 0; j < _canvasData.height; j++) {
					for(i = 0; i < _canvasData.width; i++) {
						if (index >= data.length) {
							_canvasData.setPixel(i, j, white);
						} else if (data.charAt(index) == "0") {
							_canvasData.setPixel(i, j, 0);
						} else {
							_canvasData.setPixel(i, j, white);
						}
						++index;
					}
				}
			}
		}

		public function mylog(...args):void {
			ExternalInterface.call.apply(ExternalInterface, ["console.log"].concat(args));
		}

		private function arrange():void {
			//mylog("arrange", stage.width, stage.height);

			var canvasWidth:uint = 512;
			var canvasHeight:uint = 512;
			var controlsWidth:uint = 128;
			var controlsHeight:uint = canvasHeight;

			_controlsBackground.width = controlsWidth;
			_controlsBackground.height = controlsHeight;

			_controls.x = canvasHeight;
			_controls.y = 0;

			// controls

			var i:int = 0;
			var b:BrushButton;
			for each (b in _buttonsRow1) {
				b.x = 10;
				b.y = 10 + i * (b.width + 10);
				i++;
			}
			i = 0;
			for each (b in _buttonsRow2) {
				b.x = 10 + b.height + 10;
				b.y = 10 + i * (b.width + 10);
				i++;
			}
		}

		private function draw():void {
			//mylog("draw");
		}

		private function mouseDraw(event:MouseEvent):void {
		}

		private function setDrawingOn(on:Boolean, event:MouseEvent):void{
			if (on) {
				_lastX = event.localX;
				_lastY = event.localY;
			}
			_drawingOn = on;
		}

		// Bresenham algorithm translated from
		// http://en.wikipedia.org/wiki/Bresenham's_line_algorithm
		private function drawLine(x0:int, y0:int, x1:int, y1:int, colour:int):void {
			var t:int;
			var steep:Boolean = Math.abs(y1 - y0) > Math.abs(x1 - x0);
			if(steep) {
				x0 ^= y0; y0 ^= x0; x0 ^= y0; // swap x0 and y0
				x1 ^= y1; y1 ^= x1; x1 ^= y1; // swap x1 and y1
			}
			if (x0 > x1) {
				x0 ^= x1; x1 ^= x0; x0 ^= x1; // swap x0 and x1
				y0 ^= y1; y1 ^= y0; y0 ^= y1; // swap y0 and y1
			}
			var dx:int = x1 - x0;
			var dy:int = Math.abs(y1 - y0);
			var error:int = -(dx + 1) / 2;
			var yi:int;
			if (y0 < y1) {
				yi = 1;
			} else {
				yi = -1;
			}
			for(; x0 <= x1; x0++) {
				if (steep) {
					drawAt(y0, x0);
				} else {
					drawAt(x0, y0);
				}
				error += dy;
				if(error >= 0) {
					y0 += yi;
					error -= dx;
				}
			}
		}

		private function drawAt(x0:int, y0:int):void {
			if (_brush) {
				_canvasData.copyPixels(_brush.bitmapData, _brush.bitmapData.rect, new Point(x0 - 3, y0 - 3));
			}
		}

	} // class
}

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.text.*;

class Controls extends Sprite {
	function Controls() {
	}
}

class DynButton extends Sprite {

	protected var _on:Boolean;
	protected var _width:uint;
	protected var _height:uint;

	function DynButton() {
		_width = 46;
		_height = 46;
		useHandCursor = true;
		buttonMode = true;
		redraw();
	}

	public function redraw():void {
		var fillType:String = GradientType.LINEAR;
		var colors:Array = [0x8b9bba, 0x5d7cba];
		var alphas:Array = [1, 1];
		var ratios:Array = [0x00, 0xFF];
		var matr:Matrix = new Matrix();
		matr.createGradientBox(_width, _height, Math.PI/2, 0, 0);
		var spreadMethod:String = SpreadMethod.PAD;

		graphics.clear();
		if (_on) {
			graphics.lineStyle(4, 0xff9000);
		} else {
			graphics.lineStyle(2, 0x000061);
		}
		graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
		//graphics.beginFill(0xff0000);
		graphics.drawRoundRect(0, 0, _width, _height, 10, 10);
		graphics.endFill();
	}
}

class SendButton extends DynButton {

	function SendButton() {
		mouseChildren = false;
		_width = 60;
		_height = 95;

		var format:TextFormat = new TextFormat();
		format.font = "Helvetica";
		format.color = 0xffffff;
		format.size = 16;
		format.bold = true;
		format.align = TextFormatAlign.CENTER;

		var label:TextField = new TextField();
		label.background = false;
		label.border = false;
		label.text = "Send";
		label.setTextFormat(format);
		label.width = _width - 10;
		label.height = 20;

		label.x = (_width - (_width - 10))/2;
		label.y = (_height - label.height)/2;

		var bm:Bitmap = new Bitmap();

		addChild(label);

		redraw();
	}

	public function turnOn():void {
		_on = true;
		redraw();
	}
}

class BrushButton extends DynButton {
	private var _brush:Bitmap;

	function BrushButton(brush:Bitmap) {
		_brush = brush;
		_brush.scaleX = 4;
		_brush.scaleY = 4;
		_brush.x = (uint)(_width - _brush.width)/2;
		_brush.y = (uint)(_height - _brush.height)/2;
		addChild(_brush);
	}

	public function turnOn():void {
		_on = true;
		redraw();
	}

	public function turnOff():void {
		_on = false;
		redraw();
	}

	public function get brush():Bitmap {
		return _brush;
	}
}
