package com.mpc.te.videotour.model {
	
	public class Quad {
		
		public var Ax:Number = 0.0;
		public var Ay:Number = 0.0;
		
		public var Bx:Number = 0.0;
		public var By:Number = 0.0;
		
		public var Cx:Number = 0.0;
		public var Cy:Number = 0.0;
		
		public var Dx:Number = 0.0;
		public var Dy:Number = 0.0;
		
		
		public function toString():String {
			var s:String = '';
			s += 'A:' + Ax + '/' + Ay + ' - ';
			s += 'B:' + Bx + '/' + By + ' - ';
			s += 'C:' + Cx + '/' + Cy + ' - ';
			s += 'D:' + Dx + '/' + Dy + ' - ';
			return s;
		}
		
		public function scale(scaleX:Number, scaleY:Number):void {
			Ax *= scaleX;
			Bx *= scaleX;
			Cx *= scaleX;
			Dx *= scaleX;
			
			Ay *= scaleY;
			By *= scaleY;
			Cy *= scaleY;
			Dy *= scaleY;
		}
	}
}