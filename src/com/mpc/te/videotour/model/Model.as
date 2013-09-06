package com.mpc.te.videotour.model {
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	public class Model {
		
		public var time:int;
		
		private var _shots:Array;
		private var _overlays:Array;
		private var _currentShot:Object;
		private var _currentOverlay:Object;
		private var _shotChanged:Signal;
		private var _overlayChanged:Signal;
		
		public function Model(data) {
			_shots = data[0];
			_overlays = data[1];
			_shotChanged = new Signal(Object);
			_overlayChanged = new Signal(Object);
			time = getTimer();
		}
		
		public function setShotByID(val:String):void {
			
			if(_currentShot && _currentShot.videoId == val) return;
			
			var shots:Array = _shots;
			var shot:Object;
			var i:int = shots.length; 
			while( --i > -1 ) {
				shot = shots[i];
				if(shot.videoId == val) {
					_currentShot = shot;
					_shotChanged.dispatch(shot);
					return;
				}
			}
			throw new Error('Video ID not found: ', val);	
		}
		
		
		public function setOverlayByID(val:String):void {
			
			if(_currentShot && _currentShot.videoId == val) return;
			
			var overlays:Array = _overlays;
			var overlay:Object;
			var i:int = overlays.length; 
			while( --i > -1 ) {
				overlay = overlays[i];
				if(overlay.lightboxId == val) {
					_currentOverlay = overlay;
					_overlayChanged.dispatch(overlay);
					return;
				}
			}
			throw new Error('Overlay ID not found: ', val);	
		}
		
		public function get shots():Array {
			return _shots;
		}
		
		public function get shot():Object {
			return _currentShot;
		}
		
		public function get shotChanged():Signal {
			return _shotChanged;
		}
		
		public function get overlayChanged():Signal {
			return _overlayChanged;
		}
	}
}