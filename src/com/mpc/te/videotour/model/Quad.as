package com.mpc.te.videotour.model {
	
	/**
	 *	Quad Model 
	 * 	@author patrickwolleb
	 */	
	
	public class Quad {
		
		/**
		 *  Ax as used in JS app
		 */		
		public var Ax:Number = 0.0;
		
		
		/**
		 *  Ay as used in JS app
		 */	
		public var Ay:Number = 0.0;
		
		
		/**
		 *  Bx as used in JS app
		 */	
		public var Bx:Number = 0.0;
		
		
		/**
		 *  By as used in JS app
		 */	
		public var By:Number = 0.0;
		
		
		/**
		 *  Cx as used in JS app
		 */	
		public var Cx:Number = 0.0;
		
		
		/**
		 *  Cy as used in JS app
		 */	
		public var Cy:Number = 0.0;
		
		
		/**
		 *  Dx as used in JS app
		 */	
		public var Dx:Number = 0.0;
		
		
		/**
		 *  Dy as used in JS app
		 */	
		public var Dy:Number = 0.0;
		
		
		/**
		 *	Returns string represantation for debugging
		 * 	@return
		 */		
		public function toString():String {
			var s:String = '';
			s += 'A:' + Ax + '/' + Ay + ' - ';
			s += 'B:' + Bx + '/' + By + ' - ';
			s += 'C:' + Cx + '/' + Cy + ' - ';
			s += 'D:' + Dx + '/' + Dy + ' - ';
			return s;
		}
		
		
		/**
		 * 	Scale position by scalar
		 * 	@param scaleX
		 * 	@param scaleY
		 */		
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
		
		
		/**
		 * 	Returns maximum width
		 * 	@return  
		 */		
		public function get width():Number {
			return Math.min(Bx, Dx) - Math.min(Ax, Cx);		
		}
		
		
		/**
		 * 	Returns maximum height
		 * 	@return  
		 */	
		public function get height():Number {
			return Math.min(Cy, Dy) - Math.min(Ay, By);		
		}
	}
}