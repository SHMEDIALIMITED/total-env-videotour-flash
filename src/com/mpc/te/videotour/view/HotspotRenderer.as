package com.mpc.te.videotour.view {
	
	import com.greensock.TweenMax;
	import com.mpc.te.videotour.model.Model;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public final class HotspotRenderer extends Sprite {
		
		private var _model:Model;
		
		public function set model(val:Model):void {
			_model = val;
		}
		
		public function render(playerTime:Number):void {
			
			const hotspots:Array = _model.shot.hotspotTracks;
			
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
					
					var xPos:Number = Px * stage.stageWidth;
					var yPos:Number = Py * (stage.stageWidth / 16 * 9);
					
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
	}
}