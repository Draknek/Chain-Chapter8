package
{
	import net.flashpunk.*;
	import net.flashpunk.debug.*;
	import net.flashpunk.utils.*;
	
	[SWF(width = "640", height = "480", backgroundColor="#000000")]
	public class Main extends Engine
	{
		public function Main () 
		{
			super(640, 480, 60, true);
			FP.world = new Level();
		}
		
		public override function init (): void
		{
			super.init();
		}
		
		public override function update (): void
		{
			if (Input.pressed(FP.console.toggleKey)) {
				// Doesn't matter if it's called when already enabled
				FP.console.enable();
			}
			
			super.update();
		}
	}
}

