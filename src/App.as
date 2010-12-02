package {
	import flash.geom.ColorTransform;
	import net.hires.debug.Stats;
	import flash.filters.BlurFilter;
	import flash.display.*;
	import flash.events.*;

	/**
	 * @author thiago
	 */
	 
	[SWF(backgroundColor="#CCCCCC", frameRate="31", width="640", height="480")]
	
	public class App extends MovieClip
	{
		private var _circles:Array = new Array();
		
		private var _gravity:Number = 0.95;
		
		private var _angle:Number = 0;
		
		private var _drawLines:Boolean = false;
		
		private var _count:int = 2;
		
		private var _friction:Number = 0.1;
		
		public function App()
		{
			addChild(new Stats());
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			for (var i:int = 0; i < _count; i++)
			{
				var circle:Circle = new Circle(20, false, 0xFF0000);
				
				circle.vx = -10 + Math.random() * 20;
				//circle.vy = 10 + Math.random() * 10;
				circle.vy = 30;
				circle.weight = 5// + Math.random() * 10;
				
				circle.finalPos = Math.round((circle.vy / _gravity) * circle.vy);
				
				circle.x = stage.stageWidth/2 - circle.width/2;
				circle.y = stage.stageHeight - circle.height;
				
				circle.isLaunched = false;
				
				_circles.push(circle);
				
				addChild(circle);
			}
			
			stage.addEventListener(Event.ENTER_FRAME, _render);
		}

		private function _render(e:Event) : void
		{
			var sh:Number = stage.stageHeight;
			var sw:Number = stage.stageWidth;
			
			this.graphics.clear();
			
			var fCircle:Circle = _circles[0];
			
			this.graphics.moveTo(fCircle.x, fCircle.y);
			
			for each(var circle:Circle in _circles)
			{
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
					circle.vx = 0
					circle.vy = 0
				}
				
				circle.vy -= _gravity;
				
				circle.x += circle.vx;
				
				circle.y -= Math.floor(circle.vy);
				
				if (_drawLines)
				{
					this.graphics.lineStyle(1, 0xFFFFFF, ratio);
					
					this.graphics.lineTo(circle.x + circle.centerPoint, circle.y + circle.centerPoint);
				}
				
				if (circle.y + circleHeight < (sh - circleHeight) && !circle.isLaunched)
				{
					circle.isLaunched = true;
				}
				
				if ((circle.y + circleHeight) > sh && circle.isLaunched) 
				{
					circle.y = sh - circleHeight;
					
					circle.vy *= -1;
					
					circle.finalPos = Math.floor((circle.vy / _gravity) * circle.vy);
					
					if(!circle.isBounced)
					{
						circle.isBounced = true;
						circle.vy = speed + (Math.random() * circle.weight);
					}
				}
				
				var ratio:Number = 0;
				
				if (circle.finalPos == 0)
				{
					ratio = 1;
				}
				else
				{
					ratio = ((circle.y+circle.height) / circle.finalPos);
				}
				
				trace(circle.y, circle.finalPos, "ratio: ", ratio);
				
				_changeColor(circle, 0xFFFFFF, ratio);
				
				if ((circle.x + circleWidth) > stage.stageWidth)
				{
					circle.vx *= -1;
					circle.x = sw - circleWidth;
				}
				else if (circle.x < 0)
				{
					circle.x = 0;
					circle.vx *= -1;
				}
				
				//circle.filters = [new BlurFilter(circle.vx, Math.abs(circle.vy), 1)];
				
				/*
				if (circle.y > sh && circle.isBounced)
				{
				 	
				}
				*/
			}
		}
		
		private function _reset(target:Circle):void
		{
			var sw:Number = stage.stageWidth*.5;
			var sh:Number = stage.stageHeight;
					
			var centerPoint:Number = sw - target.width;
			
			target.isBounced = false;
			target.isLaunched = false;
			target.x = centerPoint;
			//circle.x = centerPoint + Math.cos(_angle) * centerPoint
			target.y = sh;
			//target.vy = 10 + (Math.random() * 10);
			target.vy = 10;
			target.vx = -5 + (Math.random() * 10);
			
			target.finalPos = Math.round((target.vy / _gravity) * target.vy);
		}

		private function _changeColor(circle : Circle, color : Number = 0xFF0000, ratio:Number = 0) : void
		{
			var originalColor:Array = hex2rgb(circle.color);
			
			var cRed:Number = originalColor[0];
			var cGreen:Number = originalColor[1];
			var cBlue:Number = originalColor[2];
			
			var newColor:Array = hex2rgb(color);
			
			var maxRed:Number = newColor[0];
			var maxGreen:Number = newColor[1];
			var maxBlue:Number = newColor[2];
			
			var fRed:uint = cRed + (ratio * (maxRed - cRed));
			var fGreen:uint = cGreen + (ratio * (maxGreen - cGreen));
			var fBlue:uint = cBlue + (ratio * (maxBlue - cBlue));
			
			var finalColorT:ColorTransform = new ColorTransform(0, 0, 0, 1, fRed, fGreen, fBlue, 0);
			
			circle.transform.colorTransform = finalColorT;
		}

		/**
		 * Conversion functions (for hexa/color tweening).
		 * @param hex The hexadecimal to be converted.
		 * @return HEXADECIMAL INTRO RGB (array with 3 indexes: 0=R, 1=G, 2=B).
		 */
		public static function hex2rgb(hex : Number) : Array 
		{
			return new Array( (hex >> 16), (hex >> 8 & 0xff), (hex & 0xff) );
		}
	}
}
