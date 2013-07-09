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
			
			addGraphic(new Text(
"Chapter 8{WAIT20}\nLogging in{WAIT10}.{WAIT10}.{WAIT10}.{WAIT20}\n> {WAIT20}chain\nWelcome back [legion].\nThe following sessions have been\nmarked for review:\nTEST-0043-1987-07-07\nTEST-000782-1989-12-13\nTEST-014263-1992-03-22\n\
+-----+\n\
|O    |\n\
|    #|\n\
|C @  |\n\
|     *\n\
|0 . ~|\n\
+--*--+\n", 0, 0, {color: 0xd2f6a9}));
			
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
		}
	}
}

