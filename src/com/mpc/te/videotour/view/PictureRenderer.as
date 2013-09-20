package com.mpc.te.videotour.view {
	import com.mpc.te.videotour.model.PictureRenderModel;
	import com.mpc.te.videotour.model.Quad;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	
	
	/**
	 * 	PictureRenderer taking care of rendering positions of hotpsots overlaying the current video.
	 * 	The code in the render method has been ported from the JS version written by dean dean@neuroid.co.uk 
	 * 	@author patrickwolleb
	 * 
	 */	
	public final class PictureRenderer extends Sprite {
		
		private const _pictures:Vector.<PictureRenderModel> = new Vector.<PictureRenderModel>();
		private const quadA:Quad = new Quad();
		private const quadB:Quad = new Quad();
		private const clipQuad:Quad = new Quad();

		private var _videoRectangle:Rectangle;
		private var _stageRectangle:Rectangle;
		private var _mask:Shape;
		
		public function PictureRenderer() {
			_mask = new Shape();
			addChild(_mask);
			mask = _mask;
		}
		
		
		/**
		 * 	Update current shot pictures array. It removes and destroys current photos.
		 *	@param val
		 */	
		public function set model(val:Array):void {
			
			for(var i:int = 0; i < _pictures.length; ++i) {
				_pictures[i].destroy();
			}	
			
			_pictures.length = 0;
			
			for(i = 0; i < val.length; ++i) {
				_pictures.push(new PictureRenderModel(val[i]));
			}
		}
		
		public function resize(stageRectangle:Rectangle, videoRectangle:Rectangle):void {
			_stageRectangle = stageRectangle;
			_videoRectangle = videoRectangle;
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x0000ff);
			_mask.graphics.drawRect(0,0,videoRectangle.width, videoRectangle.height);
			_mask.graphics.endFill();
		}
		
		/**
		 * 	Updates pictures 
		 * 	@param time current video player time.
		 */
		public function render(time:Number):void {
		
			const videoWidth:Number = _videoRectangle.width;
			const videoHeight:Number = _videoRectangle.height;
			const l:int = _pictures.length;
			
			var renderModel:PictureRenderModel;
			var keyframes:Vector.<Vector.<Number>>;
			var clippings:Vector.<Vector.<Number>>;
			var keyframeA:Vector.<Number>;
			var keyframeB:Vector.<Number>;
			var clippingA:Vector.<Number>;
			var clippingB:Vector.<Number>;
			var i:int,j:int,k:int, size:int,mf:Number;
			
			i = 0;
			while (i < l) {
				
				renderModel = _pictures[i];
				keyframes = renderModel.keyframes;
				
				if( time >= keyframes[0][0] && time <= keyframes[ keyframes.length - 1 ][0] ){
					
					// interpolate keyframes
					// get nearest keyframe (binary search) - takes int( log2(N) + 1 ) steps for dataset size N.
					j = 0;
					size = keyframes.length + 1 >> 1;
					while( size > 0 ){
						k = j + size;
						if( keyframes[ k ][0] < time ) j = k;
						size >>= 1; // half the step size
					}
					
					keyframeA = keyframes[ j ];
					keyframeB = keyframes[ j + 1 ];
					
					//if( !keyframeA || !keyframeB ) continue; // might not be defined if things are loading in weird orders.?
					
					mf = (time - keyframeA[ 0 ]) / ( keyframeB[ 0 ] - keyframeA[ 0 ]);
					
					quadA.setFromVector(keyframeA);
					quadB.setFromVector(keyframeB);
					quadA.scale(1-mf, 1-mf);
					quadB.scale(mf, mf);
					quadA.add(quadB);
					quadA.scale(videoWidth, videoHeight);
					renderModel.view.render(quadA);
					addChild(renderModel.view);
					
					
					var clipX0mf:Number = 0;
					var clipX1mf:Number = 1;
					var clipY0mf:Number = 0;
					var clipY1mf:Number = 1;
					if( renderModel.clippings ){
						// apply clipping (if used)
						clippings = renderModel.clippings;
						
						if( time < clippings[0][0] ){
							
							// use clipping position of first data
							j = 0;
							clipX0mf = clippings[ j ][1];
							clipX1mf = clippings[ j ][2];
							clipY0mf = clippings[ j ][3];
							clipY1mf = clippings[ j ][4];
							
						}else
							if( time > clippings[ clippings.length - 1 ][0] ){
								
								// use clipping position of last data
								j = clippings.length - 1;
								clipX0mf = clippings[ j ][1];
								clipX1mf = clippings[ j ][2];
								clipY0mf = clippings[ j ][3];
								clipY1mf = clippings[ j ][4];
								
							}else{
								
								// get interpolated clipping position
								j = 0;
								size = clippings.length + 1 >> 1;
								while( size > 0 ){
									k = j + size;
									if( clippings[ k ][0] < time ) j = k;
									size >>= 1; // half the step size
								}
								clippingA = clippings[ j ];
								clippingB = clippings[ j + 1 ];
								
								mf = (time - clippingA[ 0 ]) / ( clippingB[ 0 ] - clippingA[ 0 ]);
								
								clipX0mf = clippingA[1] * (1 - mf) + clippingB[1] * mf;
								clipX1mf = clippingA[2] * (1 - mf) + clippingB[2] * mf;
								clipY0mf = clippingA[3] * (1 - mf) + clippingB[3] * mf;
								clipY1mf = clippingA[4] * (1 - mf) + clippingB[4] * mf;
								
							}
					}
					
					
					var top:Number = (clipY0mf * quadA.height >>0);
					//var left:Number = (clipX0mf * quadA.width >>0);
					var right:Number = (clipX1mf * quadA.width >>0);
					//var bottom:Number = (clipY1mf * quadA.height >>0);
					
					
					
					clipQuad.Ax = quadA.Ax;
					clipQuad.Ay = quadA.Ay;
					
					clipQuad.Bx = quadA.Bx - (quadA.width - right);
					clipQuad.By = quadA.By - top;
					
					clipQuad.Cx = quadA.Cx;
					clipQuad.Cy = quadA.Cy;
					
					clipQuad.Dx = quadA.Dx - (quadA.width - right);
					clipQuad.Dy = quadA.Dy;
					
					
					
					renderModel.view.updateMask(clipQuad);
					
					
				}else {
					if(contains(renderModel.view)) removeChild(renderModel.view);
				}
				
				++i;
			}
		}		
	}
}