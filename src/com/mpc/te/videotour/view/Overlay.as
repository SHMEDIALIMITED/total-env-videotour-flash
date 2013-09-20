package com.mpc.te.videotour.view {
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.osflash.signals.Signal;
	
	
	
	public final class Overlay extends Sprite {

		private var _video:VideoPlayer;	
		private var _image:Image;
		private var _remote:RemoteControl;
		private var _closeButton:OverlayCloseButtonView;
		private var _backdrop:Shape;
		private var _text:OverlayTextView;
		private var _loaderAnimation:LoaderAnimation;
		
		private var _imageLoadStarted:Signal;
		private var _imageLoadEnded:Signal;
		private var _hidded:Signal;
		
		private var _rectangle:Rectangle;
		private var _videoRectangle:Rectangle;
		
		public var needsRendering:Boolean;
		
		private const TRANSITION_TIME:Number = 1.0;
		
		// Fake Fade effect if StageVideo available
		private var _videoShape:Shape;
		
		public function Overlay() {
			_video = new VideoPlayer(1);
			_video.bufferingEnded.add(onVideoBufferingEnded);
			addChild(_video);
			_video.visible = false;
			
			_videoShape = new Shape();
			_videoShape.graphics.beginFill(0);
			_videoShape.graphics.drawRect(0,0,10,10);
			addChild(_videoShape);
			
			_backdrop = new Shape();
			var g:Graphics = _backdrop.graphics;
			g.beginFill(0,.8);
			g.drawRect(0, 0, 10, 10);
			addChild(_backdrop);
			
			_image = new Image();
			_image.loaded.add(onImageLoaded);
			addChild(_image);
			_image.visible = false;	
			
			_remote = new RemoteControl();
			_remote.visible = false;
			addChild(_remote);
			
			_closeButton = new OverlayCloseButtonView();
			addChild(_closeButton);
			
			_text = new OverlayTextView();
			addChild(_text);
			
			_loaderAnimation = new LoaderAnimation();
			addChild(_loaderAnimation);
			
			_imageLoadStarted = new Signal();
			_imageLoadEnded = new Signal();
			_hidded = new Signal();
		}
		
		public function show(model:Object):void {
			
			_backdrop.visible = true;
			_backdrop.alpha = 0;
			TweenMax.to(_backdrop, TRANSITION_TIME, {alpha:1});
			
			
			switch(String(model.type)) {
				
				case "1" : // Video
					_videoShape.visible = true;
					_videoShape.alpha = 1;
					_video.alpha = 0;
					
					_text.text = model.text;
					_video.play(model.videoSource[0]);
					
					_video.visible = true;
					_text.visible = true;
					
					break;
					
				case "2" : // Image
					_videoShape.visible = false;
					
					_image.src = model.imageSource;
					_imageLoadStarted.dispatch();
					_text.text = model.text;
					
					_image.alpha = 0;
					
					_image.visible = true;	
					
					_text.visible = true;
					
					needsRendering = true;
					
					break;
				
				case "3" : // Video with Remote Control
					
					_videoShape.visible = true;
					_videoShape.alpha = 1;
					_video.alpha = 0;
					
					_text.text = model.text;
					_video.play(model.videoSource[0]);
					
					_video.visible = true;
					_text.visible = true;
					
					_remote.visible = true;
					_remote.active = true;
					_remote.load(_video, model);
					
					break;
			
				
				
			}
			
			//_loaderAnimation.progress = 0;
			
			
			_closeButton.model = model;
			resize(_rectangle, _videoRectangle);
		}
		
		public function hide(model:Object):void {
			
			TweenMax.to(_backdrop, TRANSITION_TIME, {alpha:0});
			
			switch(String(model.type)) {
				
				case "1" : // Video
					
					TweenMax.to(_videoShape, TRANSITION_TIME, {alpha:1, ease:Linear.easeNone, onComplete: onHidden, onCompleteParams:[model.type]});
					
					break;
				
				case "2" : // Image
					
					TweenMax.to(_image, TRANSITION_TIME, {alpha:0, ease:Linear.easeNone, onComplete: onHidden, onCompleteParams:[model.type]});
					
					break;
				
				case "3" : // Video with Remote Control
					
					TweenMax.to(_videoShape, TRANSITION_TIME, {alpha:1, ease:Linear.easeNone, onComplete: onHidden, onCompleteParams:[model.type]});
					
					break;
				
				
			}
			
			
			
			
		}
		
		private function onHidden(type:String):void {
				
			switch(String(type)) {
				
				case "1" : // Video
					
					_video.stop();
					_video.visible = false;
					
					break;
				
				case "2" : // Image
					
					_image.unload();
					_image.visible = false;
					
					break;
				
				case "3" : // Video with Remote Control
					
					_video.stop();
					_video.visible = false;
					_remote.visible = false;
					_remote.active = false;
					
					break;
				
				
			}
			
			_hidded.dispatch();	
		}
		
		public function resize(rectangle:Rectangle, videoRectangle:Rectangle):void {
			
			_backdrop.width = rectangle.width;
			_backdrop.height = rectangle.height;
			
			_video.resize(videoRectangle);
			
			_image.x = rectangle.x - _image.width * .5;
			_image.y = rectangle.y - _image.height * .5;
			
			_remote.x = videoRectangle.x + 30;
			_remote.y = videoRectangle.y + videoRectangle.height - _remote.height - 30;
			
			_closeButton.x = rectangle.width - _closeButton.width * .5 - 30;
			_closeButton.y = _closeButton.height * .5 + 30;
			
			_text.x = rectangle.width - _text.width - 60;
			_text.y = rectangle.height - _text.height - 60;
			
			_loaderAnimation.x = rectangle.x - 100;
			_loaderAnimation.y = rectangle.y - _loaderAnimation.height * .5;
			
			_rectangle = rectangle;
			_videoRectangle = videoRectangle;
			
			_videoShape.width = videoRectangle.width;
			_videoShape.height = videoRectangle.height + 4;
			_videoShape.x = videoRectangle.x;
			_videoShape.y = videoRectangle.y - 2;
		}
		
		public function render(time:int):void {
			if(_video.buffering) {
				_video.render(time);
			} else if(needsRendering) {
				
			}
			
			if(_remote.active) {
				_remote.update();
			}
		}
		
		private function onVideoBufferingEnded():void {
			_backdrop.visible = false;
			TweenMax.to(_videoShape, TRANSITION_TIME, {alpha:0, ease:Linear.easeNone});
			TweenMax.to(_video, TRANSITION_TIME, {alpha:1, ease:Linear.easeNone});
		}
		
		private function onImageLoaded(image:Image):void {
			TweenMax.to(_image, TRANSITION_TIME, {alpha:1, ease:Linear.easeNone});
			resize(_rectangle, _videoRectangle);
			_imageLoadEnded.dispatch();
		}
		
		public function get closed():Signal {
			return _closeButton.clicked;
		}
		
		public function get videoBufferingStarted():Signal {
			return _video.bufferingStarted;
		}
		
		public function get videoBufferingEnded():Signal {
			return _video.bufferingEnded;
		}
		
		public function get videoBufferProgressed():Signal {
			return _video.bufferProgressed;
		}
		
		public function get imageLoadingStarted():Signal {
			return _imageLoadStarted;
		}
		
		public function get imageLoadingEnded():Signal {
			return _imageLoadEnded;
		}
		
		public function get imageLoadProgressed():Signal {
			return _image.progressed;
		}
		
		public function get hidden():Signal {
			return _hidded;
		}
		
		public function get player():VideoPlayer {
			return _video;
		}
 
	}
}