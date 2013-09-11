package com.mpc.te.videotour.view
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	
	import org.osflash.signals.Signal;
	
	public final class Image extends Loader {
		
		private var _loaded:Signal;
		private var _progressed:Signal;
		
		public function Image() {
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			this.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_loaded = new Signal(Image);
			_progressed = new Signal(Number);
		}
			
		public function destroy():void {
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			this.unload();
			_loaded.removeAll();
			_loaded = null;
		}
		
		public function set src(val:String):void {
			this.load(new URLRequest(val));
		}
		
		public function get loaded():Signal {
			return _loaded;
		}
		
		public function get progressed():Signal {
			return _progressed;
		}
		
		protected function onProgress(e:ProgressEvent):void {
			_progressed.dispatch(e.bytesLoaded / e.bytesTotal);
		}
		
		protected function onSecurityError(e:SecurityErrorEvent):void {
			trace('Image Security Error:', e.errorID);
		}
		
		protected function onIOError(e:IOErrorEvent):void {
			trace('Image IO Error:', e.errorID);
		}
		
		private function onComplete(e:Event):void {
			_loaded.dispatch(this);
		}
	}
}