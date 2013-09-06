package com.mpc.te.videotour.view {
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.osflash.signals.Signal;
	
	public final class Overlay extends Sprite {

		private var _video:StageVideoPlayer;	
		private var _image:Image;
		private var _closeButton:OverlayCloseButton;
		private var _backdrop:Shape;
		private var _text:OverlayTextView;
		
		private var _rectangle:Rectangle;
		private var _videoRectangle:Rectangle;
		
		public function Overlay() {
			_video = new StageVideoPlayer(1);
			addChild(_video);
			_video.visible = false;
			
			_backdrop = new Shape();
			var g:Graphics = _backdrop.graphics;
			g.beginFill(0,.8);
			g.drawRect(0, 0, 10, 10);
			addChild(_backdrop);
			
			_image = new Image();
			_image.loaded.add(onImageLoaded);
			addChild(_image);
			_image.visible = false;	
			
			_closeButton = new OverlayCloseButton();
			addChild(_closeButton);
			
			_text = new OverlayTextView();
			addChild(_text);
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
					
					break;
				
				case "3" : // Floor Plan
					_backdrop.visible = true;
					_text.visible = false;
					break;
			}
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
				
				case "3" : // Floor Plan
					
					
					break;
			}
		}
		
		public function resize(rectangle:Rectangle, videoRectangle):void {
			
			_backdrop.width = rectangle.width;
			_backdrop.height = rectangle.height;
			
			_video.resize(videoRectangle);
			
			_image.x = rectangle.x - _image.width * .5;
			_image.y = rectangle.y - _image.height * .5;
			
			_closeButton.x = rectangle.width - 21;
			_closeButton.y = _closeButton.height * .5;
			
			_text.x = rectangle.width - _text.width - 60;
			_text.y = rectangle.height - _text.height - 60;
			
			_rectangle = rectangle;
			_videoRectangle = videoRectangle;
			
		}
		
		private function onImageLoaded(image:Image):void {
			resize(_rectangle, _videoRectangle);
		}
		
		public function get closed():Signal {
			return _closeButton.clicked;
		}
 
	}
}