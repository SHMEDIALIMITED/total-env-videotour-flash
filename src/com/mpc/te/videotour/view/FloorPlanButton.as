package com.mpc.te.videotour.view {
	import com.greensock.TweenMax;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class FloorPlanButton extends Button {
		
		public var bg:MovieClip;
		public var txt:TextField;
		
		public function FloorPlanButton() {
			super();
			
			trace('LLLLLLHEHEHEHEHE')
			
			bg.stop();
			TweenPlugin.activate([TintPlugin]);
		}
		
		public function set label(val:String):void {
			txt.text = val.toUpperCase();
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