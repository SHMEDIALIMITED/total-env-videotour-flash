package com.mpc.te.videotour.view {
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Linear;
	
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	
	/**
	 *	Hotspot base class for Flash IDE library export
	 * 	@author patrickwolleb 
	 */
	public class Hotspot extends Button {
		
		public var txt:TextField;
		public var innerRing:MovieClip;
		public var outerRing:MovieClip;
		private var _underline:Shape;
		
		public function Hotspot() {
			_underline = new Shape();
			
			addChild(_underline);
			alpha = 0;
			txt.autoSize = TextFieldAutoSize.LEFT;
		}
		
		public override function set model(val:Object):void{
			super.model = val;
			if(val.hotspotType == "2") {
				txt.visible = false;
				_underline.visible = false;
				_underline.alpha = 0;
				txt.alpha = 0;
			}
		}
		
		public function set label(val:String):void {
			txt.htmlText = val.toUpperCase();
			txt.x = _underline.x = -txt.width * .5;
			_underline.y = txt.y + txt.height - 5;
			var g:Graphics = _underline.graphics;
			g.clear();
			g.lineStyle(1, 0xffffff, 1, true);
			g.lineTo(txt.width,0);
		}
		
		protected override function onMouseOver(e:MouseEvent):void {
			txt.visible = true;
			_underline.visible = true;
			animateRings();
			TweenMax.to(this.txt, .2, {alpha:1, ease:Linear.easeNone});
			TweenMax.to(_underline, .2, {alpha:1, ease:Linear.easeNone});		
		}
		
		protected override function onMouseOut(e:MouseEvent):void {
			
			if(_model.hotspotType == "2") {
				TweenMax.to(txt, .2, {alpha:0, ease:Linear.easeNone, onComplete:function():void {
					txt.visible = false;
				}});
				
				TweenMax.to(_underline, .2, {alpha:0, ease:Linear.easeNone, onComplete:function():void {
					_underline.visible = false;
				}});
			}	
		}
		
		private function animateRings():void {
			TweenMax.to(innerRing, 0.2, {scaleX:1.2, scaleY:1.2, ease:Cubic.easeOut, onComplete:function():void{
				TweenMax.to(innerRing, 0.2, {scaleX:1, scaleY:1, ease:Cubic.easeOut});
			}});
			TweenMax.to(outerRing, 0.2, {scaleX:1.2, scaleY:1.2, ease:Cubic.easeOut, delay:.1, onComplete:function():void{	
				TweenMax.to(outerRing, 0.2, {scaleX:1, scaleY:1, ease:Cubic.easeOut});
			}});
		}
		
		public override function destroy():void {
			super.destroy();
			if(parent) parent.removeChild(this);
			TweenMax.killTweensOf(innerRing);
			TweenMax.killTweensOf(outerRing);
			_underline.graphics.clear();
			removeChild(_underline);
			txt = null;
			innerRing = null;
			outerRing = null;
		}
		
	}
}