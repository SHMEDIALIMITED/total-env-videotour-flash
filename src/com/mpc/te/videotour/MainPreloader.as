package com.mpc.te.videotour {
	
	import com.mpc.te.videotour.view.LoaderAnimation;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	/**
	 * Preloader
	 * It is compiled into a SWF that is loaded from swfobject.js. This object loads the Main app and addsit to stage.
	 * @author patrickwolleb
	 */	
	
	[SWF(width="1200", height="800", backgroundColor="#000000", frameRate="60")]
	public class MainPreloader extends Sprite {
		
		/**
		 *  Loader Animation AKA Prelaoder
		 */			
		private var _animation:LoaderAnimation;
		
		/**
		 * 	Loader for Main.swf 
		 */		
		private var _loader:Loader;
			
		
		/**
		 *  Constructor creates Loader and LoaderAnimation instances.
		 */		
		public function MainPreloader() {
			_loader = new Loader();
			_animation = new LoaderAnimation();
			addChild(_animation);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 *  AddedToStage is called when MainPreloader has been instanciated.
		 * 	@param e
		 */		
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = 'tl';
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			_loader.load(new URLRequest('Main.swf'));
			_animation.start();
			stage.addEventListener(Event.ENTER_FRAME, render);
		}
		
		/**
		 * LoadComplete is called when Main.swf has been successfully loaded. It adds the Main app to stage and passes the LoaderAnimation reference. 
		 * @param e
		 */		
		private function onLoadComplete(e:Event):void {
			_animation.stop();
			stage.removeEventListener(Event.ENTER_FRAME, render);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			var main:DisplayObject = _loader.content; 
			(main as Object).loaderAnimation = _animation;
			stage.addChildAt(main, 0);	
			stage.removeChild(this);
			_loader = null;
			_animation = null;	
		}
		
		/**
		 * Render is called when ENTER_FRAME event id fired. It updates the LoaderAnimation's progress and layout in case of stage resizing while loading.
		 * @param e
		 */		
		private function render(e:Event):void {
			_animation.x = stage.stageWidth * .5;
			_animation.y = stage.stageHeight * .5;
			_animation.setProgress(_loader.contentLoaderInfo.bytesLoaded / _loader.contentLoaderInfo.bytesTotal);
		}	
	}
}