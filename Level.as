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
		
		public var preventSkip:Boolean;
		
		public var t:int;
		
		public var map:Text;
		public var grid:Array;
		public var player:Point;
		public var playerCallback:Function;
		public var waitTime:int;
		public var nextPlayerCallback:Function;
		
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
				var callbackName:String = levelString.substring(j+1, k);
				data.callback = this["update_" + callbackName];
				
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
				
				playerCallback();
			}
			
			if (toAdd.length || ! lastIsDone) {
				if (! preventSkip && Input.pressed(Key.SPACE)) {
					Text.textDelay = 0;
				}
				
				preventSkip = false;
				
				return;
			}
			
			preventSkip = false;
			
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
					playerCallback = levels[selected].callback;
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
			waitTime = -1;
			
			player = new Point;
			
			grid = levels[selected].map.split("\n");
			
			for (i = 0; i < grid.length; i++) {
				grid[i] = grid[i].split("");
			}
			
			var i:int;
			var j:int;
			
			for (j = 0; j < grid.length; j++) {
				for (i = 0; i < grid[j].length; i++) {
					if (grid[j][i] == "@") {
						grid[j][i] = "C";
						player.x = i;
						player.y = j;
						return;
					}
				}
			}
		}
		
		public function wait (delay:int, nextCallback:Function):void
		{
			playerCallback = update_wait;
			waitTime = delay;
			nextPlayerCallback = nextCallback;
		}
		
		public function update_moveoncedie ():void
		{
			if (waitTime == -1) {
				addText("Subject emerged in poor condition");
				waitTime = 1;
			}
			if (update_normal()) {
				wait(30, update_die);
			}
		}
		
		public function update_staggerdie ():void
		{
			if (Input.pressed(Key.LEFT) || Input.pressed(Key.RIGHT) || Input.pressed(Key.UP) || Input.pressed(Key.DOWN)) {
				if (waitTime == -1) {
					waitTime = 10;
					addText("Subject experienced severe\nnausea and disorientation");
				}
			
				var dx:int;
				var dy:int;
				
				if (Math.random() < 0.5) {
					dx = (Math.random() < 0.5) ? -1 : 1;
				} else {
					dy = (Math.random() < 0.5) ? -1 : 1;
				}
				
				move(dx, dy);
				
				waitTime--
				
				if (waitTime < 0) {
					wait(30, update_die);
				}
			}
		}
		
		public function update_die ():void
		{
			grid[player.y][player.x] = "x";
			player.x = player.y = -1;
			
			updateGrid();
			
			addText("Subject lost: report ends");
			
			choices.push(addText("Continue?"));
			selected = 0;
			
			playerCallback = update_gameover;
		}
		
		public function update_gameover ():void
		{
			if (Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER)) {
				choices[selected].visible = true;
				map = null;
				addLevelChoice();
				preventSkip = true;
			}
		}
		
		public function update_wait ():void
		{
			waitTime--;
			
			if (waitTime < 0 && nextPlayerCallback != null) {
				playerCallback = nextPlayerCallback;
			}
		}
		
		public function update_normal ():Boolean
		{
			var dx:int = int(Input.pressed(Key.RIGHT)) - int(Input.pressed(Key.LEFT));
			var dy:int = int(Input.pressed(Key.DOWN)) - int(Input.pressed(Key.UP));
			
			return move(dx, dy);
		}
		
		public static const solid:String = "|-+*";
		
		public function move (dx:int, dy:int):Boolean
		{
			if (!dx && !dy) return false;
			if (dx && dy) return false;
			
			var ix:int = player.x + dx;
			var iy:int = player.y + dy;
			
			var c:String = grid[iy][ix];
			
			if (solid.indexOf(c) >= 0) return false;
			
			player.x = ix;
			player.y = iy;
			
			updateGrid();
			
			return true;
		}
		
		public function updateGrid ():void
		{
			var c:String;
			var s:String = "";
			
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

