package com.mpc.te.videotour.view {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	
	/**
	 *	Abstract Button Class 
	 * 	Shoud be used within FLash IDE as base classes of library items
	 * 	@author patrickwolleb
	 */	
	public class Button extends MovieClip {
		
		/**
		 *	Button clicked signal
		 */		
		protected var _clicked:Signal;
		
		
		/**
		 *	Any Model usually target value object 
		 */		
		protected var _model:Object;
		
		
		/**
		 *	Constructor
		 */		
		public function Button() {
			_clicked = new Signal(Object);
			this.mouseChildren = false;
			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		
		/**
		 * 	MouseDown callback dispatches clicked signal containing button model payload.
		 * 	@param e
		 */		
		protected function onMouseDown(e:MouseEvent):void {
			_clicked.dispatch(_model);
		}
		
		
		/**
		 * 	MouseOver callback method stub
		 * 	@param e
		 */		
		protected function onMouseOver(e:MouseEvent):void {
				
		}
		
		
		/**
		 * 	MouseOut callback method stub
		 * 	@param e
		 */	
		protected function onMouseOut(e:MouseEvent):void {
			
		}
		
		
		/**
		 *	Any Model usually target value object
		 * 	@param val
		 */		
		public function set model(val:Object):void {
			_model = val;
		}
		
		
		/**
		 *	ClickedSignal containing model as payload
		 * 	@return 
		 */		
		public function get clicked():Signal {
			return _clicked;
		}
		
		
		/**
		 * 	Removes references and listeners to get object ready for garbage collection
		 */			
		public function destroy():void {
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_clicked.removeAll();
			_clicked = null;
		}
	}
}