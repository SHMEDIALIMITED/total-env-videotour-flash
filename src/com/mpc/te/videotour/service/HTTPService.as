package com.mpc.te.videotour.service {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	
	/**
	 *	HTTPService 
	 * 	Encapsulates URLLoader providing signals for callbacks.
	 * 	@author patrickwolleb
	 */	
	public class HTTPService {
		
		/**
		 *	URLLoader reference
		 */		
		private var _loader:URLLoader;
		
		/**
		 *	CompletedSignal  
		 */		
		private var _completed:Signal;
		
		/**
		 * 	Progressed Signal 
		 */		
		private var _progressed:Signal;
		
		/**
		 *	URLRequest reference 
		 */		
		private var _request:URLRequest;
		
		
		/**
		 * 	Bandwidth detection
		 * 	IP Packet is usually 576 bytes in size, including 40 bytes of header data: 40/576 = 0.69444 or ~7% --> 0.93	 --> from http://www.betriebsraum.de/blog/2007/02/27/flash-video-tip-1-calculating-an-optimal-buffer-size/
		 */		
		private const IP_HEADER_OVERHEAD:Number = 0.07;
		
		
		/**
		 *	Time passed until response received
		 */		
		private var _time:int;
		
		
		/**
		 *	Calculated bandwidth for last request  
		 */		
		private var _bandwidth:Number;
		
		
		/**
		 *	Constructor
		 * 	Creates instances and adds listeners
		 */		
		public function HTTPService() {
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onComplete);
			_loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_completed = new Signal(Object, HTTPService);
			_progressed = new Signal(Number)
		}
		
		
		/**
		 *	Sends the request 
		 * 	@param request
		 */		
		public function send(request:URLRequest):void {
			_request = request;
			_loader.load(request);
			_time = getTimer();
		}
		
		
		/**
		 *	Securtiy Error callback
		 * 	@param e
		 */		
		protected function onSecurityError(e:SecurityErrorEvent):void {
			throw new Error('HTTPService Security Error #' + e.errorID  + ': ' + _request.url);	
		}
		
		
		/**
		 *	IO Error callback
		 * 	@param e
		 */		
		protected function onIOError(e:IOErrorEvent):void {
			throw new Error('HTTPService IO Error #' + e.errorID  + ': ' + _request.url);	
		}
		
		
		/**
		 *	Request success callback 	 
		 *	@param e
		 */		
		protected function onComplete(e:Event):void {
			_time = getTimer() - _time;
			var loadedKBits:Number = e.target.bytesTotal;
			_bandwidth =  Math.floor(10 * (loadedKBits/(_time)) * (1 - IP_HEADER_OVERHEAD));	
			_completed.dispatch(e.target.data, this);
		}
		
		
		/**
		 * 	Progress callback
		 * 	@param e 
		 */		
		protected function onProgress(e:ProgressEvent):void {
			_progressed.dispatch(e.bytesLoaded / e.bytesTotal);
		}
		
		
		/**
		 * 	Removes references and listeners to get object ready for garbage collection
		 */		
		public function destroy():void {
			_loader.removeEventListener(Event.COMPLETE, onComplete);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_completed.removeAll();
			_loader = null;
			_completed = null;
			_request = null;
		}
		
		
		/**
		 * 	Calculated bandwidth for last request
		 * 	@return 
		 */		
		public function get bandwidth():Number {
			return _bandwidth;
		}
		
		
		/**
		 * 	SuccessSignal 
		 * 	@return 
		 */		
		public function get completed():Signal {
			return _completed;
		}
		
		
		/**
		 * 	ProgressedSignal
		 * @return 
		 */		
		public function get progressed():Signal {
			return _progressed;
		}
	}
}