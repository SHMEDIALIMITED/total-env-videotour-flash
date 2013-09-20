package com.mpc.te.videotour.view {
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
		
		private var _model:Array;
		
		private const _pictures:Vector.<RenderModel> = new Vector.<RenderModel>();
		

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
		
		
		/**
		 * 	Update current shot pictures array. It removes and destroys current photos.
		 *	@param val
		 */	
		public function set model(val:Array):void {
			
			trace('shold be twice', _pictures.length)
			
			for(var i:int = 0; i < _pictures.length; ++i) {
				_pictures[i].destroy();
			}
			
			_pictures.length = 0;
			
			for(i = 0; i < val.length; ++i) {
				_pictures.push(new RenderModel(val[i]));
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
		
		/**
		 * 	Updates pictures 
		 * 	@param time current video player time.
		 */
		public function render(time:Number):void {
		
			const pictureTracks:Array = _model;
			const videoWidth:Number = _videoRectangle.width;
			const videoHeight:Number = _videoRectangle.height;
			
			var clippingA:Vector.<Number>, clippingB:Vector.<Number>;
			
			// update picture tracks
			var i:int,j:int,k:int, size:int,mf:Number;
			
			
			var renderModel:RenderModel;
			i = 0;
			const l:int = _pictures.length;
			
			while (i < l) {
			
				
			
				
				renderModel = _pictures[i];
				
				if( time >= renderModel.keyframes[0][0] && time <= renderModel.keyframes[ renderModel.keyframes.length - 1 ][0] ){
					
					// interpolate keyframes
					
					// get nearest keyframe (binary search) - takes int( log2(N) + 1 ) steps for dataset size N.
					j = 0;
					size = renderModel.keyframes.length + 1 >> 1;
					while( size > 0 ){
						k = j + size;
						if( renderModel.keyframes[ k ][0] < time ) j = k;
						size >>= 1; // half the step size
					}
					var keyframeA:Vector.<Number> = renderModel.keyframes[ j ];
					var keyframeB:Vector.<Number> = renderModel.keyframes[ j + 1 ];
					
					if( !keyframeA || !keyframeB ) continue; // might not be defined if things are loading in weird orders.?
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
						
						
						if( time < renderModel.clippings[0][0] ){
							
							// use clipping position of first data
							j = 0;
							clipX0mf = renderModel.clippings[ j ][1];
							clipX1mf = renderModel.clippings[ j ][2];
							clipY0mf = renderModel.clippings[ j ][3];
							clipY1mf = renderModel.clippings[ j ][4];
							
						}else
							if( time > renderModel.clippings[ renderModel.clippings.length - 1 ][0] ){
								
								// use clipping position of last data
								j = renderModel.clippings.length - 1;
								clipX0mf = renderModel.clippings[ j ][1];
								clipX1mf = renderModel.clippings[ j ][2];
								clipY0mf = renderModel.clippings[ j ][3];
								clipY1mf = renderModel.clippings[ j ][4];
								
							}else{
								
								// get interpolated clipping position
								j = 0;
								size = renderModel.clippings.length + 1 >> 1;
								while( size > 0 ){
									k = j + size;
									if( renderModel.clippings[ k ][0] < time ) j = k;
									size >>= 1; // half the step size
								}
								clippingA = renderModel.clippings[ j ];
								clippingB = renderModel.clippings[ j + 1 ];
								
								mf = (time - clippingA[ 0 ]) / ( clippingB[ 0 ] - clippingA[ 0 ]);
								
								clipX0mf = clippingA[1] * (1 - mf) + clippingB[1] * mf;
								clipX1mf = clippingA[2] * (1 - mf) + clippingB[2] * mf;
								clipY0mf = clippingA[3] * (1 - mf) + clippingB[3] * mf;
								clipY1mf = clippingA[4] * (1 - mf) + clippingB[4] * mf;
								
							}
					}
					
					
					var top:Number = (clipY0mf * quadA.height >>0);
					var left:Number = (clipX0mf * quadA.width >>0);
					var right:Number = (clipX1mf * quadA.width >>0);
					var bottom:Number = (clipY1mf * quadA.height >>0);
					
					
					
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
//					
					
				++i;
			}
		
		
		}
		
		
	}
}
import com.mpc.te.videotour.view.Photo;

class RenderModel {
	
	public var keyframes:Vector.<Vector.<Number>>;
	public var clippings:Vector.<Vector.<Number>>;
	public var view:Photo;
	
	public function RenderModel(data:Object) {
		
		view = new Photo();
		view.alpha = data.opacity;
		view.blur = data.blur;
		view.src = 'photos/gandhi.jpg';
		
		var i:int = 0, 
			l:int = data.keyframes.length,
			keyframe:Vector.<Number>,
			clipping:Vector.<Number>,
			j:int,
			keyframesArray:Array = data.keyframes,	
			keyframeArray:Array,
			clippingsArray:Array,
			clippingArray:Array;
			
		keyframes = new Vector.<Vector.<Number>>(l, true);
		for(; i < l; ++i) {
			keyframe = keyframes[i] = new Vector.<Number>( 9, true);
			keyframeArray = keyframesArray[i];
			for(j = 0; j < 9; ++j) {
				keyframe[j] = keyframeArray[j]; 
			}
		}
		
			
		
		if(data.clipping) {
			i = 0;
			l = data.clipping.length;
			clippingsArray = data.clipping;
			clippings  = new Vector.<Vector.<Number>>( l, true);	
			for(; i < l; ++i) {
				clipping = clippings[i] = new Vector.<Number>(5, true);
				clippingArray = clippingsArray[i];
				for(j = 0; j < 5; ++j) {
					clipping[j] = clippingArray[j];
				}	
			}
		}
	}
	
	public function destroy():void {
		view.destroy();
		var i:int = keyframes.length;
		while( --i > -1 ) keyframes[i] = null;
		if(clippings) {
			i = clippings.length;
			while( --i > -1 ) clippings[i] = null;
			clippings = null;
		}
		keyframes = null;
		view = null;
	}
	
}