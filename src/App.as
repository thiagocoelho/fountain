package
{
	import net.hires.debug.Stats;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;

	/**
	 * @author Thiago Coelho
	 */
	 
	[SWF(backgroundColor="#CCCCCC", frameRate="31", width="640", height="480")]

	public class App extends MovieClip
	{
		private var _circles:Array = new Array();
		private var _gravity:Number = 0.95;
		private var _count:int = 512;
		private var _friction:Number = 0.1;
		private var _bArray:ByteArray = new ByteArray();
		private var _channelLength:uint = 512;
		private var _sound:Sound;
		private var _played:Boolean = false;
		private var _bSprite:Sprite = new Sprite();
		
		private var _bPass:int;
		
		private var _scroller:scrollBar;

		public function App()
		{
			if (stage)
			{
				_init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, _init);
			}
		}

		private function _init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			addChild(new Stats());
			
			_createCircles();
			
			_sound = new Sound();
			
			_sound.addEventListener(ProgressEvent.PROGRESS, _buffer);
			_sound.addEventListener(Event.COMPLETE, _playSound);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, _ioError);
			
			_sound.load(new URLRequest("music.mp3"));
			
			addChild(_bSprite);
			
			_scroller = new scrollBar();
			_scroller.x = 200;
			_scroller.y = 200;
			addChild(_scroller);
			
			_scroller.track.addEventListener(MouseEvent.MOUSE_DOWN, _startTrack);
		}

		private function _startTrack(e:MouseEvent):void 
		{
			addEventListener(Event.ENTER_FRAME, _setCircles);
			stage.addEventListener(MouseEvent.MOUSE_UP, _stopDrag);
			_scroller.track.startDrag(false, new Rectangle(0, 0, _scroller.bar.width - _scroller.track.width, 0));
		}
		
		private var _currentCircle:int;

		private function _setCircles(event:Event):void 
		{
			var ratio:Number = _scroller.track.x / (_scroller.bar.width - _scroller.track.width);
			
			var circle:int = (ratio * (_circles.length-1));
			
			trace(circle, _circles.length);
			
			if (_circles[circle].visible && circle != _currentCircle)
			{
				_circles[circle].visible = false;
			}
			else if (circle != _currentCircle)
			{
				_circles[circle].visible = true;
			}
			
			_currentCircle = circle
		}

		private function _stopDrag(event:MouseEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, _setCircles);
			_scroller.track.stopDrag();
		}

		private function _createCircles():void
		{
			var color:uint = 0xFF0000;
			
			for (var i:int = 0;i < _count;i++)
			{
				color = (i >= _count/2) ? 0x000000 : 0xFF0000;
				
				_addCircles(color, 10, false);
				
				/*
				var circle:Circle = new Circle(10, false, color);
				
				circle.vx = - 10 + Math.random() * 20;
				circle.vy = 30;
				circle.weight = 5;
				
				circle.finalPos = Math.round((circle.vy / _gravity) * circle.vy);
				
				circle.x = stage.stageWidth / 2 - circle.width / 2;
				circle.y = stage.stageHeight - circle.height;
				
				circle.isLaunched = false;
				
				_circles.push(circle);
				
				addChild(circle);
				 */
			}
		}
		
		private function _addCircles(color:uint = 0xFFFFFF, radius:Number = 10, center:Boolean = false):void
		{
			var circle:Circle = new Circle(radius, center, color);
				
			circle.vx = - 10 + Math.random() * 20;
			circle.vy = 15;
			
			//circle.finalPos = Math.round((circle.vy / _gravity) * circle.vy);
			
			circle.x = stage.stageWidth / 2 - circle.width / 2;
			circle.y = stage.stageHeight / 2;
			
			circle.isLaunched = false;
			
			_circles.push(circle);
			
			addChild(circle);
			
			_bPass = _channelLength / _circles.length;
		}

		private function _buffer(e:ProgressEvent):void
		{
			_bSprite.y = stage.stageHeight / 2;
			
			var ratio:Number = e.bytesLoaded / e.bytesTotal;
			
			_bSprite.graphics.clear();
			_bSprite.graphics.lineStyle(1, 0xFF0000);
			_bSprite.graphics.lineTo(ratio * stage.stageWidth, 0);
			
			if (ratio > 0.1 && ! _played)
			{
				_played = true;
				_sound.play();
				stage.addEventListener(Event.ENTER_FRAME, _render);
			}
		}

		private function _playSound(e:Event):void
		{
			_bSprite.visible = false;
			_sound.removeEventListener(ProgressEvent.PROGRESS, _buffer);
			_sound.removeEventListener(Event.COMPLETE, _playSound);
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, _ioError);
		}

		private function _ioError(e:IOErrorEvent):void
		{
			trace(e);
		}

		private function _render(e:Event):void
		{
			var sh:Number = stage.stageHeight;
			var sw:Number = stage.stageWidth;
			
			SoundMixer.computeSpectrum(_bArray, false, 0);
			
			var rFloat:Number = 0;
			
			for each(var circle:Circle in _circles)
			{
				for (var i:int = 0; i < _bPass; i++)
				{
					//realtime
					rFloat = _bArray.readFloat();
				}
				
				//lastvalue
				
				var circleWidth:Number = circle.width;
				var circleHeight:Number = circle.height;
				
				var speed:Number = Math.sqrt(circle.vx * circle.vx + circle.vy * circle.vy);
				var angle:Number = Math.atan2(circle.vy, circle.vx);

				if (speed > _friction)
				{
					speed -= _friction;
					circle.vx = Math.cos(angle) * speed;
					circle.vy = Math.sin(angle) * speed;
				}
				else
				{
					speed = 0;
					circle.vx = 0;
					circle.vy = 0;
				}
				
				circle.vy -= _gravity;
				
				circle.x += circle.vx;
				
				circle.y -= Math.floor(circle.vy);
				
				if ((circle.y + circleHeight) > sh) 
				{
					circle.vx = 0;
					circle.vx = rFloat * (- 15 + Math.random() * 30);
					
					circle.y = sh - circleHeight;
					
					circle.vy = 0;
					
					circle.vy = rFloat  * (30);
					
					circle.vy *= - 1;
				}
				
				var ratio:Number = 0;
				
				ratio = ((circle.y + circle.height)) / sh;
				
				_changeColor(circle, 0xFFFFFF, ratio);
				
				if ((circle.x + circleWidth) > stage.stageWidth)
				{
					circle.vx *= - 1;
					circle.x = sw - circleWidth;
				}
				else if (circle.x < 0)
				{
					circle.x = 0;
					circle.vx *= - 1;
				}
			}
		}

		private function _changeColor(circle:Circle, color:Number = 0xFF0000, ratio:Number = 0):void
		{
			var originalColor:Array = hex2rgb(circle.color);
			
			var cRed:Number = originalColor[0];
			var cGreen:Number = originalColor[1];
			var cBlue:Number = originalColor[2];
			
			var newColor:Array = hex2rgb(color);
			
			var maxRed:Number = newColor[0];
			var maxGreen:Number = newColor[1];
			var maxBlue:Number = newColor[2];
			
			var fRed:uint = maxRed + (ratio * (cRed - maxRed));
			var fGreen:uint = maxGreen + (ratio * (cGreen - maxGreen));
			var fBlue:uint = maxBlue + (ratio * (cBlue - maxBlue));
			
			var finalColorT:ColorTransform = new ColorTransform(0, 0, 0, 1, fRed, fGreen, fBlue, 0);
			
			circle.transform.colorTransform = finalColorT;
		}

		/**
		 * Conversion functions (for hexa/color tweening).
		 * @param hex The hexadecimal to be converted.
		 * @return HEXADECIMAL INTRO RGB (array with 3 indexes: 0=R, 1=G, 2=B).
		 */
		public static function hex2rgb(hex:Number):Array 
		{
			return new Array((hex >> 16), (hex >> 8 & 0xff), (hex & 0xff));
		}
	}
}