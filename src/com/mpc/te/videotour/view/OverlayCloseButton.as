package com.mpc.te.videotour.view {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	/**
	 *	OverlayCloseButton base class for Flash IDE library export
	 * 	@author patrickwolleb 
	 */	
	public class OverlayCloseButton extends Button {
		
		public var bg:MovieClip;
		
		public function OverlayCloseButton() {
			super();
			bg.stop();
		}
		
		protected override function onMouseOver(e:MouseEvent):void {
			bg.gotoAndPlay(1);
		}
		
		protected override function onMouseOut(e:MouseEvent):void {
			bg.gotoAndPlay(6);	
		}
	}
}