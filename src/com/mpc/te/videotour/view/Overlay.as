package com.mpc.te.videotour.view {
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
		private var _loaderAnimation:LoaderAnimation
		
		private var _rectangle:Rectangle;
		private var _videoRectangle:Rectangle;
		
		public var needsRendering:Boolean;
		
		public function Overlay() {
			_video = new VideoPlayer(1);
			addChild(_video);
			_video.visible = false;
			
			_backdrop = new Shape();
			var g:Graphics = _backdrop.graphics;
			g.beginFill(0,.8);
			g.drawRect(0, 0, 10, 10);
			addChild(_backdrop);
			
			_image = new Image();
			_image.loaded.add(onImageLoaded);
			_image.progressed.add(onProgress);
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
		}
		
		public function show(model:Object):void {
			switch(String(model.type)) {
				
				case "1" : // Video
					_text.text = model.text;
					_video.play(model.videoSource[0]);
					_backdrop.visible = false;
					_video.visible = true;
					_text.visible = true;
					
					break;
					
				case "2" : // Image
					_image.src = model.imageSource;
					_text.text = model.text;
					
					_image.visible = true;	
					_backdrop.visible = true;
					_text.visible = true;
					
					needsRendering = true;
					
					break;
				
				case "3" : // Video with Remote Control
					_text.text = model.text;
					_video.play(model.videoSource[0]);
					_backdrop.visible = false;
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
			switch(String(model.type)) {
				
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
		}
		
		public function resize(rectangle:Rectangle, videoRectangle):void {
			
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
		}
		
		public function render(time:int):void {
			if(_video.buffering) {
				_video.render(time);
			} else if(needsRendering) {
				
			} else if(_remote.active) {
				_remote.update();
			}
		}
		
		private function onProgress(percentage:Number):void {
			//_loaderAnimation.progress = percentage;
		}
		
		private function onImageLoaded(image:Image):void {
			resize(_rectangle, _videoRectangle);
		}
		
		public function get closed():Signal {
			return _closeButton.clicked;
		}
 
	}
}