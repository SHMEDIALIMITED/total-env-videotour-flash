package com.mpc.te.videotour.model
{
	import com.mpc.te.videotour.view.HotspotView;

	/**
	 * 	HotspotRenderModel for faster rendering
	 * 	It takes an untyped keyframe array to convert it to typed fixed Vector and creates a HotspotView instance for rendering
	 * 	@author patrickwolleb
	 * 
	 */	
	public class HotspotRenderModel {
		
		public var view:HotspotView;
		public var keyframes:Vector.<Vector.<Number>>;
		
		
		/** 
		 * 	@param data Hotspot data as defined in JSON
		 */		
		public function HotspotRenderModel(data:Object) {
			
			view = new HotspotView();
			view.label = (data.labelText as String).toUpperCase();
			view.model = data;
			
			var i:int = 0,
				keyframesArray:Array = data.keyframes,
				keyframeArray:Array,
				l:int = keyframesArray.length,
				keyframe:Vector.<Number>,
				j:int;
			
			keyframes = new Vector.<Vector.<Number>>(l, true);
			
			for(; i < l; ++i) {
				keyframe = keyframes[i] = new Vector.<Number>(3, true);
				keyframeArray = keyframesArray[i]
				for(j = 0; j < keyframeArray.length; ++j) {
					keyframe[j] = keyframeArray[j];
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
			keyframes = null;
			view = null;
		}
	}
}