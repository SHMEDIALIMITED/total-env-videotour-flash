package com.mpc.te.videotour.view {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import org.osflash.signals.Signal;
	
	public class Button extends MovieClip {
		
		
		
		private var _clicked:Signal;
		private var _model:Object;
		
		public function Button() {
			_clicked = new Signal(Object);
			this.mouseChildren = false;
			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		private function onMouseDown(e:MouseEvent):void {
			_clicked.dispatch(_model);
		}
		
		protected function onMouseOver(e:MouseEvent):void {
				
		}
		
		protected function onMouseOut(e:MouseEvent):void {
			
		}
		
		public function set model(val:Object):void {
			_model = val;
		}
		
		public function get clicked():Signal {
			return _clicked;
		}
		
		public function destroy():void {
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_clicked.removeAll();
			_clicked = null;
		}
	}
}