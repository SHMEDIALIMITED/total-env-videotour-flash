package com.mpc.te.videotour.view {
	
	import com.mpc.te.videotour.model.Quad;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	
	import org.flashsandy.display.DistortImage;
	
	
	/**
	 * 	Photo view for picture renderer
	 * 	Draws BitmapData into graphics using triangle distortion
	 * 	@author patrickwolleb
	 * 
	 */	
	public class Photo extends Sprite {
		
		private const precision:int = 2;
		
		private var _distort:DistortImage;
		private var _bitmapData:BitmapData;
		private var _blur:BlurFilter;
		private var _mask:Shape;
		
		
		public function Photo(){
			_blur = new BlurFilter(2,2,3);	
		}
		
		
		/**
		 * 	Renders the photo accroding to passed Quad. It is callbed by Picture renderer
		 * 	@param quad
		 */		
		public function render(quad:Quad):void {
			
			this.graphics.clear();
			
			if(!_distort) return;
			_distort.setTransform(
				this.graphics, 
				_bitmapData, quad.B, quad.A, quad.C, quad.D);
					
		}
		
		
		/**
		 * 	Renders clipping mask
		 * 	@param quad 
		 */		
		public function updateMask(quad:Quad):void {
			if(!_mask) return;
			const g:Graphics = _mask.graphics;
			g.clear();
			g.beginFill(0xff0000);
			g.moveTo(quad.Ax, quad.Ay);
			g.lineTo(quad.Bx, quad.By);
			g.lineTo(quad.Dx, quad.Dy);
			g.lineTo(quad.Cx, quad.Cy);
			g.endFill();
		}
		
		private function onImageLoaded(image:Image):void {
			_bitmapData = new BitmapData(image.width, image.height, false);
			_bitmapData.draw(image);
			var b:Bitmap = new Bitmap(_bitmapData);
			_distort = new DistortImage(image.width, image.height, precision, precision);
			_mask = new Shape();
			addChild(_mask)
			mask = _mask;
			image.destroy();
		}
		
		public function set blur(val:Number):void {
			_blur.blurX = _blur.blurY = val / 5;
			filters = [_blur];
		}
		
		public function set src(val:String):void {
			var image:Image = new Image();
			image.src = val;
			image.loaded.addOnce(onImageLoaded);
		}
		
		public function get imageWidth():Number {
			if(!_bitmapData) return 0.0;
			return _bitmapData.width;
		}
		
		public function get imageHeight():Number {
			if(!_bitmapData) return 0.0;
			return _bitmapData.height;
		}
		
		public function destroy():void {
			this.filters.length = 0;
			_blur = null;
			_bitmapData.dispose();
			_bitmapData = null;
			graphics.clear();
			_distort = null;
			_mask.graphics.clear();
			removeChild(_mask);
			_mask = null;
			mask = null;	
		}
	}
}