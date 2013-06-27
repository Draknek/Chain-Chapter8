
package
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.getDefinitionByName;

	[SWF(width = "640", height = "480", backgroundColor="#000000")]
	public class Preloader extends Sprite
	{
		// Change these values
		private static const mustClick: Boolean = false;
		private static const mainClassName: String = "Main";
		
		private static const BG_COLOR:uint = 0x000000;
		private static const FG_COLOR:uint = 0xFFFFFF;
		
		
		
		// Ignore everything else
		
		public static var stage:Stage;
		
		public static var hostedOn:String;
		
		
		
		private var progressBar: Shape;
		private var text: TextField;
		
		private var px:int;
		private var py:int;
		private var w:int;
		private var h:int;
		private var sw:int;
		private var sh:int;
		
		private var testLoad:Boolean = true;
		private var testLoadAmount:Number = 0;
		
		[Embed(source = 'net/flashpunk/graphics/04B_03__.TTF', embedAsCFF="false", fontFamily = 'default')]
		private static const FONT:Class;
		
		public function Preloader ()
		{
			Preloader.stage = this.stage;
			
			sw = stage.stageWidth;
			sh = stage.stageHeight;
			
			w = stage.stageWidth * 0.8;
			h = 20;
			
			px = (sw - w) * 0.5;
			py = (sh - h) * 0.5;
			
			sitelock(["draknek.org"]);
			
			graphics.beginFill(BG_COLOR);
			graphics.drawRect(0, 0, sw, sh);
			graphics.endFill();
			
			graphics.beginFill(FG_COLOR);
			graphics.drawRect(px - 2, py - 2, w + 4, h + 4);
			graphics.endFill();
			
			progressBar = new Shape();
			
			addChild(progressBar);
			
			text = makeText("O%", 16, "default", FG_COLOR);
			text.x = (sw - text.width) * 0.5;
			text.y = sh * 0.5 + h;
			
			addChild(text);
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			if (mustClick) {
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}

		public function onEnterFrame (e:Event): void
		{
			if (hasLoaded())
			{
				graphics.clear();
				graphics.beginFill(BG_COLOR);
				graphics.drawRect(0, 0, sw, sh);
				graphics.endFill();
				
				if (! mustClick) {
					startup();
				} else {
					text.scaleX = 2.0;
					text.scaleY = 2.0;
				
					text.text = "Click to start";
			
					text.y = (sh - text.height) * 0.5;
				}
			} else {
				var p:Number;
				
				if (testLoad) {
					p = testLoadAmount;
					testLoadAmount += 0.005;
				} else {
					p = (loaderInfo.bytesLoaded / loaderInfo.bytesTotal);
				}
				
				progressBar.graphics.clear();
				progressBar.graphics.beginFill(BG_COLOR);
				progressBar.graphics.drawRect(px, py, p * w, h);
				progressBar.graphics.endFill();
				
				text.text = int(p * 100) + "%";
			}
			
			text.x = (sw - text.width) * 0.5;
		}
		
		private function onMouseDown(e:MouseEvent):void {
			if (hasLoaded())
			{
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				startup();
			}
		}
		
		private function hasLoaded (): Boolean {
			if (testLoad) return testLoadAmount >= 1;
			return (loaderInfo.bytesLoaded >= loaderInfo.bytesTotal);
		}
		
		private function startup (): void {
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			var mainClass:Class = getDefinitionByName(mainClassName) as Class;
			parent.addChild(new mainClass as DisplayObject);
			
			parent.removeChild(this);
		}
		
		public function sitelock (allowed:Array):Boolean
		{
			var url:String = stage.loaderInfo.url;
			var startCheck:int = url.indexOf('://' ) + 3;
			
			if (url.substr(0, startCheck) != 'http://'
				&& url.substr(0, startCheck) != 'https://'
				&& url.substr(0, startCheck) != 'ftp://') return true;
			
			var domainLen:int = url.indexOf('/', startCheck) - startCheck;
			var host:String = url.substr(startCheck, domainLen);
			
			for each (var d:String in allowed)
			{
				if (host.substr(-d.length, d.length) == d) {
					hostedOn = d;
					return true;
				}
			}
			
			text = makeText('This game is not authorised\nto play on this website.\n\n<a href="http://www.draknek.org/">Go to my site</a>', 24, 'default', 0xFFFFFF, "a {text-decoration:underline;} a:hover {text-decoration:none;}");
			
			text.x = sw*0.5 - text.width*0.5;
			text.y = sh*0.5 - text.height*0.5;
			addChild(text);
			
			throw new Error("Error: this game is sitelocked");
			
			return false;
		}
		
		public static function makeText (text:String, size:Number, font:String, color:uint, css:String = null): TextField
		{
			var textField:TextField = new TextField;
			
			textField.selectable = false;
			
			textField.embedFonts = true;
			
			textField.multiline = true;
			
			textField.autoSize = "center";
			
			textField.textColor = color;
			
			var format:TextFormat = new TextFormat(font, size);
			format.align = "center";
			
			textField.defaultTextFormat = format;
			
			if (css) {
				var ss:StyleSheet = new StyleSheet();
				ss.parseCSS(css);
				textField.styleSheet = ss;
				textField.htmlText = text;
				textField.mouseEnabled = true;
			} else {
				textField.text = text;
				textField.mouseEnabled = false;
			}
			
			return textField;
		}
	}
}


