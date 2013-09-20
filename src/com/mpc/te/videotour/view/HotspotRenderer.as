package com.mpc.te.videotour.view {
	
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.osflash.signals.Signal;
	
	
	/**
	 * 	HotspotRenderer taking care of rendering positions of hotpsots overlaying the current video.
	 * 	The code in the render method has been ported from the JS version written by dean dean@neuroid.co.uk 
	 * 	@author patrickwolleb
	 * 
	 */	
	public final class HotspotRenderer extends Sprite {
		
		private var _model:Array;
		private var _videoRectangle:Rectangle;
		private var _stageRectangle:Rectangle;
		private var _mask:Shape;
		private var _hotspotClicked:Signal;
		
		public function HotspotRenderer() {
			_mask = new Shape();
			addChild(_mask);
			mask = _mask;
			_hotspotClicked = new Signal();
			_model = [];
		}
		
		
		/**
		 * 	Update current shot hotspots array. It removes and destroys current hotpsots and creates new hotspots
		 *	@param val
		 */			
		public function set model(val:Array):void {
	
			var hotspotView:HotspotView;
			
			for(var i:int = 0; i < _model.length; ++i) {
				hotspotView = _model[i].view as HotspotView;
				hotspotView.destroy();
				if(contains(hotspotView))
					removeChild(hotspotView);
			}
			
			
			var hotspot:Object;
			for(i = 0; i < val.length; ++i) {
				hotspot = val[i];
				hotspot.view = new HotspotView()
				hotspot.view.label = (hotspot.labelText as String).toUpperCase();
				hotspot.view.model = hotspot;
				(hotspot.view as HotspotView).clicked.add(onHotpsotClicked);
			}
			
			_model = val;
		}
		
		private function onHotpsotClicked(hotspot:Object):void {
			_hotspotClicked.dispatch(hotspot);
		}
		
		public function resize(stageRectangle:Rectangle, videoRectangle:Rectangle):void {
			_stageRectangle = stageRectangle;
			_videoRectangle = videoRectangle;
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000);
			_mask.graphics.drawRect(0,0,videoRectangle.width, videoRectangle.height);
			_mask.graphics.endFill();
		}
		
		
		/**
		 * 	Updates hotpsot positions
		 * 	@param playerTime
		 * 
		 */		
		public function render(playerTime:Number):void {
			
			const hotspots:Array = _model;
			
			var hotspot:Object, vidhotspot:Object;
			
			for( var i:int = 0; i < hotspots.length; i++ ){
				
				vidhotspot = hotspots[i];
				hotspot = vidhotspot.view;
				
				if( playerTime >= vidhotspot.keyframes[0][0] && playerTime <= vidhotspot.keyframes[ vidhotspot.keyframes.length - 1 ][0] ){
					
					// get nearest keyframe (binary search) - takes int( log2(N) + 1 ) steps for dataset size N.
					var j:int = 0;
					var size:int = vidhotspot.keyframes.length + 1 >> 1;
					while( size > 0 ){
						var k:int = j + size;
						if( vidhotspot.keyframes[ k ][0] < playerTime ) j = k;
						size >>= 1; // half the step size
					}
					
					var keyframeA:Array = vidhotspot.keyframes[ j ];
					var keyframeB:Array = vidhotspot.keyframes[ j + 1 ];
					
					if( !keyframeA || !keyframeB ) continue; // might not be defined if things are loading in weird orders.?
					var mf:Number = (playerTime - keyframeA[ 0 ]) / ( keyframeB[ 0 ] - keyframeA[ 0 ]);
					
					var Ax:Number = keyframeA[ 1 ];
					var Ay:Number = keyframeA[ 2 ];
					var Bx:Number = keyframeB[ 1 ];
					var By:Number = keyframeB[ 2 ];
					
					var Px:Number = Ax * (1 - mf) + Bx * mf;
					var Py:Number = Ay * (1 - mf) + By * mf;
					
					var xPos:Number = Px * _videoRectangle.width;
					var yPos:Number = Py * _videoRectangle.height;
					
					if(playerTime < 0.5) {
						addChild(hotspot as DisplayObject) ;
					}else {
						addChild(hotspot as DisplayObject) ;
						TweenMax.to(hotspot, 0.5, {alpha:1});
					}
					
					hotspot.x = xPos;
					hotspot.y = yPos;
					
					//TweenMax.to(hotspot, .4, {x:xPos, ease:Linear.easeNone});
					//TweenMax.to(hotspot, 0.4, {y:yPos, ease:Linear.easeNone});
				
				}else{
					if(playerTime < 1) {
						if(contains(hotspot as DisplayObject)) removeChild(hotspot as DisplayObject );	
					}else if(contains(hotspot as DisplayObject)) {
						
						TweenMax.to(hotspot, .5, {alpha:0, onComplete:function(hotspot:DisplayObject):void {
							if(contains(hotspot as DisplayObject)) removeChild(hotspot as DisplayObject );		
						}, onCompleteParams:[hotspot]});
					}			
				}
			}
		}
		
		/**
		 * 	HotpsotClickedSignal
		 * 	@return 
		 */		
		public function get hotspotClicked():Signal {
			return _hotspotClicked;
		}
	}
}