package {
	import flash.display.*;

	/**
	 * @author thiago
	 */
	public class Circle extends MovieClip
	{
		public var vx:Number;
		public var vy:Number;
		
		public var finalPos:Number;
		
		public var isBounced:Boolean = false;
		public var isLaunched:Boolean = false;
		
		public function Circle(radius:Number = 20, center:Boolean = false, color:uint = 0xFFFFFF, ivx:Number = 0, ivy:Number = 0)
		{
			this.graphics.beginFill(color);
			
			if (center)
			{
				this.graphics.drawCircle(0, 0, radius);
			}
			else
			{
				var topAlgin:Number = radius / 2;
				
				this.graphics.drawCircle(topAlgin, topAlgin, radius);
			}
			
			this.graphics.endFill();
			
			this.vx = ivx;
			this.vy = ivy;
		}
	}
}
