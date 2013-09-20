package com.mpc.te.videotour.view
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	
	import org.osflash.signals.Signal;
	
	/**
	 *	Image class encapsualtes Loader event listener callback handlers.
	 * 	It exposes loaded and progressed signals. 
	 * 	@author patrickwolleb
	 */	
	public final class Image extends Loader {
		
		private var _loaded:Signal;
		private var _progressed:Signal;
		
		/**
		 *	Constructor 
		 */		
		public function Image() {
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			this.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_loaded = new Signal(Image);
			_progressed = new Signal(Number);
		}
		
		
		/**
		 * 	Removes all signal listeners and internal refernces to get object ready for garbage collection
		 */		
		public function destroy():void {
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			this.unload();
			_loaded.removeAll();
			_loaded = null;
			_progressed.removeAll();
			_progressed = null;
		}
		
		
		/**
		 * 	Start image load when set
		 * 	@param val 
		 */		
		public function set src(val:String):void {
			this.load(new URLRequest(val));
		}
		
		
		/**
		 * 	LoadedSignal carries a reference to this Image instance as payload
		 * 	@return  
		 */		
		public function get loaded():Signal {
			return _loaded;
		}
		
		
		/**
		 * 	ProgressedSignal carries the progress Number ranging from 0 to 1
		 * 	@return 
		 */		
		public function get progressed():Signal {
			return _progressed;
		}
		
		
		
		private function onProgress(e:ProgressEvent):void {
			_progressed.dispatch(e.bytesLoaded / e.bytesTotal);
		}
		
		
		/**
		 * 	Throws security error
		 * 	@param e 
		 */		
		private function onSecurityError(e:SecurityErrorEvent):void {
			throw new Error('Image Security Error: ' + e.errorID);
		}
		
		
		/**
		 *	Throws IOError 
		 * 	@param e
		 */		
		private function onIOError(e:IOErrorEvent):void {
			throw new Error('Image IO Error: ' + e.errorID);
		}
		
		
		/**
		 * 	LoadCompleteEvent dispatches signal with this Image payload
		 * 	@param e 
		 */				
		private function onComplete(e:Event):void {
			_loaded.dispatch(this);
		}
	}
}