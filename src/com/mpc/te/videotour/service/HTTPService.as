package com.mpc.te.videotour.service {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	public class HTTPService {
		
		private var _loader:URLLoader;
		private var _completed:Signal;
		private var _progressed:Signal;
		private var _request:URLRequest;
		
		
		// Bandwidth detection
		// IP Packet is usually 576 bytes in size, including 40 bytes of header data: 40/576 = 0.69444 or ~7% --> 0.93	 --> from http://www.betriebsraum.de/blog/2007/02/27/flash-video-tip-1-calculating-an-optimal-buffer-size/
		private const IP_HEADER_OVERHEAD:Number = 0.07;
		private var _time:int;
		private var _bandwidth:Number;
		
		public function HTTPService() {
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onComplete);
			_loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_completed = new Signal(Object, HTTPService);
			_progressed = new Signal(Number)
		}
		
		public function send(request:URLRequest):void {
			_request = request;
			_loader.load(request);
			_time = getTimer();
		}
		
		protected function onSecurityError(e:SecurityErrorEvent):void {
			throw new Error('HTTPService Security Error #' + e.errorID  + ': ' + _request.url);	
		}
		
		protected function onIOError(e:IOErrorEvent):void {
			throw new Error('HTTPService IO Error #' + e.errorID  + ': ' + _request.url);	
		}
		
		protected function onComplete(e:Event):void {
			_time = getTimer() - _time;
			var loadedKBits:Number = e.target.bytesTotal;
			_bandwidth =  Math.floor(10 * (loadedKBits/(_time)) * (1 - IP_HEADER_OVERHEAD));	
			_completed.dispatch(e.target.data, this);
		}
		
		protected function onProgress(e:ProgressEvent):void {
			_progressed.dispatch(e.bytesLoaded / e.bytesTotal * 100);
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
		
		public function get bandwidth():Number {
			return _bandwidth;
		}
		
		public function get completed():Signal {
			return _completed;
		}
		
		public function get progressed():Signal {
			return _progressed;
		}
	}
}