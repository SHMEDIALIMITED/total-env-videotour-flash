package com.mpc.te.videotour.model {
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	public class Model {
		
		public var time:int;
		public var bandwidth:int;
		
		private var _shots:Array;
		private var _overlays:Array;
		private var _currentShot:Object;
		private var _currentOverlay:Object;
		private var _shotChanged:Signal;
		private var _overlayChanged:Signal;
		
		public function Model() {
			_shotChanged = new Signal(Object);
			_overlayChanged = new Signal(Object);
			time = getTimer();
		}
		
		public function parse(json:Object):void {
			_shots = json[0] as Array;
			_overlays = json[1] as Array;
			
			var i:int = 0, l:int = _shots.length;
			var shot:Object, source:String
			for(; i < l; ++i) {
				shot = _shots[i];
				source = shot.videoSource[0];
				shot.videoSource[0] = source.substr(0, source.length-3) + 'f4v';
			}
			
			i = 0, l = _overlays.length;
			var overlay:Object;
			for(; i < l; ++i) {
				overlay = _overlays[i];
				if(overlay.type != 2) {
					source = overlay.videoSource[0];
					overlay.videoSource[0] = source.substr(0, -3) + 'f4v';
				}
			}
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
		
		public function updateDeltaTime():int {
			const newTime:int = getTimer();
			const dt:int = newTime - time;
			time = newTime;
			return time;
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