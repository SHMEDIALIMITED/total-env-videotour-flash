package com.mpc.te.videotour.controller {
	import com.mpc.te.videotour.controller.signal.ResizeSignal;
	import com.mpc.te.videotour.model.ResizeVO;
	import com.mpc.te.videotour.view.VideoPlayerMediator;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	
	import fl.video.FLVPlayback;
	
	import org.robotlegs.mvcs.Context;
	import org.robotlegs.mvcs.SignalContext;

	
	
	
	public class AppContext extends Context {
		
		
		private const APP_MIN_WIDTH:Number = 400;
		private const APP_MIN_HEIGHT:Number = 300;
		
		private var _resized:ResizeSignal;
		private var _resizeVO:ResizeVO;
		
		
		public function AppContext(contextView:DisplayObjectContainer) {
			super(contextView)
		}

		
		public override function startup():void {
			
			
			trace('HERE', contextView)
			
			super.startup();
			mediatorMap.mapView(FLVPlayback, VideoPlayerMediator);
			
			// Resize signal dispatched on Resize 
			_resized = new ResizeSignal();
			_resizeVO = new ResizeVO(0, 0, APP_MIN_WIDTH, APP_MIN_HEIGHT);
			contextView.stage.addEventListener(Event.RESIZE, onResize);
			
			
			
			onResize();
		}
		
		private function onResize(e:Event=null):void {
			var stage:Stage = this.contextView.stage;
			_resizeVO.width = stage.stageWidth;
			_resizeVO.height = stage.stageHeight;
			_resized.dispatch(_resizeVO);
		}
	}
}