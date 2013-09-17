package com.mpc.te.videotour.view {
	
	import flash.events.NetStatusEvent;
	import flash.geom.Rectangle;

	public final class VideoPlayer extends StageVideoPlayer {
		
		private var _loaderAnimation:LoaderAnimation;
		private var _buffering:Boolean;
		private var _bandwidth:int;
		
		public function VideoPlayer(stageVideoIndex:int) {
			super(stageVideoIndex);
			_loaderAnimation = new LoaderAnimation();
			
			addChild(_loaderAnimation);			
		}
		
		public function set bandwidth(val:int):void {
			_bandwidth = val;	
		}
		
		public function render(time):void {
			_loaderAnimation.progress = _stream.bufferLength / _stream.bufferTime;
			_loaderAnimation.draw(time);
		}
		
		public override function resize(rect:Rectangle):void {
			super.resize(rect);
			_loaderAnimation.x = rect.width * .5 - 100;
			_loaderAnimation.y = rect.height * .5 - 50 + rect.y;
		}
		
		private function showLoaderAnimation():void {
			_buffering = true;
			_loaderAnimation.graphics.clear();
			_stream.bufferTime = _bandwidth / 100;
			
		}
		
		protected override function onNetstreamBufferEmpty(e:NetStatusEvent):void {
			showLoaderAnimation();
		}
		
		protected override function onNetstreamPlayStart(e:NetStatusEvent):void {
			showLoaderAnimation();
		}	
		
		protected override function onNetstreamBufferFull(e:NetStatusEvent):void {
			_buffering = false;
			_loaderAnimation.graphics.clear();
		}
		
		protected override function onNetstreamBufferFlush(e:NetStatusEvent):void {
			_buffering = false;
			_loaderAnimation.graphics.clear();
		}
		
		public function get buffering():Boolean {
			return _buffering;
		}
	}
}