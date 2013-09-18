package com.mpc.te.videotour.view {
	import com.mpc.te.videotour.model.Quad;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public final class PictureRenderer extends Sprite {
		
		private var _model:Array;
		
		private const quad:Quad = new Quad();
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
			_model = [];
		}
		
		public function set model(val:Array):void {
			
			
			
			var photo:Photo;
			for(var i:int = 0; i < _model.length; ++i) {
				photo = _model[i].view as Photo;
				photo.destroy();
				if(contains(photo))
					removeChild(photo);
			}
			
			
			var picture:Object;
			for(i = 0; i < val.length; ++i) {
				picture = val[i];
				picture.view = new Photo();
				picture.view.alpha = picture.opacity;
				picture.view.blur = picture.blur;
				picture.view.src = 'photos/gandhi.jpg';
			}
			
			_model = val;
		}
		
		public function resize(stageRectangle:Rectangle, videoRectangle:Rectangle):void {
			_stageRectangle = stageRectangle;
			_videoRectangle = videoRectangle;
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x0000ff);
			_mask.graphics.drawRect(0,0,videoRectangle.width, videoRectangle.height);
			_mask.graphics.endFill();
		}
		
		public function render(time:Number):void {
			
			
			const pictureTracks:Array = _model;
			
			const videoWidth:Number = _videoRectangle.width;
			const videoHeight:Number = _videoRectangle.height;
			
			var clippingA:Array, clippingB:Array;
			
			// update picture tracks
			var i:int,j:int,k:int, size:int,mf:Number;
			var pic:Photo, vidpic:Object;
			for( i = 0; i < pictureTracks.length; i++ ){
				
				vidpic = pictureTracks[i];
				pic = vidpic.view as Photo;
				
				if( time >= vidpic.keyframes[0][0] && time <= vidpic.keyframes[ vidpic.keyframes.length - 1 ][0] ){
					
					// interpolate keyframes
					
					// get nearest keyframe (binary search) - takes int( log2(N) + 1 ) steps for dataset size N.
					j = 0;
					size = vidpic.keyframes.length + 1 >> 1;
					while( size > 0 ){
						k = j + size;
						if( vidpic.keyframes[ k ][0] < time ) j = k;
						size >>= 1; // half the step size
					}
					var keyframeA:Array = vidpic.keyframes[ j ];
					var keyframeB:Array = vidpic.keyframes[ j + 1 ];
					
					if( !keyframeA || !keyframeB ) continue; // might not be defined if things are loading in weird orders.?
					mf = (time - keyframeA[ 0 ]) / ( keyframeB[ 0 ] - keyframeA[ 0 ]);
					
					
					quadA.Ax = keyframeA[ 1 ];
					quadA.Ay = keyframeA[ 2 ];
					quadA.Bx = keyframeA[ 3 ];
					quadA.By = keyframeA[ 4 ];
					quadA.Cx = keyframeA[ 5 ];
					quadA.Cy = keyframeA[ 6 ];
					quadA.Dx = keyframeA[ 7 ];
					quadA.Dy = keyframeA[ 8 ];
					
					quadB.Ax = keyframeB[ 1 ];
					quadB.Ay = keyframeB[ 2 ];
					quadB.Bx = keyframeB[ 3 ];
					quadB.By = keyframeB[ 4 ];
					quadB.Cx = keyframeB[ 5 ];
					quadB.Cy = keyframeB[ 6 ];
					quadB.Dx = keyframeB[ 7 ];
					quadB.Dy = keyframeB[ 8 ];
					
					quad.Ax = quadA.Ax * (1 - mf) + quadB.Ax * mf;
					quad.Ay = quadA.Ay * (1 - mf) + quadB.Ay * mf;
					quad.Bx = quadA.Bx * (1 - mf) + quadB.Bx * mf;
					quad.By = quadA.By * (1 - mf) + quadB.By * mf;
					quad.Cx = quadA.Cx * (1 - mf) + quadB.Cx * mf;
					quad.Cy = quadA.Cy * (1 - mf) + quadB.Cy * mf;
					quad.Dx = quadA.Dx * (1 - mf) + quadB.Dx * mf;
					quad.Dy = quadA.Dy * (1 - mf) + quadB.Dy * mf;
					
					
					quad.scale(videoWidth, videoHeight);
					pic.render(quad);
					addChild(pic);
					
					
					// apply clipping (if used)
					var clipX0mf:Number = 0;
					var clipX1mf:Number = 1;
					var clipY0mf:Number = 0;
					var clipY1mf:Number = 1;
					if( vidpic.clipping && vidpic.clipping.length ){
						if( time < vidpic.clipping[0][0] ){
							
							// use clipping position of first data
							j = 0;
							clipX0mf = vidpic.clipping[ j ][1];
							clipX1mf = vidpic.clipping[ j ][2];
							clipY0mf = vidpic.clipping[ j ][3];
							clipY1mf = vidpic.clipping[ j ][4];
							
						}else
							if( time > vidpic.clipping[ vidpic.clipping.length - 1 ][0] ){
								
								// use clipping position of last data
								j = vidpic.clipping.length - 1;
								clipX0mf = vidpic.clipping[ j ][1];
								clipX1mf = vidpic.clipping[ j ][2];
								clipY0mf = vidpic.clipping[ j ][3];
								clipY1mf = vidpic.clipping[ j ][4];
								
							}else{
								
								// get interpolated clipping position
								j = 0;
								size = vidpic.clipping.length + 1 >> 1;
								while( size > 0 ){
									k = j + size;
									if( vidpic.clipping[ k ][0] < time ) j = k;
									size >>= 1; // half the step size
								}
								clippingA = vidpic.clipping[ j ];
								clippingB = vidpic.clipping[ j + 1 ];
								
								mf = (time - clippingA[ 0 ]) / ( clippingB[ 0 ] - clippingA[ 0 ]);
								
								clipX0mf = clippingA[1] * (1 - mf) + clippingB[1] * mf;
								clipX1mf = clippingA[2] * (1 - mf) + clippingB[2] * mf;
								clipY0mf = clippingA[3] * (1 - mf) + clippingB[3] * mf;
								clipY1mf = clippingA[4] * (1 - mf) + clippingB[4] * mf;
								
							}
					}
//					var s = ' '; // delimiter. either space or comma depending on browser.
					var top:Number = (clipY0mf * quad.height >>0);
					var left:Number = (clipX0mf * quad.width >>0);
					var right:Number = (clipX1mf * quad.width >>0);
					var bottom:Number = (clipY1mf * quad.height >>0);
//					pic.obj.style.clip = 'rect(' + top +s+ right +s+ bottom +s+ left +s+ ')';
					
					
					
					clipQuad.Ax = quad.Ax;
					clipQuad.Ay = quad.Ay;
					
					clipQuad.Bx = quad.Bx - (quad.width - right);
					clipQuad.By = quad.By - top;
					
					clipQuad.Cx = quad.Cx;
					clipQuad.Cy = quad.Cy;
					
					clipQuad.Dx = quad.Dx - (quad.width - right);
					clipQuad.Dy = quad.Dy;
					
					
					
					pic.updateMask(clipQuad);
					
					
				}else {
					if(contains(pic)) removeChild(pic);
				}
//					
					
			
			}
		}
		
		
	}
}