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
		[Embed(source="audio/sfx.swf#text")] public static const TextSfx: Class;
		[Embed(source="audio/sfx.swf#input")] public static const InputSfx: Class;
		
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
		public var enemies:Array;
		public var enemyTimer:int;
		
		public var deathMessage:String;
		
		public var hum:Sfx;
		public var textSfx:Sfx;
		public var inputSfx:Sfx;
		
		public function Level ()
		{
			add(new Player());
			
			lastText = makeText(new IntroTxt);
			addGraphic(lastText);
			textList.push(lastText);
			
			loadLevels();
			
			addLevelChoice();
			
			hum = new Sfx(HumSfx);
			hum.loop();
			hum.volume = 2;
			
			textSfx = new Sfx(TextSfx);
			textSfx.loop();
			textSfx.volume = 2;
			
			inputSfx = new Sfx(InputSfx);
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
			var i:int = 0;
			var j:int = 0;
			
			const waitChar:String = "\uFEFF";
			
			while ((i = s.indexOf("{WAIT", i)) != -1) {
				j = s.indexOf("}", i);
				var wait:int = int(s.substring(i+5, j));
				var after:String = s.substring(j+1);
				s = s.substring(0, i);
				
				for (j = 0; j < wait; j++) {
					s += waitChar;
				}
				
				s += after;
				
				i += wait;
			}
			
			var max:int = 33;
			
			var length:int = 0;
			var lastSpace:int = -1;
			
			for (i = 0; i < s.length; i++) {
				var c:String = s.charAt(i);
				if (c == waitChar) {
					continue;
				}
				if (c == "\n") {
					length = 0;
					lastSpace = -1;
					continue;
				}
				if (c == " ") {
					lastSpace = i;
				}
				
				length++;
				
				if (length > max && lastSpace > 0) {
					s = s.substring(0, lastSpace) + "\n" + s.substring(lastSpace+1);
					length -= lastSpace + 1;
					lastSpace = -1;
				}
			}
			
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
			addText("The following sessions have been marked for review:");
			
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
					inputSfx.play();
					return;
				}
				
				playerCallback();
				
				updateEnemies();
				
				if (player.x == 0 || player.y == 0) {
					deathMessage = "Subject automatically neutralised by containment procedures";
					playerCallback = update_die;
				}
				
				updateGrid();
			}
			
			if (toAdd.length || ! lastIsDone) {
				if (! preventSkip && Input.pressed(Key.SPACE)) {
					Text.textDelay = 0;
				}
				
				textSfx.volume = 2;
				
				preventSkip = false;
				
				return;
			}
			
			textSfx.volume = 0;
			
			preventSkip = false;
			
			Text.textDelay = 1;
			
			if (choices.length) {
				if (choices.length > 1) {
					if (Input.pressed(Key.UP)) {
						choices[selected].visible = true;
						selected--;
						if (selected < 0) selected = 0;
						t = 0;
						inputSfx.play();
					}
					
					if (Input.pressed(Key.DOWN)) {
						choices[selected].visible = true;
						selected++;
						if (selected >= choices.length) selected = choices.length - 1;
						t = 0;
						inputSfx.play();
					}
				}
				
				if (Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER)) {
					choices[selected].visible = true;
					initMap();
					choices.length = 0;
					inputSfx.play();
				} else {
					choices[selected].visible = ((t % 60) >= 30);
				}
			}
		}
		
		public function initMap ():void
		{
			waitTime = -1;
			enemyTimer = 0;
			
			player = new Point;
			
			enemies = [];
			
			playerCallback = levels[selected].callback;
			
			map = addText(levels[selected].map.replace(/[<>^v]/g, "@"));
			addText(levels[selected].comments);
			
			grid = levels[selected].map.split("\n");
			
			map.setStyle("player", {color: 0xFFFFFF});
			map.setStyle("enemy", {color: 0xFF2222});
			
			for (i = 0; i < grid.length; i++) {
				grid[i] = grid[i].split("");
			}
			
			var i:int;
			var j:int;
			
			for (j = 0; j < grid.length; j++) {
				for (i = 0; i < grid[j].length; i++) {
					var c:String = grid[j][i];
					if (c == "@") {
						grid[j][i] = "C";
						player.x = i;
						player.y = j;
						continue;
					}
					if (c == ">" || c == "<" || c == "^" || c == "v") {
						grid[j][i] = " ";
						var enemy:Object = {}
						enemy.x = i;
						enemy.y = j;
						enemy.dx = 0;
						enemy.dy = 0;
						if (c == ">") enemy.dx = 1;
						else if (c == "<") enemy.dx = -1;
						else if (c == "^") enemy.dy = -1;
						else if (c == "v") enemy.dy = 1;
						
						enemies.push(enemy);
					}
				}
			}
		}
		
		public function updateEnemies ():void
		{
			enemyTimer++;
			
			var doMove:Boolean = ((enemyTimer % 24) == 0);
			
			var enemy:*;
			
			for each (enemy in enemies) {
				var ix:int = enemy.x;
				var iy:int = enemy.y;
				var dx:int = enemy.dx;
				var dy:int = enemy.dy;
				
				if (! dx && ! dy) continue;
				
				if (doMove) {
					if (solid.indexOf(grid[iy+dy][ix+dx]) >= 0) {
						dx *= -1;
						dy *= -1;
						enemy.dx = dx;
						enemy.dy = dy;
					}
					
					enemy.x += dx;
					enemy.y += dy;
				}
				
				if (enemy.x == player.x && enemy.y == player.y) {
					enemy.dx = enemy.dy = 0;
					enemy.x = enemy.y = -1;
					playerCallback = update_die;
					deathMessage = "Subject contamination"
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
				waitTime = 1;
			}
			if (update_normal()) {
				deathMessage = "Subject collapsed immediately upon leaving gestation tube\nCause: severe brain hemorrhaging";
				wait(30, update_die);
			}
		}
		
		public function update_staggerdie ():void
		{
			if (Input.pressed(Key.LEFT) || Input.pressed(Key.RIGHT) || Input.pressed(Key.UP) || Input.pressed(Key.DOWN)) {
				inputSfx.play();
				
				if (waitTime == -1) {
					waitTime = 10;
					addText("Subject experienced severe nausea and disorientation");
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
		
		public function update_leanonwalls ():void
		{
			var nextToWall:Boolean = false;
			
			var ix:int = player.x;
			var iy:int = player.y;
			
			var i:int;
			var j:int;
			
			for (j = -1; j <= 1; j++) {
				for (i = -1; i <= 1; i++) {
					if (solid.indexOf(grid[iy+j][ix+i]) >= 0) {
						nextToWall = true;
						break;
					}
				}
			}
			
			if (nextToWall) {
				update_normal();
			} else if (Input.pressed(Key.LEFT) || Input.pressed(Key.RIGHT) || Input.pressed(Key.UP) || Input.pressed(Key.DOWN)) {
				
				if (waitTime == -1) {
					waitTime = 10;
					addText("Subject heavily disoriented when not leaning on a wall for support");
				}
			
				inputSfx.play();
				
				var dx:int;
				var dy:int;
				
				if (Math.random() < 0.5) {
					dx = (Math.random() < 0.5) ? -1 : 1;
				} else {
					dy = (Math.random() < 0.5) ? -1 : 1;
				}
				
				move(dx, dy);
			}
		}
		
		public function update_die ():void
		{
			grid[player.y][player.x] = "<player>x</player>";
			player.x = player.y = -1;
			
			if (deathMessage) {
				addText(deathMessage);
			} else {
				addText("Subject collapsed");
			}
			
			deathMessage = null;
			
			choices.push(addText("Back"));
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
				
				inputSfx.play();
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
			
			if (dx || dy) inputSfx.play();
			
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
			
			t = 0;
			
			return true;
		}
		
		public function updateGrid ():void
		{
			if (! map) return;
			
			var showPlayer:Boolean = true;//(t % 60) < 30;
			var showEnemy:Boolean = true;//(enemyTimer % 12) < 6;
			
			var c:String;
			var s:String = "";
			var enemy:*;
			
			var i:int;
			var j:int;
			
			for (j = 0; j < grid.length; j++) {
				for (i = 0; i < grid[j].length; i++) {
					if (showPlayer && player.x == i && player.y == j) {
						c = "<player>@</player>";
					} else {
						c = grid[j][i];
						
						if (showEnemy) {
							for each (enemy in enemies) {
								if (enemy.x == i && enemy.y == j) {
									c = "<enemy>@</enemy>";
								}
							}
						}
					}
					
					s += c;
				}
				s += "\n";
			}
			
			s = s.substr(0, -1);
			
			map.richText = s;
		}
		
		public override function render (): void
		{
			super.render();
		}
	}
}

