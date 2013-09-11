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
			
			
			graphics.clear();
			
			graphics.beginFill(0x222222);
			graphics.drawRect(0,0, 200,100);
			graphics.endFill();
				
			var i:int = 0;
			
			var l:int = Math.ceil(_progress * 16) * 2;
			
			var itemWidth:Number = 4.0;
			
			var itemY:Number;
			
			while( i < l ){
				
				itemY = Math.sin(i+time /300);
				
				graphics.beginFill(0xffffff, 1);
				
				graphics.drawRect(20 + i* itemWidth+ i*1 , (itemY * (i/l/4) + 50) - ((20-itemY*2) * (i/l)) * .5 , itemWidth, (20-itemY*2) * (i/l));
				
				graphics.endFill();
				i++;
			}
		}
	}
}