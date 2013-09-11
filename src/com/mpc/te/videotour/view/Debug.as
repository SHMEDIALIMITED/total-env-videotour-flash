package com.mpc.te.videotour.view {
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Debug extends Sprite {
		
		public static const instance:Debug = new Debug();
		private var _txt:TextField;
		
		
		public function Debug() {
			_txt = new TextField();
			_txt.textColor = 0xffffff;
			_txt.background = true;
			_txt.backgroundColor = 0;
			_txt.border = true;
			_txt.borderColor = 0xeeeeee;
			addChild(_txt);
			
			var format:TextFormat = _txt.defaultTextFormat;
			format.bold = true;
			_txt.defaultTextFormat = format;
		}
		
		public function log(val:String):void {
			_txt.appendText(val + '\n');
		}
		
		public function init(stage:Stage):void {
			stage.addChild(this);
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		private function onResize(e:Event):void {
			_txt.width = stage.stageWidth / 4;
			_txt.height = 200;
			_txt.y = stage.stageHeight - 200;
		}
	}
}