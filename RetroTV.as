﻿package {
	
	import flash.display.*;
	import flash.geom.*;
	import flash.filters.*;
	import flash.utils.getTimer;
	
	public class RetroTV {
		
		public var phosphorWidth:Number;
		public var  _brightenFactor:Number;
		public var preBlur:BlurFilter;
		public var warping:Boolean;
		public var scene:DisplayObject;
		public var sceneWidth:Number;
		public var sceneHeight:Number;
		public var _redOffsetX:Number;
		public var _redOffsetY:Number;
		public var _greenOffsetX:Number;
		public var _greenOffsetY:Number;
		public var _blueOffsetX:Number;
		public var _blueOffsetY:Number;
		public var minPhosphorLevel:Number;
		public var displacementBitmapData:BitmapData;
		public var noiseAmount:Number;
		public var usePreBlurRed:Boolean;
		public var usePreBlurGreen:Boolean;
		public var usePreBlurBlue:Boolean;
		
		public var distortScale:Number = 1.0;
		public var warpChange:int;
		
		public var TVPic:Bitmap;
		private var sceneData:BitmapData;
		private var TVPicData:BitmapData;
		private var origin:Point;
		private var verticalLine:Rectangle;
		private var destPoint:Point;
		private var noiseData:BitmapData;
		public var noiseBitmap:Bitmap;
		private var raiseFloor:ColorTransform;
		private var dmfilter:DisplacementMapFilter;
		private var redOffsetMatrix:Matrix;
		private var greenOffsetMatrix:Matrix;
		private var blueOffsetMatrix:Matrix;
		private var brighten:ColorTransform;
		
		
		public function RetroTV(inBuffer:BitmapData, phosphorW:int=1):void {
			phosphorWidth = phosphorW;
			//weird things happen if phosphorWidth is not set to an integer > 0.
			phosphorWidth = Math.max(1, Math.floor(phosphorWidth));
			
			sceneWidth = inBuffer.width;
			sceneHeight = inBuffer.height;
			
			scene = new Bitmap(inBuffer);
			
			noiseAmount = 10;
			
			usePreBlurRed = false;
			usePreBlurGreen = false;
			usePreBlurBlue = false;
			preBlur = new BlurFilter(2,2);
			
			_redOffsetX = 0;
			_redOffsetY = 0;
			_greenOffsetX = 0;
			_greenOffsetY = 0;
			_blueOffsetX = 0;
			_blueOffsetY = 0;
			redOffsetMatrix = new Matrix(1,0,0,1,_redOffsetX,_redOffsetY);
			greenOffsetMatrix = new Matrix(1,0,0,1,_greenOffsetX,_greenOffsetY);
			blueOffsetMatrix = new Matrix(1,0,0,1,_blueOffsetX,_blueOffsetY);
			
			
			minPhosphorLevel = 16;
			raiseFloor = new ColorTransform(1-minPhosphorLevel/255,1-minPhosphorLevel/255,1-minPhosphorLevel/255,1,minPhosphorLevel,minPhosphorLevel,minPhosphorLevel,0);
			
			_brightenFactor = 1.0;//25;
			brighten = new ColorTransform(_brightenFactor,_brightenFactor,_brightenFactor);
			
			warping = true;
			
			//sceneData is the BitmapData that the scene will be drawn to for pixel reading:
			sceneData = new BitmapData(sceneWidth,sceneHeight,false);
			
			//TVPic is the bitmap which will be displayed:
			TVPicData = new BitmapData(sceneWidth*3,sceneHeight,false);	
			TVPic = new Bitmap(TVPicData);
			TVPic.scaleX = phosphorWidth;
			TVPic.scaleY = 3*phosphorWidth;
			
			//noiseData will create the noise effect over the top
			noiseData = new BitmapData(3*sceneWidth,sceneHeight,false);
			noiseBitmap = new Bitmap(noiseData);
			noiseBitmap.scaleX = phosphorWidth;
			noiseBitmap.scaleY = 3*phosphorWidth;
			
			//We use the ADD blend mode so that the noiseBitmap will lighten underlying pixels.
			noiseBitmap.blendMode = BlendMode.ADD;
			
			createDisplacementMap();
						
			//point to use for filters:
			origin = new Point();
			
			verticalLine = new Rectangle(0,0,1,sceneData.height);
			destPoint = new Point();
		}
		
		public function set redOffsetX(n:Number):void {
			_redOffsetX = n;
			redOffsetMatrix = new Matrix(1,0,0,1,_redOffsetX,_redOffsetY);
		}
		public function set redOffsetY(n:Number):void {
			_redOffsetY = n;
			redOffsetMatrix = new Matrix(1,0,0,1,_redOffsetX,_redOffsetY);
		}
		public function set greenOffsetX(n:Number):void {
			_greenOffsetX = n;
			greenOffsetMatrix = new Matrix(1,0,0,1,_greenOffsetX,_greenOffsetY);
		}
		public function set greenOffsetY(n:Number):void {
			_greenOffsetY = n;
			greenOffsetMatrix = new Matrix(1,0,0,1,_greenOffsetX,_greenOffsetY);
		}
		public function set blueOffsetX(n:Number):void {
			_blueOffsetX = n;
			blueOffsetMatrix = new Matrix(1,0,0,1,_blueOffsetX,_blueOffsetY);
		}
		public function set blueOffsetY(n:Number):void {
			_blueOffsetY = n;
			blueOffsetMatrix = new Matrix(1,0,0,1,_blueOffsetX,_blueOffsetY);
		}
		
		public function set brightenFactor(n:Number):void {
			_brightenFactor = n;
			brighten = new ColorTransform(_brightenFactor,_brightenFactor,_brightenFactor);
		}
		public function get TVWidth():Number {
			return sceneWidth*phosphorWidth*3;
		}
		public function get TVHeight():Number {
			return sceneHeight*phosphorWidth*3;
		}
		
		
		private function createDisplacementMap():void {
			warpChange = Math.random()*1000 + 60;
			
			var numLines:Number = 8;
			var lineThicknessMax:Number = 4;
			var i:Number;
			
			displacementBitmapData = new BitmapData(sceneWidth,sceneHeight,false,0x808080);
			
			var gradMatrix:Matrix = new Matrix();
			var bottomWarpHeight:Number = 0.15*sceneHeight;
			var bottomWarp:Shape = new Shape();
			gradMatrix.createGradientBox(sceneWidth,bottomWarpHeight,-Math.PI/2,0,sceneHeight-bottomWarpHeight);
			bottomWarp.graphics.beginGradientFill(GradientType.LINEAR,[0xaaaaaa,0x808080],[1,1],[0,255],gradMatrix);
			bottomWarp.graphics.drawRect(0,sceneHeight-bottomWarpHeight,sceneWidth,bottomWarpHeight);
			bottomWarp.graphics.endFill();
			displacementBitmapData.draw(bottomWarp);
			
			for (i = 0; i < 7; i++) {
				var line:Shape = new Shape();
				var posY:Number = 5+Math.random()*(sceneHeight-10);
				var grayLevel:Number = 128+90*(2*Math.random()-1);
				var color:uint = grayLevel << 16 | grayLevel << 8 | grayLevel;
				line.graphics.lineStyle(1+2*Math.random(),color);
				line.graphics.moveTo(0,posY);
				line.graphics.lineTo(sceneWidth,posY);
				displacementBitmapData.draw(line);
			}
			
			var dmblur:BlurFilter = new BlurFilter(0,7,3);
			displacementBitmapData.applyFilter(displacementBitmapData,displacementBitmapData.rect,new Point(0,0),dmblur);
			dmfilter = new DisplacementMapFilter(displacementBitmapData,origin,BitmapDataChannel.RED,BitmapDataChannel.BLUE,2,0,DisplacementMapFilterMode.COLOR,0x000000);
		}
		
		
		public function update():void {
			
			//update warping amount
			if (warping) {
				warpChange--;
				
				dmfilter.scaleX = distortScale*40*(0.5+0.5*Math.cos(getTimer()*0.001027+Math.cos(getTimer()*0.001324)))*(0.5+0.5*Math.cos(getTimer()*0.005227+Math.cos(getTimer()*0.072324)));
				if (dmfilter.scaleX < 5) {
					if (warpChange < 0) {
						createDisplacementMap();
					}
					
					dmfilter.scaleX = 0;
				}
			}
			
			//change noise
			noiseData.noise(int(Math.random()*int.MAX_VALUE),0,noiseAmount,7,true);
				
			//draw TVPicData
			TVPicData.lock();
			
			TVPicData.fillRect(TVPicData.rect,0x000000);
			var i:Number;
				
			//draw scene to bitmap for copying
			sceneData.draw(scene,redOffsetMatrix);
			if (warping) {
				sceneData.applyFilter(sceneData,sceneData.rect,origin,dmfilter);
			}
			sceneData.colorTransform(sceneData.rect,brighten);
			sceneData.applyFilter(sceneData,sceneData.rect,origin,preBlur);
			for (i = 0; i<= sceneData.width; i++) {
				//red line
				verticalLine.x = i;
				destPoint.x = 3*i;
				TVPicData.copyChannel(sceneData,verticalLine,destPoint,BitmapDataChannel.RED,BitmapDataChannel.RED);
			}
			
			//draw scene to bitmap for copying
			sceneData.draw(scene,greenOffsetMatrix);
			if (warping) {
				sceneData.applyFilter(sceneData,sceneData.rect,origin,dmfilter);
			}
			sceneData.colorTransform(sceneData.rect,brighten);
			for (i = 0; i<= sceneData.width; i++) {
				//green line
				verticalLine.x = i;
				destPoint.x = 3*i+1;
				TVPicData.copyChannel(sceneData,verticalLine,destPoint,BitmapDataChannel.GREEN,BitmapDataChannel.GREEN);
			}
		
			//draw scene to bitmap for copying
			sceneData.draw(scene,blueOffsetMatrix);
			if (warping) {
				sceneData.applyFilter(sceneData,sceneData.rect,origin,dmfilter);
			}	
			sceneData.colorTransform(sceneData.rect,brighten);
			for (i = 0; i<= sceneData.width; i++) {
				//blue line
				verticalLine.x = i;
				destPoint.x = 3*i+2;
				TVPicData.copyChannel(sceneData,verticalLine,destPoint,BitmapDataChannel.BLUE,BitmapDataChannel.BLUE);
			}
			
			//raise floor to minimum phosphor level
			TVPicData.colorTransform(TVPicData.rect,raiseFloor);
			TVPicData.unlock();
		}
	}
}
