package com.mpc.te.videotour.view {
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class LoaderAnimation extends Sprite { 
		
		private var _videoRectangle:Rectangle;
		private var _progress:Number;
		
		
		
		public function set progress(val:Number):void {
			_progress = Math.min(val, 1);		
		}
		
		public function draw(time:int):void {
			
		}
	}
}