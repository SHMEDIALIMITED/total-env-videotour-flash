package com.mpc.te.videotour
{
	
	import com.flashdynamix.utils.SWFProfiler;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.mpc.te.videotour.model.Model;
	import com.mpc.te.videotour.service.HTTPService;
	import com.mpc.te.videotour.view.Debug;
	import com.mpc.te.videotour.view.FloorPlan;
	import com.mpc.te.videotour.view.HotspotRenderer;
	import com.mpc.te.videotour.view.LoaderAnimation;
	import com.mpc.te.videotour.view.Overlay;
	import com.mpc.te.videotour.view.PictureRenderer;
	import com.mpc.te.videotour.view.VideoPlayer;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	
	/**
	 *  Appliaction entry point
	 * 	It reads bottom up for easy developement 
	 *	@author patrickwolleb
	 */
	
	[SWF(width="1200", height="800", backgroundColor="#000000", frameRate="60")]
	public class Main extends Sprite {
		
		
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////// RENDER CALLBACK TARGET 60FPS ////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Render callback is called when stage ENTER_FRAME event is fired.
		 * @param e 
		 */		
		private function render(e:Event):void {
			
			_model.updateDeltaTime();
			
			_floorPlan.update(_player.time);
			_hotpsotRenderer.render(_player.time);
			_pictureRenderer.render(_player.time);
			_overlay.render(_model.time);
			
			if(_player.buffering) {
				_player.render(_model.time);
			}	
		}
		
		
		
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////// STAGE RESIZE CALLBACK ///////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/**
		 * Resize callback is called when stage RESIZE event is fired.
		 * It calculates the videoRectangle and the stageRectangle and then positions and resizes all UI elements. 
		 * Note that stageRectangle's x and y are stage center positions
		 * @param e
		 */		
		private function onResize(e:Event):void {
			var stageWidth:Number = stage.stageWidth;
			var stageHeight:Number = stage.stageHeight;
			var halfWidth:Number = stageWidth * .5;
			var halfHeight:Number = stageHeight * .5;
			
			var stageRectangle:Rectangle = new Rectangle(halfWidth, halfHeight, stageWidth, stageHeight);
			
			// Video Player Rectangle with fixed 16/9 apsect ratio
			
			var videoRectangle:Rectangle
			if(stageWidth / stageHeight < 16 / 9) {
				videoRectangle = new Rectangle(0,halfHeight - halfWidth /16 * 9, stageWidth, stageWidth / 16 * 9);
			}else {
				videoRectangle = new Rectangle(halfWidth - halfHeight * 16 / 9, 0 , stageHeight * 16 / 9, stageHeight);
			}
			
			
			_player.resize(videoRectangle);
			
			_floorPlan.y = videoRectangle.y + 30;
			_floorPlan.x = videoRectangle.x;
			
			// Correct hotspot position
			_hotpsotRenderer.resize(stageRectangle, videoRectangle);
			_hotpsotRenderer.x = videoRectangle.x;
			_hotpsotRenderer.y = videoRectangle.y;
			
			
			// Picuture Renderer needs video and stage dimensions plus y correction
			_pictureRenderer.resize(stageRectangle, videoRectangle);
			_pictureRenderer.y = videoRectangle.y;
			_pictureRenderer.x = videoRectangle.x;
			
			// Overlay
			_overlay.resize(stageRectangle, videoRectangle);
			
			// Loader Animation
			_loaderAnimation.x = halfWidth;
			_loaderAnimation.y = halfHeight;
			_loaderAnimation.resize(stageRectangle);
			
			_black.width = stageRectangle.width;
			_black.height = stageRectangle.height;
			
		}
		
		
		
		
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////// SIGNAL CALLBACKS ////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/**
		 * HotpsotClicked callback is called when a Hotspot is receives a MOUSE_DOWN from the user. 
		 * The callback is hooked up through a Signal containing the traget model.
		 * @param hotspot Shot model object as defined in JSON. Note it's not strong-typed.
		 */		
		private function onHotpsotClicked(hotspot:Object):void {
			if(hotspot.hotspotType == 1) {			
				_model.setShotByID(hotspot.target);
			}else {	
				_model.setOverlayByID(hotspot.target);
			}
		}
		
		/**
		 * ShotChanged callback is called when the Model validated the traget id as a new shot and found the respective Shot value Object.
		 * @param shot Shot model object as defined in JSON. Note it's not strong-typed.
		 */		
		private function onShotChanged(shot:Object):void {
			_black.visible = true;
			_black.alpha = 0;
			
			if(_model.previousShot) {
				TweenMax.to(_black, 1.0, {alpha:1, onComplete:function(shot:Object):void {
					
					_hotpsotRenderer.model = shot.hotspotTracks;;
					_pictureRenderer.model = shot.pictureTracks;;
					_player.play(shot.videoSource[0]);
					_floorPlan.load(shot.floorplan);
					
					TweenMax.to(_black, 1.0, {alpha:0, onComplete:function():void {
						_black.visible = false;
					}, ease:Linear.easeNone});
					
					
				}, onCompleteParams:[shot]});
			}else {
				_black.visible = true;
				_black.alpha = 1;
				TweenMax.to(_black, 1.0, {alpha:0, onComplete:function():void {
					_black.visible = false;
				}, ease:Linear.easeNone});
				
				_hotpsotRenderer.model = shot.hotspotTracks;;
				_pictureRenderer.model = shot.pictureTracks;;
				_player.play(shot.videoSource[0]);
				_floorPlan.load(shot.floorplan);
				
			}
		}
		
		
		/**
		 * ShotChanged callback is called when the Model validated the traget id as a new overlay and found the respective Overlay value Object
		 * @param overlay Overlay model object as defined in JSON. Note it's not strong-typed.
		 */		
		private function onOverlayChanged(overlay:Object):void {
			addChild(_black);
			_black.alpha = 0;
			_black.visible = true;
			TweenMax.to(_black, 1.0, {alpha:1, onCompleteParams:[overlay], onComplete:function(overlay:Object):void {
				
				TweenMax.to(_black, 1.0, {alpha:0, onComplete:function():void {
					_black.visible = false;
				}, ease:Linear.easeNone});
				
				_player.pause();
				addChild(_overlay);
				addChild(_loaderAnimation);
				addChild(_black);
				_loaderAnimation.stop();
				_hotpsotRenderer.visible = false;
				_pictureRenderer.visible = false;
				_floorPlan.visible = false;
				_overlay.show(overlay);
			}, ease:Linear.easeNone});	
		}
		
		/**
		 * OverlayClosed callback is called when overlay close button received MOUSE_DOWN event. That event triggers a signal containing the current Overlay value object as a payload.
		 * @param overlay Overlay model object as defined in JSON. Note it's not strong-typed. 
		 */		
		private function onOverlayClosed(overlay:Object):void {
			_loaderAnimation.stop();
			_overlay.hide(overlay);
			addChild(_black);
			_black.alpha = 0;
			_black.visible = true;
			TweenMax.to(_black, 1.0, {alpha:1, ease:Linear.easeNone});
		}
		
		/**
		 * OverlayHidden callback is called when the overlay has been completely faded out and is ready to be removed from stage.
		 * This method is hooked up through a signal being dispatched from the Overaly view object. 
		 */		
		private function onOverlayHidden():void {
			if(contains(_overlay)) {
				addChild(_black);
				_black.alpha = 1;
				_black.visible = true;
				
				TweenMax.to(_black, 1.0, {alpha:0, onComplete:function():void {
					_black.visible = false;
				}, ease:Linear.easeNone});
				
				removeChild(_overlay);
				_loaderAnimation.stop();
				_hotpsotRenderer.visible = true;
				_pictureRenderer.visible = true;
				_floorPlan.visible = true;
				_player.play();
			}
		}
				
		
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////// INIT CODE ////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/**
		 * Start is called when the app has loaded the JSON into the Model and the StageVideoPLayer is ready. 
		 */		
		private function start():void {
			_loaderAnimation.stop();
			onResize(null);
			_model.setShotByID('shot11');
			stage.addEventListener(Event.ENTER_FRAME, render);		
		}
		
		/**
		 * ParseData is called from the JSON data HTTPService passing itself and the server response.
		 * @param res JSON String
		 * @param service HTTPService
		 */		
		private function parseData(res:Object, service:HTTPService):void {
			_model.bandwidth = _player.bandwidth = _overlay.player.bandwidth = service.bandwidth;
			service.destroy();
			var json:Object = JSON.parse(res as String);
			_model.parse(json)
			_model.shotChanged.add(onShotChanged);
			_model.overlayChanged.add(onOverlayChanged);
			
			start();							///////////////////// when Model has parsed JSON app starts rendering
		}
		
		/**
		 * LoadData is called when the StageVideoPlayer dispatches it's ready signal.
		 * It creates an instance of HTTPService to load to app JSON data.
		 */		
		private function loadData():void {
			var service:HTTPService = new HTTPService();
			service.completed.add(parseData); 	///////////////////// when data is loaded then Model parses JSON
			service.progressed.add(_loaderAnimation.setProgress);
			var request:URLRequest = new URLRequest('data.json');
			service.send(request);
			
		}
		
		/**
		 * AddedToStage is called when the app main view has been added to stage. 
		 * In development mode this should happen righ after the constructor gets called. When the app is loaded by the MainPreloader the app waits until the ADDED_TO_STAGE event is fired.  
		 * @param e
		 */		
		private function onAddedToStage(e:Event):void {
			
			
			// DEBUG TOOLS
			SWFProfiler.init(stage, this);
			Debug.instance.init(stage);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_model = new Model(stage.loaderInfo.parameters.flashRoot);
			
			// If the animation ahs been created in the MainPrelader we reuse the instance.
			if(!_loaderAnimation) _loaderAnimation = new LoaderAnimation();
			_loaderAnimation.start();
			
			_player = new VideoPlayer(0);
			_player.ready.add(loadData); 		///////////////////// when player is ready then JSON data files starts being loaded
			_player.bufferingStarted.add(_loaderAnimation.start);
			_player.bufferingEnded.add(_loaderAnimation.stop);
			_player.bufferProgressed.add(_loaderAnimation.setProgress);
			addChild(_player);
			
			_floorPlan = new FloorPlan();
			addChild(_floorPlan);
						
			_hotpsotRenderer = new HotspotRenderer();
			_hotpsotRenderer.hotspotClicked.add(onHotpsotClicked);
			addChild(_hotpsotRenderer);
			
			_pictureRenderer = new PictureRenderer();
			addChild(_pictureRenderer);
		
			_overlay = new Overlay();
			_overlay.closed.add(onOverlayClosed);
			_overlay.hidden.add(onOverlayHidden);
			_overlay.imageLoadingStarted.add(_loaderAnimation.start);
			_overlay.imageLoadingEnded.add(_loaderAnimation.stop);
			_overlay.imageLoadProgressed.add(_loaderAnimation.setProgress);
			_overlay.videoBufferingStarted.add(_loaderAnimation.start);
			_overlay.videoBufferingEnded.add(_loaderAnimation.stop);
			_overlay.videoBufferProgressed.add(_loaderAnimation.setProgress);
			
			// Stack on top of everthing else
			addChild(_loaderAnimation);
			
			// Black fullscreen shape for shot and overaly transisitons
			_black = new Shape();
			_black.visible = false;
			_black.graphics.beginFill(0);
			_black.graphics.drawRect(0,0,10,10);
			_black.graphics.endFill();
			addChild(_black);
			
			onResize(null);
			stage.addEventListener(Event.RESIZE, onResize);	
		}
		
		
		/**
		 * Set the LoaderAnimation if preloading the Main app. Set by MainPreloader. 
		 * @param val
		 */		
		public function set loaderAnimation(val:LoaderAnimation):void {
			_loaderAnimation = val;
		}
		
		/**
		 * Contructor 
		 */		
		public function Main() {
			if(!stage) this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			else onAddedToStage(null);
		}
		
		/**
		 * Main VideoPlayer object
		 */		
		private var _player:VideoPlayer;
		
		/**
		 * Overlay(Lightbox) view 
		 */		
		private var _overlay:Overlay;
		
		/**
		 * App Model
		 */				
		private var _model:Model;
		
		/**
		 *  Container for hotspots
		 */		
		private var _hotpsotRenderer:HotspotRenderer;
		
		/**
		 * 	Container for pictures mapped onto video
		 */		
		private var _pictureRenderer:PictureRenderer;
		
		/**
		 *  Loader Animation AKA Prelaoder
		 */		
		private var _loaderAnimation:LoaderAnimation;
		
		/**
		 * 	House blueprint top-left corner 
		 */		
		private var _floorPlan:FloorPlan;
		
		/**
		 *	Black fullscreen shape for shot and overaly transisitons 
		 */		
		private var _black:Shape;
		
	}
}