package com.mpc.te.videotour {
	
	import com.mpc.te.videotour.view.LoaderAnimation;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	
	
	[SWF(width="1200", height="800", backgroundColor="#000000", frameRate="60")]
	public class MainPreloader extends Sprite {
		
		private var _animation:LoaderAnimation;
		private var _loader:Loader;
		private var _stage:Stage;
		
		public function MainPreloader() {
			_loader = new Loader();
			_animation = new LoaderAnimation();
			addChild(_animation);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onLoadComplete(e:Event):void {
			
			_animation.stop()
			
			_stage.removeEventListener(Event.ENTER_FRAME, render);
			_loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			
			
			var main:DisplayObject = _loader.content; 
			(main as Object).loaderAnimation = _animation;
			_stage.addChildAt(main, 0);
				
			_stage.removeChild(this);
			_animation = null;	
		}
		
		
		private function render(event:Event):void {
			_animation.x = stage.stageWidth * .5;
			_animation.y = stage.stageHeight * .5;
			_animation.setProgress(_loader.contentLoaderInfo.bytesLoaded / _loader.contentLoaderInfo.bytesTotal);
		}
		
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = 'tl';
			_stage = stage;
			
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			_loader.load(new URLRequest('Main.swf'));
			_animation.start();
			stage.addEventListener(Event.ENTER_FRAME, render);
		}
		
		
	}
}