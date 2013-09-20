package com.mpc.te.videotour.view {
	
	import flash.events.NetStatusEvent;
	
	import org.osflash.signals.Signal;
	
	
	/**
	 *	Concrete final VideoPlayer class for app. Handling signal dispatches buffering for start, end and progress.  
	 * 	@author patrickwolleb 
	 */
	public final class VideoPlayer extends StageVideoPlayer {
		
		private var _buffering:Boolean;
		private var _bandwidth:int;
		
		public var bufferingStarted:Signal;
		public var bufferingEnded:Signal;
		public var bufferProgressed:Signal;
		
		public function VideoPlayer(stageVideoIndex:int) {
			super(stageVideoIndex);
			
			bufferingStarted = new Signal();
			bufferingEnded = new Signal();
			bufferProgressed = new Signal(Number);			
		}
		
		public function set bandwidth(val:int):void {
			_bandwidth = val;	
		}
		
		public function render(time:int):void {
			bufferProgressed.dispatch(_stream.bufferLength / _stream.bufferTime);
		}
		
		private function showLoaderAnimation():void {
			_buffering = true;
			bufferingStarted.dispatch();
		}
		
		private function hideLoaderAnimation():void {
			_buffering = false;
			bufferingEnded.dispatch();
		}
		
		protected override function onNetstreamBufferEmpty(e:NetStatusEvent):void {
			if(_stream.time < _length) showLoaderAnimation();
			_stream.bufferTime = 4 / (_bandwidth * 0.001);
			Debug.instance.log('BUFFER TIME: ' + _stream.bufferTime)
			
		}
		
		protected override function onNetstreamPlayStart(e:NetStatusEvent):void {
			showLoaderAnimation();
		}	
		
		protected override function onNetstreamBufferFull(e:NetStatusEvent):void {
			hideLoaderAnimation();
			
		}
		
		protected override function onNetstreamBufferFlush(e:NetStatusEvent):void {
			hideLoaderAnimation();
		}
		
		public function get buffering():Boolean {
			return _buffering;
		}
	}
}