package com.mpc.te.videotour.view {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StageVideoEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osflash.signals.Signal;
	
	public class StageVideoPlayer extends Sprite {
		
		
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
		
		
		protected function onNetstreamPlayStart(e:NetStatusEvent):void {
			
		}
		
		protected function onNetstreamPlayStop(e:NetStatusEvent):void {
			
		}
		
		protected function onNetstreamPlayStreamNotFound(e:NetStatusEvent):void {
			
		}
		
		protected function onNetstreamPlayFailed(e:NetStatusEvent):void {
			
		}
		
		protected function onNetstreamBufferEmpty(e:NetStatusEvent):void {
			
		}
		
		protected function onNetstreamBufferFull(e:NetStatusEvent):void {
			
		}
		
		protected function onNetstreamBufferFlush(e:NetStatusEvent):void {
			
		}
		
		
		private function onNetStreamStatus(e:NetStatusEvent):void {
			switch(e.info.code) {
				
				case 'NetStream.Play.Start' :
					trace('PLAY') 
					onNetstreamPlayStart(e);
					break;
				
				case 'NetStream.Play.Stop' :
					onNetstreamPlayStop(e);
					break;
				
				case "NetStream.Play.StreamNotFound":
					onNetstreamPlayStreamNotFound(e);
					break;
				
				case 'NetStream.Play.Failed' : 
					onNetstreamPlayFailed(e);
					break;
				
				case 'NetStream.Buffer.Empty' :
					trace('BUFFER EMPTY') 
					onNetstreamBufferEmpty(e);
					break;
				
				case 'NetStream.Buffer.Full' :
					trace('BUFFER FULL') 
					onNetstreamBufferFull(e);
					break;
				
				case 'NetStream.Buffer.Flush' :
					trace('BUFFER FLUSH') 
					onNetstreamBufferFlush(e);
					break;
				
			}
		}
		
		
		
		protected function onNetConnectionSuccess(event:NetStatusEvent):void {
			_stream = new NetStream(_connection);
			_stream.client = _client;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamStatus);		
			if(_ready) {	
				if(_stageVideo) _stageVideo.attachNetStream(_stream);
				else _video.attachNetStream(_stream);
				_readySignal.dispatch();
			}
			_ready = true;	
		}
		
		protected function onNetConnectionFail(e:NetStatusEvent):void {
			throw new Error('NetConnection.Connect.Failed');	
		}
		
		private function onNetConnectionStatus(e:NetStatusEvent):void {
			switch (e.info.code) {
				case 'NetConnection.Connect.Success':
					onNetConnectionSuccess(e);
					break;
				
				case 'NetConnection.Connect.Failed' : 
					onNetConnectionFail(e);
					break;
				
			}
		}
		
		protected function onSecurityError(e:SecurityErrorEvent):void {
			throw new Error('NetConnection Security Error: ' + e.errorID );
		}
		
		protected function stageVideoStateChange(event:StageVideoEvent):void {          
			var status:String = event.status;  
			trace('STAGE VIDEO STATUS:', status);
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
		
		public function get ready():Signal {
			return _readySignal;
		}
		
		public function get time():Number {
			return _stream.time;
		}
		
		public function calculateBufferSize(flvLength:Number, flvBitrate:Number, bandwidth:Number):Number {
			var bufferTime:Number;
			if (flvBitrate > bandwidth) {
				bufferTime = Math.ceil(flvLength - flvLength / (flvBitrate / bandwidth));
			} else {
				bufferTime = 0;
			}
			bufferTime += 3.0;
			
			return bufferTime;
		}
		
		public function StageVideoPlayer(stageVideoIndex:int) {
			_stageVideoIndex = stageVideoIndex;
			_readySignal = new Signal();
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
			_connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_connection.connect(null);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		
		private var _stageVideoIndex:int;
		protected var _stream:NetStream;
		private var _connection:NetConnection;
		private var _stageVideo:StageVideo;
		private var	_video:Video;
		private var _paused:Boolean;
		private var _readySignal:Signal;
		private var _ready:Boolean;
		protected var _client:Object = { 
			
			onMetaData : function(info:Object):void {
				trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
			},
			
			onCuePoint : function(info:Object):void {
				trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
			}
		}
	}
}