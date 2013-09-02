package com.mpc.te.videotour
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.mpc.te.videotour.model.HotspotVO;
	import com.mpc.te.videotour.model.Model;
	import com.mpc.te.videotour.service.HTTPService;
	import com.mpc.te.videotour.view.HotspotPool;
	import com.mpc.te.videotour.view.StageVideoPlayer;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	[SWF(width="800", height="800")]
	public class Main extends Sprite {
		
		private function render(e:Event):void {
			const newTime:int = getTimer();
			const dt:int = newTime - _model.time;
			_model.time = newTime;
			//trace(dt);
			//trace(_player.time);
			
			var hotspots:Array = _model.shot.hotspotTracks;
			
			var i:int = hotspots.length;
			while( --i > -1 ) {
				
				var hotspot:Object = hotspots[i];
				var keyframes:Array = hotspot.keyframes as Array;
				
				
				
				if(keyframes.length > 0 && (keyframes[0] as Array)[0] >= _player.time) {
					if(!hotspot.view) {
						hotspot.view = _hotspotPool.getItem();
						addChild(hotspot.view);
					}
					
				}
				
				var j:int = 0;
				var size:int = keyframes.length + 1 >> 1;
				while( size > 0 ){
					var k:int = j + size;
					if( keyframes[ k ][0] < _player.time ) j = k;
					size >>= 1; // half the step size
				}
				
				var frame:Array = keyframes[j];
				
				
				
				TweenMax.to(hotspot.view, 0.2, { x: stage.stageWidth * frame[1], ease:Linear.easeNone});;
				TweenMax.to(hotspot.view, 0.2, { y: stage.stageHeight * frame[2], ease:Linear.easeNone});;
				
			}
			
		}
		
		private function onResize(e:Event):void {
			var stageWidth:Number = stage.stageWidth;
			var stageHeight:Number = stage.stageHeight;
			var halfWidth:Number = stageWidth * .5;
			var halfHeight:Number = stageHeight * .5;
			
			// Video Player Rectangle with fixed 16/9 apsect ratio
			var videoRectangle:Rectangle = new Rectangle(0,halfHeight - halfWidth /16 * 9, stageWidth, stageWidth / 16 * 9);
			_player.resize(videoRectangle);
			
			_hotpsotContainer.width = videoRectangle.width;
			_hotpsotContainer.height = videoRectangle.height;
			_hotpsotContainer.y = videoRectangle.y;
		}
		
		private function onShotChanged(shot:Object):void {
			
			var hotspots:Array = shot.hotspotTracks;
			var spot:Hotspot;
			
			for(var i:int = 0; i < hotspots[0].keyframes.length; ++i) {
				
				//trace(hotspots[0].keyframes[i]);
			}
			
			_player.play(shot.videoSource[0]);
			stage.addEventListener(Event.ENTER_FRAME, render);
		}
	
			
		private function start():void {
			onResize(null);
			_model.setShotByID('shot1');
		}
		
		private function parseData(res:Object, service:HTTPService):void {
			service.destroy();
			var json:Object = JSON.parse(res as String);
			_model = new Model(json);
			_model.shotChanged.add(onShotChanged);
			start();
		}
		
		private function initModel():void {
			var service:HTTPService = new HTTPService();
			service.completed.add(parseData);
			var request:URLRequest = new URLRequest('data.json');
			service.send(request);
		}
		
		private function initViews():void {
			//stage.color = 0;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_player = new StageVideoPlayer();
			_player.ready.add(initModel);
			addChild(_player);
			
			_hotspotPool = new HotspotPool();
			
			addChild(_hotpsotContainer);
				
			stage.addEventListener(Event.RESIZE, onResize);	
		}
		
		private function initSignals():void {
			_hotspotClicked = new Signal(HotspotVO);
			
		}
		
		private function onAddedToStage(e:Event):void {
			initSignals();
			initViews();
		}
		
		public function Main() {
			if(!stage) this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			else onAddedToStage(null);
		}
		
		
		private var _player:StageVideoPlayer;
		private var _hotspotClicked:Signal;
		private var _model:Model;
		private var _hotspotPool:HotspotPool;
		private const _hotpsotContainer:Sprite = new Sprite();
	}
}