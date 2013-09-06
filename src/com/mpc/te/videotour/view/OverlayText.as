package com.mpc.te.videotour.view {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class OverlayText extends Sprite {
		
		public var txt:TextField;
		public var background:MovieClip;
		
		
		public function OverlayText() {
			txt.autoSize = TextFieldAutoSize.LEFT;
		}
		
		public function set text(val:String):void {
			txt.text = val;
			background.height = txt.height + 20;
		}
	}
}