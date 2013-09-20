package com.mpc.te.videotour.view {
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import flash.display.Sprite;
	
	
	/**
	 *	FloorPlan view presents top down view of house blueprint showing current camera position.
	 * 	@author patrickwolleb
	 * 
	 */	
	public final class FloorPlan extends Sprite {
		
		private var _plan:Sprite;
		private var _image:Image;
		private var _camera:FloorPlanCamera;
		private var _button:FloorPlanButtonView;
		private var _keyframes:Vector.<Vector.<Number>>; 
		private var _currentKeyFrame:Vector.<Number>;
		
		private const X_CORRECTION:Number = 15;
		private const Y_CORRECTION:Number = 11;
		
		public function FloorPlan() {
			
			_plan = new Sprite();
			_plan.visible = false;
			_plan.alpha = 0;
			_plan.y = 30;
			addChild(_plan);
			
			_image = new Image();
			_image.x = 7;
			_image.loaded.add(onImageLoaded);
			_plan.addChild(_image);
			
			_camera = new FloorPlanCamera();
			_plan.addChild(_camera)
			
			_button = new FloorPlanButtonView();
			_button.x = 30;
			_button.label = 'Show Floor Plan';
			addChild(_button);
			_button.clicked.add(onStateChanged);
			
			_keyframes = new Vector.<Vector.<Number>>();
			
			visible = false;
		}	
		
		
		/**
		 *  Updates the floorplan's camera position based on video's playhead time.
		 *	@param time Current shot's video player time
		 */		
		public function update(time:Number):void {
			
			
			const keyframes:Vector.<Vector.<Number>> = _keyframes;
			var i:int = _keyframes.length;
			var keyframe:Vector.<Number>;
			 
			
			while( --i > -1 ) {
				keyframe = keyframes[i];
				if(keyframe[0] > time) {
					break;
				}
			}
			
			if(_currentKeyFrame[0] != keyframe[0]) {
				render(keyframe);
				_currentKeyFrame = keyframe;
			}
		}
		
		/**
		 *	Called when new keyframe has been found. Calculates the delta time between tow keyframes and runs the positional and rotaional tween.
		 * 	@param keyframe Keyframe Vector of fixed length 4 conttains time, x, y, rotation.
		 * 
		 */		
		private function render(keyframe:Vector.<Number>):void {
			var transitionTime:Number = keyframe[0] - _currentKeyFrame[0];
			TweenMax.to(_camera, transitionTime, {x: keyframe[1], y: keyframe[2], rotation:keyframe[3], ease:Linear.easeNone});
		}
		
		
		/**
		 *	Called when new shot video is loaded.
		 * 	Updates plan image and creates fast Vector from data array of keyframes. 
		 * 	@param data
		 * 
		 */		
		public function load(data:Object):void {
			
			_image.src = 'photos/floor-plan' + data.image + '.png';	
			
			if(_keyframes) _keyframes.length = 0;
			var keyframes:Array = data.keyframes, i:int = keyframes.length;
			var fastKeyframe:Vector.<Number>, keyframe:Array;
			while( --i > -1 ) {
				fastKeyframe = new Vector.<Number>(4, true);
				keyframe = keyframes[i] as Array;
				fastKeyframe[0] = keyframe[0];
				fastKeyframe[1] = keyframe[1] + X_CORRECTION;
				fastKeyframe[2] = keyframe[2] + Y_CORRECTION;
				fastKeyframe[3] = keyframe[3];
				_keyframes.push(fastKeyframe);
			}
			_currentKeyFrame = _keyframes[0];
		}
		
		private function onImageLoaded(image:Image):void {
			alpha = 0;
			visible = true;
			TweenMax.to(this, 1, {alpha:1});
		}
		
		/**
		 *  Handles showing and hiding from button click.
		 * 	@param buttonVO
		 * 
		 */		
		private function onStateChanged(buttonVO:Object):void {
			if(!_plan.visible) {
				_plan.visible = true;
				TweenMax.to(_plan, 0.25, {alpha:1});
				TweenMax.to(_button, 0.25, {alpha:0.4});
				_button.label = 'Hide Floor Plan';
			}else{
				_button.label = 'Show Floor Plan';
				TweenMax.to(_button, 0.25, {alpha:1});
				TweenMax.to(_plan, 0.25, {alpha:0, onComplete:function():void {
					_plan.visible = false;
				}});
			}
		}
	}
}