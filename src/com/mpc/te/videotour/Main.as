package com.mpc.te.videotour
{
	
	import com.flashdynamix.utils.SWFProfiler;
	import com.mpc.te.videotour.model.Model;
	import com.mpc.te.videotour.service.HTTPService;
	import com.mpc.te.videotour.view.HotspotRenderer;
	import com.mpc.te.videotour.view.HotspotView;
	import com.mpc.te.videotour.view.Overlay;
	import com.mpc.te.videotour.view.Photo;
	import com.mpc.te.videotour.view.PictureRenderer;
	import com.mpc.te.videotour.view.StageVideoPlayer;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	[SWF(width="800", height="800", backgroundColor="#000000", frameRate="60")]
	public class Main extends Sprite {
		
		
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////// RENDER CALLBACK TRAGET 60FPS ////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		private function render(e:Event):void {
			const newTime:int = getTimer();
			const dt:int = newTime - _model.time;
			_model.time = newTime;
			
			_hotpsotRenderer.render(_player.time);
			_pictureRenderer.render(_player.time);
		}
		
		
		
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////// STAGE RESIZE CALLBACK ///////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		private function onResize(e:Event):void {
			var stageWidth:Number = stage.stageWidth;
			var stageHeight:Number = stage.stageHeight;
			var halfWidth:Number = stageWidth * .5;
			var halfHeight:Number = stageHeight * .5;
			
			var stageRectangle:Rectangle = new Rectangle(halfWidth, halfHeight, stageWidth, stageHeight);
			
			// Video Player Rectangle with fixed 16/9 apsect ratio
			var videoRectangle:Rectangle = new Rectangle(0,halfHeight - halfWidth /16 * 9, stageWidth, stageWidth / 16 * 9);
			_player.resize(videoRectangle);
			
			// Correct hotspot y position
			_hotpsotRenderer.y = videoRectangle.y;
			
			// Picuture Renderer needs video and stage dimensions plus y correction
			_pictureRenderer.resize(stageRectangle, videoRectangle);
			_pictureRenderer.y = videoRectangle.y;
			
			// Overlay
			_overlay.resize(stageRectangle, videoRectangle);
		}
		
		
		
		private function releaseShot():void {
			var hotspots:Array = _model.shot.hotspotTracks;
			var hotspot:Object;
			
			for(var i:int = 0; i < hotspots.length; ++i) {
				hotspot = hotspots[i];
				(hotspot.view as HotspotView).destroy();
				if(_hotpsotRenderer.contains((hotspot.view as HotspotView)))
					_hotpsotRenderer.removeChild((hotspot.view as HotspotView));
			}
		}
		
		
		
		
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////// SIGNAL CALLBACKS ////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function onHotpsotClicked(hotspot:Object):void {
			if(hotspot.hotspotType == 1) {			
				releaseShot();
				_model.setShotByID(hotspot.target);
			}else {	
				_model.setOverlayByID(hotspot.target);
			}
		}
		
		private function onShotChanged(shot:Object):void {
			
			const hotspots:Array = shot.hotspotTracks;
			const pictures:Array = shot.pictureTracks;
			
			var hotspot:Object;
			var picture:Object;
			
			
			var i:int;
			for(i = 0; i < hotspots.length; ++i) {
				hotspot = hotspots[i];
				hotspot.view = new HotspotView()
				hotspot.view.label = (hotspot.labelText as String).toUpperCase();
				hotspot.view.model = hotspot;
				(hotspot.view as HotspotView).clicked.add(onHotpsotClicked);
			}
			
			
			for(i = 0; i < pictures.length; ++i) {
				picture = pictures[i];
				picture.view = new Photo()
				picture.view.src = 'photos/tracking.png';
			}
			
			_player.play(shot.videoSource[0]);
		}
		
		private function onOverlayChanged(overlay:Object):void {
			_player.pause();
			addChild(_overlay);
			_hotpsotRenderer.visible = false;
			_overlay.show(overlay);
		}
		
		private function onOverlayClosed(overlay:Object):void {
			if(contains(_overlay)) {
				removeChild(_overlay);
				_overlay.hide(overlay);
				_hotpsotRenderer.visible = true;
				_player.play();
			}
		}
	
		
		
		
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////// INIT CODE ////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function start():void {
			onResize(null);
			_model.setShotByID('shot15');
			stage.addEventListener(Event.ENTER_FRAME, render);
		}
		
		private function parseData(res:Object, service:HTTPService):void {
			
			service.destroy();
			
			var json:Object = JSON.parse(res as String);
			_model = new Model(json);
			_model.shotChanged.add(onShotChanged);
			_model.overlayChanged.add(onOverlayChanged);
			
			_hotpsotRenderer.model = _model;
			_pictureRenderer.model = _model;
			
			start();
		}
		
		private function initModel():void {
			var service:HTTPService = new HTTPService();
			service.completed.add(parseData);
			var request:URLRequest = new URLRequest('data.json');
			service.send(request);
		}
		
		private function onAddedToStage(e:Event):void {
			
			SWFProfiler.init(stage, this);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_player = new StageVideoPlayer(0);
			_player.ready.add(initModel); ///////////////////// when player is ready then JSON data files starts being loaded
			addChild(_player);
			
			_hotpsotRenderer = new HotspotRenderer()
			addChild(_hotpsotRenderer);
			
			_pictureRenderer = new PictureRenderer();
			addChild(_pictureRenderer);
			
			_overlay = new Overlay();
			_overlay.closed.add(onOverlayClosed);
			
			stage.addEventListener(Event.RESIZE, onResize);	
		}
		
		public function Main() {
			if(!stage) this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			else onAddedToStage(null);
		}
		
		
		private var _player:StageVideoPlayer;
		private var _overlay:Overlay;
		private var _hotspotClicked:Signal;
		private var _model:Model;
		private var _hotpsotRenderer:HotspotRenderer;
		private var _pictureRenderer:PictureRenderer;
	}
}