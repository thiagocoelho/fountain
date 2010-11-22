package {
	import flash.geom.ColorTransform;
	import net.hires.debug.Stats;
	import flash.filters.BlurFilter;
	import flash.display.*;
	import flash.events.*;

	/**
	 * @author thiago
	 */
	 
	[SWF(backgroundColor="#000000", frameRate="31", width="640", height="480")]
	
	public class App extends MovieClip
	{
		private var _circles:Array = new Array();
		
		private var _gravity:Number = 0.3;
		
		public function App()
		{
			addChild(new Stats());
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			for (var i:int = 0; i < 200; i++)
			{
				var circle:Circle = new Circle(10, false, 0xFFFFFF);
				
				circle.vx = -5 + Math.random() * 10;
				circle.vy = 10 + Math.random() * 10;
				
				circle.finalPos = (circle.vy / _gravity) * circle.vy;
				
				circle.x = stage.stageWidth/2 - circle.width/2;
				circle.y = stage.stageHeight;
				
				circle.isLaunched = false;
				
				addChild(circle);
				
				_circles.push(circle);
			}
			
			stage.addEventListener(Event.ENTER_FRAME, _render);
		}

		private function _render(e:Event) : void
		{
			var sh:Number = stage.stageHeight;
			
			for each(var circle:Circle in _circles)
			{
				var cHeight:Number = circle.height;
				
				circle.y -= circle.vy;
				
				circle.x += circle.vx;
				
				circle.vy -= _gravity;
				
				if (circle.y+cHeight < sh - cHeight && !circle.isLaunched)
				{
					trace("launched");
					
					circle.isLaunched = true;
				}
				
				circle.alpha = circle.y / circle.finalPos;
				
				if ((circle.y + cHeight) >= sh && circle.isLaunched && !circle.isBounced)
				{
					var cTransform:ColorTransform = new ColorTransform(0, 0, 0, 1, 123, 120, 60, 0);
					
					circle.transform.colorTransform = cTransform;
					
					circle.vy = 5 + (Math.random() * 5);
					circle.isBounced = true;
				}
				
				//circle.filters = [new BlurFilter(circle.vx, Math.abs(circle.vy), 1)];
				
				if (circle.y > sh && circle.isBounced)
				{
					circle.isBounced = false;
					circle.isLaunched = false;
					circle.x = (stage.stageWidth*.5) - (circle.width*.5);
					circle.y = sh;
					circle.vy = 10 + (Math.random() * 10);
					circle.vx = -5 + (Math.random() * 10);
					
					circle.finalPos = (circle.vy / _gravity) * circle.vy;
				}
				 
			}
			
		}
		
	}
}
