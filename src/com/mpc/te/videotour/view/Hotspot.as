package com.mpc.te.videotour.view {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import org.osflash.signals.Signal;
	
	public class Hotspot extends MovieClip {
		
		public var txt:TextField;
		
		private var _clicked:Signal;
		private var _model:Object;
		
		public function Hotspot() {
			_clicked = new Signal(Object);
			this.mouseChildren = false;
			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function onMouseDown(e:MouseEvent):void {
			switch(e.type) {
				case MouseEvent.MOUSE_DOWN :
					_clicked.dispatch(_model);
					break;
			}
		}
		
		public function set text(val:String):void {
			txt.text = val.toUpperCase();
		}
		
		public function get clicked():Signal {
			return _clicked;
		}
		
		public function set model(val:Object):void {
			_model = val;
		}
	}
}