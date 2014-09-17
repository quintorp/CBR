package com.borch {
	import flash.display.MovieClip;
	import flash.events.Event;

	public class ButtonText extends MovieClip {
		public function ButtonText() {
			super ();
			CBRXML.the().buttonLabelRequest(this);
			mouseEnabled = false;
			Label.selectable = Label.mouseEnabled = false;
		}
		public function setLabelText (buttonLabels:XMLList) {
			Label.text = buttonLabels [this.name];
		}
	}
}
