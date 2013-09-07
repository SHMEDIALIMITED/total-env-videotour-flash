package com.mpc.te.videotour.service {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osflash.signals.Signal;
	
	public class HTTPService {
		
		private var _loader:URLLoader;
		private var _completed:Signal;
		private var _request:URLRequest;
		
		public function HTTPService() {
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_completed = new Signal(Object, HTTPService);
		}
		
		public function send(request:URLRequest):void {
			_request = request;
			_loader.load(request);
		}
		
		protected function onSecurityError(e:SecurityErrorEvent):void {
			throw new Error('HTTPService Security Error #' + e.errorID  + ': ' + _request.url);	
		}
		
		protected function onIOError(e:IOErrorEvent):void {
			throw new Error('HTTPService IO Error #' + e.errorID  + ': ' + _request.url);	
		}
		
		protected function onComplete(e:Event):void {
			_completed.dispatch(e.target.data, this);
		}
		
		public function destroy():void {
			_loader.removeEventListener(Event.COMPLETE, onComplete);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_completed.removeAll();
			_loader = null;
			_completed = null;
			_request = null;
		}
		
		public function get completed():Signal {
			return _completed;
		}
	}
}