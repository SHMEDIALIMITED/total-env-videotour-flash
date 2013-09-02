package com.mpc.te.videotour
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.mpc.te.videotour.model.HotspotVO;
	import com.mpc.te.videotour.model.Model;
	import com.mpc.te.videotour.service.HTTPService;
	import com.mpc.te.videotour.view.HotspotPool;
	import com.mpc.te.videotour.view.HotspotView;
	import com.mpc.te.videotour.view.StageVideoPlayer;
	
	import flash.display.DisplayObject;
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
			
			// update hotspot tracks
			//var pos;
			var hotspot:Object, vidhotspot:Object;
			for( var i:int = 0; i < hotspots.length; i++ ){
				
				vidhotspot = hotspots[i];
				hotspot = vidhotspot.view;
				
				
				
				if( _player.time >= vidhotspot.keyframes[0][0] && _player.time <= vidhotspot.keyframes[ vidhotspot.keyframes.length - 1 ][0] ){
					
					// get nearest keyframe (binary search) - takes int( log2(N) + 1 ) steps for dataset size N.
					var j:int = 0;
					var size:int = vidhotspot.keyframes.length + 1 >> 1;
					while( size > 0 ){
						var k:int = j + size;
						if( vidhotspot.keyframes[ k ][0] < _player.time ) j = k;
						size >>= 1; // half the step size
					}
					
					var keyframeA:Array = vidhotspot.keyframes[ j ];
					var keyframeB:Array = vidhotspot.keyframes[ j + 1 ];
					
					if( !keyframeA || !keyframeB ) continue; // might not be defined if things are loading in weird orders.?
					var mf:Number = (_player.time - keyframeA[ 0 ]) / ( keyframeB[ 0 ] - keyframeA[ 0 ]);
					
					var Ax:Number = keyframeA[ 1 ];
					var Ay:Number = keyframeA[ 2 ];
					var Bx:Number = keyframeB[ 1 ];
					var By:Number = keyframeB[ 2 ];
					
					var Px:Number = Ax * (1 - mf) + Bx * mf;
					var Py:Number = Ay * (1 - mf) + By * mf;
					
					var xPos:Number = Px * stage.stageWidth;
					var yPos:Number = Py * (stage.stageWidth / 16 * 9);
					
					if(_player.time < 1) {
						//vidtour.css.show( hotspot.objPoint );
						_hotpsotContainer.addChild(hotspot as DisplayObject) ;
					}else {
						
						_hotpsotContainer.addChild(hotspot as DisplayObject) ;
						hotspot.alpha = 0;
						TweenMax.to(hotspot, 0.5, {alpha:1});
						//$(hotspot.objPoint).fadeIn();
					}
					//vidtour.css.setTransform( hotspot.objPoint, 'translate3d(' + (x - hotspot.objPoint.offsetWidth * .5) + 'px, ' + (y - hotspot.objPoint.offsetHeight * .5) + 'px, 0)' );
					hotspot.x = xPos;
					hotspot.y = yPos;
					
					//TweenMax.to(hotspot, .4, {x:xPos, ease:Linear.easeNone});
					//TweenMax.to(hotspot, 0.4, {y:yPos, ease:Linear.easeNone});
					
					
					//				if( hotspot.objLabel ){
					//					pos = this.setLabelPosition( x,y, hotspot.objLabel.offsetWidth, hotspot.objLabel.offsetHeight, videoWidth, videoHeight, vidhotspot.margin, vidhotspot.marginMin, vidhotspot.marginMax );
					//					vidtour.css.show( hotspot.objLabel );
					//					vidtour.css.setTransform( hotspot.objLabel, 'translate3d(' + pos.x + 'px, ' + pos.y + 'px, 0)' );
					//				}
					
				}else{
					if(_player.time < 1) {
						if(_hotpsotContainer.contains(hotspot as DisplayObject)) _hotpsotContainer.removeChild(hotspot as DisplayObject );	
					}else if(_hotpsotContainer.contains(hotspot as DisplayObject)) {
						
						TweenMax.to(hotspot, 0.5, {alpha:0, onComplete:function(hotspot:DisplayObject):void {
							_hotpsotContainer.removeChild(hotspot);
						}, onCompleteParams:[hotspot]});
					}
					
					
				}
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
			
			// Correct hotspot y position
			_hotpsotContainer.y = videoRectangle.y;
		}
		
		private function onHotpsotClicked(hotspot:Object):void {
			stage.removeEventListener(Event.ENTER_FRAME, render);	
			
			
			
			if(hotspot.hotspotType == 1) {
				releaseShot();
				_model.setShotByID(hotspot.target);
			}else {
				// Show Overlay
			}
		}
		
		private function releaseShot():void {
			var hotspots:Array = _model.shot.hotspotTracks;
			var hotspot:Object;
			for(var i:int = 0; i < hotspots.length; ++i) {
				_hotspotPool.returnItem(hotspot.view);
				(hotspot.view as HotspotView).clicked.removeAll();
			}
		}
		
		private function onShotChanged(shot:Object):void {
			
			var hotspots:Array = shot.hotspotTracks;
			var hotspot:Object;
			
			for(var i:int = 0; i < hotspots.length; ++i) {
				hotspot = hotspots[i];
				hotspot.view = _hotspotPool.getItem();
				hotspot.view.text = (hotspot.labelText as String).toUpperCase();
				hotspot.view.model = hotspot;
				(hotspot.view as HotspotView).clicked.add(onHotpsotClicked);
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