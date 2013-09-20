package com.mpc.te.videotour.model {
	import flash.geom.Point;
	
	/**
	 *	Quad Model 
	 * 	@author patrickwolleb
	 */	
	
	public class Quad {
		
		private const _A:Point = new Point();
		private const _B:Point = new Point();
		private const _C:Point = new Point();
		private const _D:Point = new Point();
		
		
		
		/**
		 * 	Add the quad value to this instance
		 * 	@param quad 
		 */		
		public function add(quad:Quad):void {
			_A.x += quad.A.x;
			_A.y += quad.A.y;
			_B.x += quad.B.x;
			_B.y += quad.B.y;
			_C.x += quad.C.x;
			_C.y += quad.C.y;
			_D.x += quad.D.x;
			_D.y += quad.D.y;
		}
		
		
		/**
		 * 	Sets a keyframe Vector to the quad which is faster than setting coordinates individually
		 * 	@param vector Requires to be length of 9 where first Number is keyframe time and the rest the quad coordinates;
		 */		
		public function setFromVector(vector:Vector.<Number>):void {
			_A.x = vector[1];
			_A.y = vector[2];
			_B.x = vector[3];
			_B.y = vector[4];
			_C.x = vector[5];
			_C.y = vector[6];
			_D.x = vector[7];
			_D.y = vector[8];
		}
		
		/**
		 *	Returns string represantation for debugging
		 * 	@return
		 */		
		public function toString():String {
			var s:String = '';
			s += 'A:' + _A.x + '/' + _A.y + ' - ';
			s += 'B:' + _B.x + '/' + _B.y + ' - ';
			s += 'C:' + _C.x + '/' + _C.y + ' - ';
			s += 'D:' + _D.x + '/' + _D.y + ' - ';
			return s;
		}
		
		
		/**
		 * 	Scale position by scalar
		 * 	@param scaleX
		 * 	@param scaleY
		 */		
		public function scale(scaleX:Number, scaleY:Number):void {
			_A.x *= scaleX;
			_B.x *= scaleX;
			_C.x *= scaleX;
			_D.x *= scaleX;
			
			_A.y *= scaleY;
			_B.y *= scaleY;
			_C.y *= scaleY;
			_D.y *= scaleY;
		}
		
		
		/**
		 * 	Returns maximum width
		 * 	@return  
		 */		
		public function get width():Number {
			return Math.min(_B.x, _D.x) - Math.min(_A.x, _C.x);		
		}
		
		
		/**
		 * 	Returns maximum height
		 * 	@return  
		 */	
		public function get height():Number {
			return Math.min(_C.y, _D.y) - Math.min(_A.y, _B.y);		
		}
		
		
		/**
		 *  Ax as used in JS app
		 */
		public function get Ax():Number {
			return _A.x;
		}
		public function set Ax(val:Number):void {
			_A.x = val;
		}
		
		
		/**
		 *  Ay as used in JS app
		 */
		public function get Ay():Number {
			return _A.y;
		}
		public function set Ay(val:Number):void {
			_A.y = val;
		}
		
		
		/**
		 *  Bx as used in JS app
		 */
		public function get Bx():Number {
			return _B.x;
		}
		public function set Bx(val:Number):void {
			_B.x = val;
		}
		
		
		/**
		 *  By as used in JS app
		 */
		public function get By():Number {
			return _B.y;
		}
		public function set By(val:Number):void {
			_B.y = val;
		}
		
		
		/**
		 *  Cx as used in JS app
		 */	
		public function get Cx():Number {
			return _C.x;
		}
		public function set Cx(val:Number):void {
			_C.x = val;
		}
		
		
		/**
		 *  Cy as used in JS app
		 */	
		public function get Cy():Number {
			return _C.y;
		}
		public function set Cy(val:Number):void {
			_C.y = val;
		}
		
		
		/**
		 *  Dx as used in JS app
		 */
		public function get Dx():Number {
			return _D.x;
		}
		public function set Dx(val:Number):void {
			_D.x = val;
		}
		
		
		/**
		 *  Dy as used in JS app
		 */	
		public function get Dy():Number {
			return _D.y;
		}
		public function set Dy(val:Number):void {
			_D.y = val;
		}
		
		
		/**
		 * 	Top left coordinate point
		 * 	@return  
		 */		
		public function get A():Point {
			return _A;
		}
		
		
		/**
		 * 	Top right coordinate point
		 * 	@return  
		 */
		public function get B():Point {
			return _B;
		}
		
		
		/**
		 * 	Bottom left coordinate point
		 * 	@return  
		 */
		public function get C():Point {
			return _C;
		}
		
		
		/**
		 * 	Bottom right coordinate point
		 * 	@return  
		 */
		public function get D():Point {
			return _D;
		}
	}
}