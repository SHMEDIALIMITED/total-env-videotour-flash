package com.mpc.te.videotour.model {
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	
	/**
	 * App Model containing JSON data, state logic and common properties. 
	 * @author patrickwolleb
	 */	
	public class Model {
		
		
		
		
		/**
		 * 	Time since app start 
		 */		
		public var time:int;
		
		
		/**
		 * 	Bandwidth calculated from JSON data response time 
		 */		
		public var bandwidth:int;
		
		
		/**
		 * 	Array of shots as defined in JSON
		 */		
		private var _shots:Array;
		
		
		/**
		 * 	Array of overlays(lightboxes) as defined in JSON  
		 */		
		private var _overlays:Array;
		
		
		/**
		 *	Refernce to current Shot model object 
		 */
		private var _currentShot:Object;
		
		
		/**
		 * 	Refernce to previous shot 
		 */		
		private var _previousShot:Object;
		
		
		/**
		 *	Refernce to current Overlay(lightbox) model object  
		 */		
		private var _currentOverlay:Object;
		
		
		/**
		 *	Signal that is dispatched when shotID has been validated successfully
		 */		
		private var _shotChanged:Signal;
		
		
		/**
		 *	Signal that is dispatched when overlayID has been validated successfully 
		 */		
		private var _overlayChanged:Signal;
		
		
		
		/**
		 *	When Main SWF is loaded from preloader the Video URLs must be corrected to look in the parent directory for the videos  
		 */		
		private var _resolveRoot:Boolean;
		
		
		/**
		 * Constructor
		 * Creates instances of Signals and get current Time. 
		 */		
		public function Model(flashRoot:String) {
			_resolveRoot = flashRoot ? true : false;
			_shotChanged = new Signal(Object);
			_overlayChanged = new Signal(Object);
			time = getTimer();
		}
		
		
		/**
		 * Parse changes the video file extensions to .f4v for use in Flash. This is due to the JSON data being shared between the JS and Flash apps.  
		 * @param json
		 * 
		 */		
		public function parse(json:Object):void {
			_shots = json[0] as Array;
			_overlays = json[1] as Array;
			
			var i:int = 0, l:int = _shots.length;
			var shot:Object, source:String
			for(; i < l; ++i) {
				shot = _shots[i];
				source = shot.videoSource[0];
				source = _resolveRoot ? '../' + source : source;
				shot.videoSource[0] = source.substr(0, source.length-3) + 'f4v';
			}
			
			i = 0, l = _overlays.length;
			var overlay:Object;
			for(; i < l; ++i) {
				overlay = _overlays[i];
				if(overlay.type != 2) {
					source = overlay.videoSource[0];
					source = _resolveRoot ? '../' + source : source;	
					overlay.videoSource[0] = source.substr(0, -3) + 'f4v';
				}
			}
		}
		
		
		/**
		 * 	Validates shot ID.
		 * 	Dispatches shotChanged signal on success or throws a VideoID error
		 * 	@param val
		 */		
		public function setShotByID(val:String):void {
			
			if(_currentShot && _currentShot.videoId == val) return;
			
			var shots:Array = _shots;
			var shot:Object;
			var i:int = shots.length; 
			while( --i > -1 ) {
				shot = shots[i];
				if(shot.videoId == val) {
					_previousShot = _currentShot;
					_currentShot = shot;
					_shotChanged.dispatch(shot);
					return;
				}
			}
			throw new Error('Video ID not found: ', val);	
		}
		
		
		/**
		 * 	Validates overlay ID.
		 * 	Dispatches overlayChanged signal on success or throws a OverlayID error
		 * 	@param val
		 */	
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
		
		
		/**
		 *	Updates time and returns delta;
		 * 	@return time in milliseconds
		 */		
		public function updateDeltaTime():int {
			const newTime:int = getTimer();
			const dt:int = newTime - time;
			time = newTime;
			return dt;
		}
		
		
		/**
		 * Current active shot model
		 * @return 
		 */		
		public function get shot():Object {
			return _currentShot;
		}
		
		
		/**
		 * 	Previous shot
		 * 	Returns null when staring up  
		 * 	@return 
		 */		
		public function get previousShot():Object {
			return _previousShot;
		}
		
		
		/**
		 * 	ShotChanedSignal containing Shot object payload
		 * 	@return  
		 */		
		public function get shotChanged():Signal {
			return _shotChanged;
		}
		
		
		/**
		 * 	OverlayChangedSignal containing Overlay object payload
		 * 	@return  
		 */	
		public function get overlayChanged():Signal {
			return _overlayChanged;
		}
	}
}