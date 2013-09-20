package com.mpc.te.videotour.view {
	
	import com.greensock.TweenMax;
	import com.mpc.te.videotour.model.HotspotRenderModel;
	
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
		
		private const _hotspots:Vector.<HotspotRenderModel> = new Vector.<HotspotRenderModel>();
		
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
	
			for(var i:int = 0; i < _hotspots.length; ++i) {
				_hotspots[i].destroy();
			}
			
			_hotspots.length = 0;
			
			var renderModel:HotspotRenderModel;
			for(i = 0; i < val.length; ++i) {
				renderModel = new HotspotRenderModel(val[i]);
				renderModel.view.clicked.add(onHotpsotClicked);
				_hotspots.push(renderModel);
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
			
			
			const videoWidth:Number = _videoRectangle.width;
			const videoHeight:Number = _videoRectangle.height;
			
			var renderModel:HotspotRenderModel;
			var hotspot:HotspotView;
			
			
			var i:int = 0;
			const l:int = _hotspots.length;
			var keyframes:Vector.<Vector.<Number>>;
			var keyframeA:Vector.<Number>;
			var keyframeB:Vector.<Number>;
			
			while(i < l) {
				
				renderModel = _hotspots[i];
				hotspot = renderModel.view;
				keyframes = renderModel.keyframes;
				
				
				if( playerTime >= keyframes[0][0] && playerTime <= keyframes[ keyframes.length - 1 ][0] ){
				
					// get nearest keyframe (binary search) - takes int( log2(N) + 1 ) steps for dataset size N.
					var j:int = 0;
					var size:int = keyframes.length + 1 >> 1;
					while( size > 0 ){
						var k:int = j + size;
						if( keyframes[ k ][0] < playerTime ) j = k;
						size >>= 1; // half the step size
					}
					
					keyframeA = keyframes[ j ];
					keyframeB = keyframes[ j + 1 ];
					
					if( !keyframeA || !keyframeB ) continue; // might not be defined if things are loading in weird orders.?
					var mf:Number = (playerTime - keyframeA[ 0 ]) / ( keyframeB[ 0 ] - keyframeA[ 0 ]);
					
					var Ax:Number = keyframeA[ 1 ];
					var Ay:Number = keyframeA[ 2 ];
					var Bx:Number = keyframeB[ 1 ];
					var By:Number = keyframeB[ 2 ];
					
					var Px:Number = Ax * (1 - mf) + Bx * mf;
					var Py:Number = Ay * (1 - mf) + By * mf;
					
					var xPos:Number = Px * videoWidth
					var yPos:Number = Py * videoHeight;
					
					if(playerTime < 0.5) {
						addChild(hotspot) ;
					}else {
						addChild(hotspot) ;
						TweenMax.to(hotspot, 0.5, {alpha:1});
					}
					
					hotspot.x = xPos;
					hotspot.y = yPos;
				
				}else{
					if(playerTime < 1) {
						if(contains(hotspot)) removeChild(hotspot);	
					}else if(contains(hotspot)) {
						TweenMax.to(hotspot, .5, {alpha:0, onComplete:function(hotspot:DisplayObject):void {
							if(contains(hotspot)) removeChild(hotspot);		
						}, onCompleteParams:[hotspot]});
					}			
				}
				++i;
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