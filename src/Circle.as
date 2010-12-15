package {
	import flash.display.*;

	/**
	 * @author thiago
	 */
	public class Circle extends MovieClip
	{
		public var vx:Number;
		public var vy:Number;
		
		public var weight:Number;
		
		public var finalPos:Number;
		
		public var isBounced:Boolean = false;
		public var isLaunched:Boolean = false;
		
		public var color:uint;
		
		public var exploded:Boolean = false;
		
		public var centerPoint:Number;
		
		public function Circle(radius:Number = 20, center:Boolean = false, color:uint = 0xFF0000, ivx:Number = 0, ivy:Number = 0, iweight:Number = 0)
		{
			this.color = color;
			
			this.graphics.beginFill(color);
			
			if (center)
			{
				this.centerPoint = 0;
				this.graphics.drawCircle(0, 0, radius);
			}
			else
			{
				this.centerPoint = radius;
				
				this.graphics.drawCircle(radius, radius, radius);
			}
			
			this.graphics.endFill();
			
			this.vx = ivx;
			this.vy = ivy;
			this.weight = iweight;
		}
	}
}
