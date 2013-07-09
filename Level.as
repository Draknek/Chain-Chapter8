package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.utils.*;
	
	public class Level extends World
	{
		[Embed(source="audio/sfx.swf#hum")] public static const HumSfx: Class;
		
		[Embed(source="intro.txt", mimeType="application/octet-stream")]
		public static const IntroTxt: Class;
		
		[Embed(source="levels.txt", mimeType="application/octet-stream")]
		public static const LevelsTxt: Class;
		
		public var lastText:Text;
		
		public var textList:Array = [];
		public var levels:Array = [];
		public var toAdd:Array = [];
		
		public var choices:Array = [];
		public var selected:int = 0;
		
		public var t:int;
		
		public function Level ()
		{
			add(new Player());
			
			lastText = makeText(new IntroTxt);
			addGraphic(lastText);
			textList.push(lastText);
			
			loadLevels();
			
			addLevelChoice();
			
			var hum:Sfx = new Sfx(HumSfx);
			hum.loop();
		}
		
		public function loadLevels ():void
		{
			var levelsData:String = new LevelsTxt;
			
			var levelStrings:Array = levelsData.split("\n\n");
			
			for each (var levelString:String in levelStrings) {
				var i:int = levelString.indexOf("\n");
				
				var data:Object = {};
				
				data.name = levelString.substring(0, i);
				
				data.rest = levelString.substring(i+1);
				
				levels.push(data);
			}
		}
		
		public static function makeText (s:String):Text
		{
			return new Text(s, 0, 0, {color: 0xd2f6a9});
		}
		
		public function addLevelChoice ():void
		{
			var i:int;
			
			choices.length = 0;
			selected = 0;
			
			for (i = 0; i < levels.length; i++) {
				var text:Text = makeText(levels[i].name);
				
				toAdd.push(text);
				choices.push(text);
			}
		}
		
		public override function update (): void
		{
			super.update();
			
			t++;
			
			var lastIsDone:Boolean = lastText.stringLength >= lastText.text.length;
			
			if (toAdd.length && lastIsDone) {
				var newText:Text = toAdd.shift();
				newText.y = lastText.y + lastText.height - 4;
				addGraphic(newText);
				
				lastText = newText;
				
				textList.push(newText);
				
				lastIsDone = false;
			}
			
			if (lastText.y + lastText.textHeight > FP.height) {
				for each (var text:Text in textList) {
					text.y -= 10;
				}
			}
			
			if (toAdd.length == 0 && lastIsDone && choices.length) {
				if (Input.pressed(Key.UP)) {
					choices[selected].visible = true;
					selected--;
					if (selected < 0) selected = 0;
					t = 0;
				}
				
				if (Input.pressed(Key.DOWN)) {
					choices[selected].visible = true;
					selected++;
					if (selected >= choices.length) selected = choices.length - 1;
					t = 0;
				}
				
				if (Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER)) {
					choices[selected].visible = true;
					var rest:String = levels[selected].rest;
					FP.log(rest);
					FP.log(rest.length);
					toAdd.push(makeText(rest));
					choices.length = 0;
				} else {
					choices[selected].visible = ((t % 60) >= 30);
				}
			}
		}
		
		public override function render (): void
		{
			super.render();
		}
	}
}

