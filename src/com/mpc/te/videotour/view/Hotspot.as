package com.mpc.te.videotour.view {
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class Hotspot extends Button {
		
		public var txt:TextField;
		
		
		public function Hotspot() {
			alpha = 0;
		}
		
		public function set label(val:String):void {
			txt.text = val.toUpperCase();
		}
		
		protected override function onMouseOver(e:MouseEvent):void {
			
		}
		
		protected override function onMouseOut(e:MouseEvent):void {
			
		}
		
	}
}