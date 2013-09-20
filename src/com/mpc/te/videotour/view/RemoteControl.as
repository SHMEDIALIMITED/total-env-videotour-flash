package com.mpc.te.videotour.view {
	
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	
	
	/**
	 * 	Remote Control for overlay type 3.
	 * 	It controls the video by seeking to the opositie position. Examine videos 3.f4v and 28_loop.f4v to understand.
	 * 	@author patrickwolleb
	 */	
	public class RemoteControl extends Sprite {
		
		private var _btn1:RemoteControlButtonView;
		private var _btn2:RemoteControlButtonView;
		
		private var _state:int;
		private var _model:Object;
		private var _receiver:VideoPlayer;
		
		public var active:Boolean;
		
		public function RemoteControl() {
			graphics.lineStyle(15);
			graphics.beginFill(0xeeeeee);
			graphics.drawRoundRect(0,0, 280, 200, 10, 10);
			graphics.endFill();
			
			_btn1 = new RemoteControlButtonView();
			_btn1.clicked.add(onAction);
			addChild(_btn1);
			_btn1.x = 30;
			_btn1.y = 65;
			_btn1.id = 1;
			
			_btn2 = new RemoteControlButtonView();
			_btn2.clicked.add(onAction);
			addChild(_btn2);
			_btn2.y = 65;
			_btn2.id = 2;
		}
		
		private function onAction(btn:RemoteControlButtonView):void {
			var seekTime:Number = Math.max(_model.videoLength - _receiver.time, 0);
			if(btn.id == 1 && _state != 1) {
				if(_state == 0) {
					_receiver.resume();
				} else {
					_receiver.seek(seekTime);
				}
			}else if(btn.id == 2 && _state != 2) {
				_receiver.seek(seekTime);
			}	
			if(btn.id == 1) {
				setTimeout(function(state:int):void {
					_state = state;
				}, 1, btn.id);
			}else {
				_state = btn.id;
			}
		}
		
		
		/**
		 * 	Must get called on ENTER_FRAME while playing to observe and pause when the video.time is halfway.
		 */		
		public function update():void {
			
			if(_state == 1 && _receiver.time >= _model.videoLength*.5) {			
				_receiver.pause();
			}
		}
		
		
		/**	
		 *	Load a new set of labels passing the JSON overlay object and the refernce to the receiving video 
		 * 	@param receiver
		 * 	@param model 
		 */		
		public function load(receiver:VideoPlayer, model:Object):void {
			_model = model;
			_state = 0;
			_receiver = receiver;
			_receiver.pause();
			
			_btn1.label = (model.remoteLabel1 as String).toUpperCase();
			_btn2.label = (model.remoteLabel2 as String).toUpperCase();
			_btn2.x = 250 - _btn2.width;
		}
		
	}
}