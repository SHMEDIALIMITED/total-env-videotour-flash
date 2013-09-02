package com.mpc.te.videotour.model {
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	public class Model {
		
		public var time:int;
		
		private var _shots:Array;
		private var _currentShot:Object;
		private var _shotChanged:Signal;
		
		public function Model(data) {
			_shots = data;
			_shotChanged = new Signal(Object);
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
			throw new Error('Video ID not found');	
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
	}
}