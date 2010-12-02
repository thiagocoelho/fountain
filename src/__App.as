package {
	import net.hires.debug.Stats;
	import flash.display.*;
	
	/**
	 * @author thiago
	 */
	 
	[SWF(backgroundColor="#000000", frameRate="31", width="640", height="480")]
	
	public class __App extends MovieClip
	{
		public function __App()
		{
			addChild(new Stats());
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			
		}
	}
}
