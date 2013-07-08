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
		
		public function Level ()
		{
			add(new Player());
			
			addGraphic(new Text("Chapter 8{WAIT20}\nLogging in{WAIT10}.{WAIT10}.{WAIT10}.{WAIT20}\n> @", 0, 0, {color: 0xd2f6a9}));
			
			var hum:Sfx = new Sfx(HumSfx);
			hum.loop();
		}
		
		public override function update (): void
		{
			super.update();
		}
		
		public override function render (): void
		{
			super.render();
			
			Draw.rect((Math.sin(0*0.001)+1) * FP.width*0.5, 50, 50, 50, 0xFF0000);
		}
	}
}

