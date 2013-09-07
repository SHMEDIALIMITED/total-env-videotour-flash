package com.mpc.te.videotour.view {
	
	import com.mpc.te.videotour.model.Quad;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import org.flashsandy.display.DistortImage;
	
	public class Photo extends Sprite {
		
		private const precision:int = 2;
		
		private var _distort:DistortImage;
		private var _bitmapData:BitmapData;
		
		
		public function render(quad:Quad):void {
			
			this.graphics.clear();
			
			if(!_distort) return;
			_distort.setTransform(
				this.graphics, 
				_bitmapData, 
				new Point(quad.Bx, quad.By),
				new Point(quad.Ax, quad.Ay),
				new Point(quad.Cx, quad.Cy),
				new Point(quad.Dx, quad.Dy))
		}
		
		private function onImageLoaded(image:Image):void {
			_bitmapData = new BitmapData(image.width, image.height, false);
			_bitmapData.draw(image);
			
			var b:Bitmap = new Bitmap(_bitmapData);
			//addChild(b);
			
			
			_distort = new DistortImage(image.width, image.height, precision, precision);
			image.destroy();
		}
		
		public function set src(val:String):void {
			var image:Image = new Image();
			image.src = val;
			image.loaded.addOnce(onImageLoaded);
		}	
	}
}