package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.utils.*;
	import flash.geom.*;
	
	public class Level extends World
	{
		[Embed(source="audio/sfx.swf#hum")] public static const HumSfx: Class;
		
		[Embed(source="audio/sfx.swf#hum2")] public static const Hum2Sfx: Class;
		
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
		
		public var map:Text;
		public var grid:Array;
		public var player:Point;
		
		public var hum:Sfx;
		public var hum2:Sfx;
		
		public function Level ()
		{
			add(new Player());
			
			lastText = makeText(new IntroTxt);
			addGraphic(lastText);
			textList.push(lastText);
			
			loadLevels();
			
			addLevelChoice();
			
			/*hum = new Sfx(HumSfx);
			hum.loop();
			hum.volume = 0;*/
			
			hum2 = new Sfx(Hum2Sfx);
			hum2.loop();
			hum2.volume = 2;
		}
		
		public function loadLevels ():void
		{
			var levelsData:String = new LevelsTxt;
			
			var levelStrings:Array = levelsData.split("\n\n");
			
			for each (var levelString:String in levelStrings) {
				var i:int = levelString.indexOf("\n");
				var j:int = levelString.indexOf(":", i);
				var k:int = levelString.indexOf("\n", j);
				
				var data:Object = {};
				
				data.name = levelString.substring(0, i);
				data.map = levelString.substring(i+1, j-1);
				data.comments = levelString.substring(k+1);
				
				data.grid = data.map.split("\n");
				
				for (i = 0; i < data.grid.length; i++) {
					data.grid[i] = data.grid[i].replace("@", "C").split("");
				}
				
				levels.push(data);
			}
		}
		
		public static function makeText (s:String):Text
		{
			return new Text(s, 0, 0, {color: 0xd2f6a9});
		}
		
		public function addText (s:String):Text
		{
			var text:Text = makeText(s);
			
			toAdd.push(text);
			
			return text;
		}
		
		public function addLevelChoice ():void
		{
			addText("The following sessions have been\nmarked for review:");
			
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
			
			while (lastText.y + lastText.textHeight > FP.height) {
				for each (var text:Text in textList) {
					text.y -= 10;
				}
			}
			
			if (map && map.stringLength >= map.text.length) {
				if (Input.pressed(Key.ESCAPE)) {
					map = null;
					addText("Report interrupted");
					addLevelChoice();
					return;
				}
				
				doPlayerInput();
			}
			
			if (toAdd.length || ! lastIsDone) {
				if (Input.pressed(Key.SPACE)) {
					Text.textDelay = 0;
				}
				return;
			}
			
			Text.textDelay = 1;
			
			if (choices.length) {
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
					map = addText(levels[selected].map);
					grid = levels[selected].grid;
					initMap();
					addText(levels[selected].comments);
					choices.length = 0;
				} else {
					choices[selected].visible = ((t % 60) >= 30);
				}
			}
		}
		
		public function initMap ():void
		{
			player = new Point;
			
			var i:int;
			var j:int;
			
			for (j = 0; j < grid.length; j++) {
				for (i = 0; i < grid[j].length; i++) {
					if (grid[j][i] == "C") {
						player.x = i;
						player.y = j;
						return;
					}
				}
			}
		}
		
		public function doPlayerInput ():void
		{
			var dx:int = int(Input.pressed(Key.RIGHT)) - int(Input.pressed(Key.LEFT));
			var dy:int = int(Input.pressed(Key.DOWN)) - int(Input.pressed(Key.UP));
			
			if (dx && dy) return;
			
			player.x += dx;
			player.y += dy;
			
			var s:String = "";
			var c:String;
			
			var i:int;
			var j:int;
			
			for (j = 0; j < grid.length; j++) {
				for (i = 0; i < grid[j].length; i++) {
					if (player.x == i && player.y == j) {
						c = "@";
					} else {
						c = grid[j][i];
					}
					
					s += c;
				}
				s += "\n";
			}
			
			s = s.substr(0, -1);
			
			map.text = s;
		}
		
		public override function render (): void
		{
			super.render();
		}
	}
}

