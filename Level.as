package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.utils.*;
	
	public class Level extends World
	{
		//[Embed(source="images/bg.png")] public static const BgGfx: Class;
		
		public function Level ()
		{
			add(new Player());
		}
		
		public override function update (): void
		{
			super.update();
		}
		
		public override function render (): void
		{
			super.render();
			
			Draw.rect((Math.sin(getTimer()*0.001)+1) * FP.width*0.5, 50, 50, 50, 0xFF0000);
		}
	}
}

