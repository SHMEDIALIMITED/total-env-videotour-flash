package com.mpc.te.videotour.view {
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class LoaderAnimation extends Sprite { 
		
		private var _progress:Number;
		private var _asset:MovieClip;
		private const _origin:Point = new Point();
		
		
		public function LoaderAnimation() {
			_asset = new LoaderAnimationView() as MovieClip;
			addChild(_asset);
			this.mouseEnabled = false;
			this.mouseChildren = false;
			alpha = 0;
			
			_origin.x = _asset.circle1.x;
			_origin.y = _asset.circle2.x;
		}
		
		public function start():void {
			TweenMax.killTweensOf(this)
			TweenMax.to(this, 0.5, {alpha:1, ease:Linear.easeNone});
			setProgress(0.0);
			this.mouseEnabled = true;
			_asset.circle1.x = _origin.x;
			_asset.circle2.x = _origin.y;
			TweenMax.to(_asset.circle1, 0.5, {x:12, yoyo:true, repeat:-1, ease:Quad.easeInOut, overwrite:1});
			TweenMax.to(_asset.circle2, 0.5, {x:-12, yoyo:true, repeat:-1, ease:Quad.easeInOut, overwrite:1});
		}
		
		public function stop():void {
			this.mouseEnabled = false;
			TweenMax.to(this, 0.5, {alpha:0, ease:Linear.easeNone, overwrite:1, onComplete:function():void {
				TweenMax.killTweensOf(_asset.circle1);
				TweenMax.killTweensOf(_asset.circle2);
			}});
		}
		
		public function setProgress(val:Number):void {
			_progress = Math.min(val, 1);
			TweenMax.to(_asset.circle1.fill, 0.1, {scaleX: _progress, scaleY:_progress, overwrite:1});
			TweenMax.to(_asset.circle2.fill, 0.1, {scaleX: _progress, scaleY:_progress, overwrite:1});	
		}
		
		public function resize(rectangle:Rectangle):void {
			graphics.clear();
			graphics.beginFill(0, .8);
			graphics.drawRect(-rectangle.x,-rectangle.y,rectangle.width, rectangle.height);
		}
	}
}