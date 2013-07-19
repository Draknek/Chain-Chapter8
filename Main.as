package
{
	import net.flashpunk.*;
	import net.flashpunk.debug.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Main extends Engine
	{
		[Embed(source = 'ProggyTiny.ttf', embedAsCFF="false", fontFamily = 'ProggyTiny')]
		public static const FONT1:Class;
		[Embed(source = 'ProggySmall.ttf', embedAsCFF="false", fontFamily = 'ProggySmall')]
		public static const FONT2:Class;
		[Embed(source = 'ProggySquare.ttf', embedAsCFF="false", fontFamily = 'ProggySquare')]
		public static const FONT3:Class;
		
		public static const fonts:Array = ['ProggySquare', 'ProggySmall', 'ProggyTiny'];
		
		public var tv:RetroTV;
		public function Main () 
		{
			var stage:Stage = Preloader.stage;
			
			var w:int = Math.ceil(stage.stageWidth / 3);
			var h:int = Math.ceil(stage.stageHeight / 3);
			
			super(w, h, 60, true);
			
			FP.screen.color = 0x0;
			
			Text.defaultLeading = 0;
			
			loop: for (var i:int = 0; i < 2; i++) {
				Text.size = i ? 16 : 32;
				
				for each (var fontName:String in fonts) {
					Text.font = fontName;
					
					var t:Text = new Text("0");
					
					var charW:int = t.width - 4;
					var charH:int = t.height - 4;
					
					var charsWide:int = w / charW;
					var charsHigh:int = h / charH;
					
					if (charsWide >= Level.lineLength && charsHigh >= Level.linesHigh) {
						break loop;
					}
				}
			}
			
			Level.lineLength = charsWide;
			Level.linesHigh = charsHigh;
			
			FP.world = new Level();
			
			tv = new RetroTV(FP.buffer, 0);
			
			addChild(tv.TVPic);
			addChild(tv.noiseBitmap);
		}
		
		public override function init (): void
		{
			super.init();
		}
		
		public override function setStageProperties():void
		{
			stage.frameRate = FP.assignedFrameRate;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		public override function update (): void
		{
			if (Input.pressed(FP.console.toggleKey)) {
				// Doesn't matter if it's called when already enabled
				//FP.console.enable();
			}
			
			super.update();
			
			Input.mouseCursor = FP.focused ? "hide" : "auto";
		}
		
		public override function render (): void
		{
			super.render();
			tv.update();
		}
	}
}

