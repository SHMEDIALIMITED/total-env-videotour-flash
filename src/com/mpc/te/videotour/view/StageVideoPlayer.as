package com.mpc.te.videotour.view {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.setTimeout;
	
	import org.osflash.signals.Signal;
	
	public final class StageVideoPlayer extends Sprite {
		
		
		public function resize (rect:Rectangle):void {	
			if ( _stageVideo ) {
				_stageVideo.viewPort = rect;
			} else if(_video) {
				_video.width = rect.width;
				_video.height = rect.height;
				_video.x = rect.x, 
				_video.y = rect.y;
			}
		}
	
		public function play(url:String=null):void {
			if(_paused) _stream.resume();
			else _stream.play(url);
			_paused = false;
		}
		
		public function pause():void {
			_stream.pause();
			_paused = true;
		}
		
		public function stop():void {
			
			
			_stream.dispose();
			
		}
	
		
		private function stageVideoStateChange(event:StageVideoEvent):void {          
			var status:String = event.status;  
			trace('STAGE VIDEO STATUS:', status);
		}
		
		private function onNetStatus(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					_stream = new NetStream(_connection);
					_stream.client = _client;
					_stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
					
					if(_ready) {	
						if(_stageVideo) _stageVideo.attachNetStream(_stream);
						else _video.attachNetStream(_stream);
						_readySignal.dispatch();
					}
					_ready = true;
					break;
				case "NetStream.Play.StreamNotFound":
					trace("Stream not found:");
					break;
			}
		}
				
		protected function onSecurityError(event:SecurityErrorEvent):void { }
			
		public function get ready():Signal {
			return _readySignal;
		}
		
		public function get time():Number {
			return _stream.time;
		}
		
		private function onAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			if(stage.stageVideos.length > _stageVideoIndex) {
				_stageVideo = stage.stageVideos[_stageVideoIndex];
				_stageVideo.depth = _stageVideoIndex;
				_stageVideo.addEventListener(StageVideoEvent.RENDER_STATE, stageVideoStateChange);  
			} else {
				_video = new Video();
				addChild(_video);
			}
			
			if(_ready) {
				if(_stageVideo) _stageVideo.attachNetStream(_stream);
				else _video.attachNetStream(_stream);
				_readySignal.dispatch();
			}
			_ready = true;
		}
		
		public function StageVideoPlayer(stageVideoIndex:int) {
			_stageVideoIndex = stageVideoIndex;
			_readySignal = new Signal();
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_connection.connect(null);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		
		private var _stageVideoIndex:int;
		private var _stream:NetStream;
		private var _connection:NetConnection;
		private var _stageVideo:StageVideo;
		private var	_video:Video;
		private var _paused:Boolean;
		private var _readySignal:Signal;
		private var _ready:Boolean;
		private var _client:Object = { 
			
			onMetaData : function(info:Object):void {
				trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
			},
			
			onCuePoint : function(info:Object):void {
				trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
			}
		}
	}
}