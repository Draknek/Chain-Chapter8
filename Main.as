package
{
	import net.flashpunk.*;
	import net.flashpunk.debug.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	public class Main extends Engine
	{
		[Embed(source = 'ProggyTiny.ttf', embedAsCFF="false", fontFamily = 'ProggyTiny')]
		public static const FONT:Class;
		
		public var tv:RetroTV;
		public function Main () 
		{
			super(200, 150, 60, true);
			
			FP.screen.color = 0x0;
			
			Text.size = 16;
			Text.defaultLeading = 2;
			Text.font = "ProggyTiny";
			
			FP.world = new Level();
			
			tv = new RetroTV(FP.buffer, 0);
			
			addChild(tv.TVPic);
			addChild(tv.noiseBitmap);
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
		
		public override function render (): void
		{
			super.render();
			tv.update();
		}
	}
}

