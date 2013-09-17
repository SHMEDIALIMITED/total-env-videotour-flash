package com.mpc.te.videotour.view {
	
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	
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
					trace('OPEN:play', seekTime);
				} else {
					
					trace('OPEN:seek', seekTime);
					_receiver.seek(seekTime);
				}
			}else if(btn.id == 2 && _state != 2) {
				//_receiver.play();
				trace('CLOSE:seek', seekTime);
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
		
		public function update():void {
			

			
			if(_state == 1 && _receiver.time >= _model.videoLength*.5) {
				
				trace('PAUSING', _receiver.time)
				_receiver.pause();
			}
		}
		
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