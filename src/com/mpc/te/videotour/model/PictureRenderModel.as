package com.mpc.te.videotour.model
{
	import com.mpc.te.videotour.view.Picture;
	
	/**
	 * 	PictureRenderModel for faster rendering
	 * 	It takes untyped keyframe/clipping arrays to convert them to typed fixed Vectors and creates it a HotspotView instance for rendering
	 * 	@author patrickwolleb
	 * 
	 */	
	public class PictureRenderModel
	{
		public var keyframes:Vector.<Vector.<Number>>;
		public var clippings:Vector.<Vector.<Number>>;
		public var view:Picture;
		
		
		/**
		 * 	@param data PictureTrackingData as defined in JSON
		 */		
		public function PictureRenderModel(data:Object) {
			
			view = new Picture();
			view.alpha = data.opacity;
			view.blur = data.blur;
			view.src = 'img/gandhi.jpg';
			
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
		
		
		/**
		 * 	Removes all references to get object ready for garbage collection
		 */
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
}