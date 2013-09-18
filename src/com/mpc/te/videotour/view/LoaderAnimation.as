package com.mpc.te.videotour.view {
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class LoaderAnimation extends Sprite { 
		
		private var _progress:Number;
		private var _asset:MovieClip;
		
		public function LoaderAnimation() {
			_asset = new LoaderAnimationView() as MovieClip;
			addChild(_asset);
			this.mouseEnabled = false;
			this.mouseChildren = false;
			alpha = 0;
		}
		
		public function start():void {
			TweenMax.to(this, 0.5, {alpha:1, ease:Linear.easeNone});
			setProgress(0.0);
			TweenMax.to(_asset.circle1, 0.5, {x:12, yoyo:true, repeat:-1, ease:Quad.easeInOut});
			TweenMax.to(_asset.circle2, 0.5, {x:-12, yoyo:true, repeat:-1, ease:Quad.easeInOut});
		}
		
		public function stop():void {
			TweenMax.to(this, 0.5, {alpha:0, ease:Linear.easeNone, onComplete:function():void {
				TweenMax.killTweensOf(_asset.circle1);
				TweenMax.killTweensOf(_asset.circle2);
			}});
		}
		
		public function setProgress(val:Number):void {
			_progress = Math.min(val, 1);
			TweenMax.to(_asset.circle1.fill, 0.1, {scaleX: _progress, scaleY:_progress});
			TweenMax.to(_asset.circle2.fill, 0.1, {scaleX: _progress, scaleY:_progress});
			
		}
	}
}