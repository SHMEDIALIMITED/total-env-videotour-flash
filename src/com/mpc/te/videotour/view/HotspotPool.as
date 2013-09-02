package com.mpc.te.videotour.view {
	import com.mpc.te.videotour.Hotspot;
	
	import flash.display.DisplayObject;

	public class HotspotPool {
		
		private var _items:Array;
		
		public function HotspotPool() {
			_items = [];	
		}
		
		public function getItem():DisplayObject{
			var item:DisplayObject = _items.pop();
			if(!item) item = new Hotspot();
			return item;
		}
		
		public function returnItem(item:DisplayObject):void {
			_items.push(item);	
		}
	}
}