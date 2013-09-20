package com.mpc.te.videotour.view {
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	
	/**
	 *	RemoteControlButton base class for Flash IDE library export
	 * 	@author patrickwolleb 
	 */	
	public class RemoteControlButton extends Button {
		
		public var bg:MovieClip;
		public var txt:TextField;
		
		public var id:int;
		
		public function RemoteControlButton() {
			super();
			bg.stop();
			txt.autoSize = TextFieldAutoSize.LEFT;
		}
		
		protected override function onMouseDown(e:MouseEvent):void {
			_clicked.dispatch(this);
		}
		
		public function set label(val:String):void {
			txt.text = val.toUpperCase();
			bg.width = txt.width + 24;
		}
		
		protected override function onMouseOver(e:MouseEvent):void {
			bg.gotoAndPlay(1);
			TweenMax.to(txt, 0.5, {tint:0});
		}
		
		protected override function onMouseOut(e:MouseEvent):void {
			bg.gotoAndPlay(6);
			TweenMax.to(txt, 0.5, {removeTint:true});
		}
	}
}