/**
 * Created by Bradley Borch
 * Activa Digital Media Design
 * http://www.activadesign.com
 * Date: 2/16/12
 * Time: 11:18 AM
 */
package com.borch {
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;

	import flash.display.MovieClip;
	import flash.events.Event;

	public class ButtonGroup extends MovieClip {
		private var Children:Array;
		private var Child:MovieClip;
		private var origin:Object;

		public function ButtonGroup () {
			super ();
		}
		public function init ():void {
			TweenLite.defaultEase = Cubic.easeOut;
			Util.addBtnMaskTo (this);
			Util.initBtn (this);
			addEventListener ('buttonClick', bringFront, false, 0, true);
			Children = Util.childArray (this);
			for each (Child in Children) Child.origin = { iX:Child.x, iY:Child.y, sX:Child.scaleX, sY:Child.scaleY, iR:Child.rotation };
			origin = { iX:x, iY:y, sX:scaleX, sY:scaleY, iR:rotation };
		}
		public function bringFront (event:Event = null):void {
			if (event) event.stopPropagation ();
			parent.addEventListener ('sendBack', sendBack, false, 0, true);
			Util.asButton (this, false, 1);
			TweenMax.to (this, 3, { x:-parent.x, y:-parent.y, scaleX:1, scaleY:1, rotation:0 });
			for each (Child in Children) TweenMax.to (Child, 1.5, { x:0, y:0, scaleX:1, scaleY:1, rotation:0 });
			dispatchEvent (new Event ('activateGroup', true, true));
			Util.bringFront (this);
		}
		private function sendBack (event:Event = null):void {
			if (event) event.stopPropagation ();
			parent.removeEventListener ('sendBack', sendBack);
			TweenMax.to (this, 3, { alpha:.7, x:origin.iX, y:origin.iY, scaleX:origin.sX, scaleY:origin.sY, rotation:origin.iR, onComplete: function () {Util.asButton (this, true)} });
			for each (Child in Children) TweenMax.to (Child, 3, { x:Child.origin.iX, y:Child.origin.iY, scaleX:Child.origin.sX, scaleY:Child.origin.sY, rotation:Child.origin.iR });
		}
	}
}
