package com.borch {
	import com.greensock.TweenMax;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;

	import org.casalib.layout.Distribution;

	public class EntryButtonField extends Sprite {
		private static var _instance:EntryButtonField;
		public function EntryButtonField (groupXML:XMLList) {
			_instance = this;
			x = 780;
			y = 100;
			alpha = 0;

//			ADD DISTRIBUTION FOR ENTRY BUTTONS TO FIELD
			var EntryBtnDist:Distribution = new Distribution (this.width);
			addChild (EntryBtnDist);

//          ADD NEW ENTRY BUTTONS
			var NewEntryBtn:Sprite;
			for each (var entryXML:XML in groupXML.story) {
				NewEntryBtn = new StoryEntryButton;
				NewEntryBtn.entryXML = entryXML;
				EntryBtnDist.addChild (NewEntryBtn);
				NewEntryBtn.name = NewEntryBtn.entryXML.title;
				Util.initBtn (NewEntryBtn);
				Util.shrinkTextToFit (NewEntryBtn.Label);
				Util.addBtnMaskTo (NewEntryBtn);
				NewEntryBtn.addEventListener (MouseEvent.ROLL_OVER, entryBtnHandler, false, 0, true);
				NewEntryBtn.addEventListener (MouseEvent.ROLL_OUT, entryBtnHandler, false, 0, true);
				NewEntryBtn.addEventListener (MouseEvent.CLICK, entryBtnHandler, false, 0, true);
			}
			EntryBtnDist.position ();
			Center.it (EntryBtnDist, this, 0, -180, 48);
		}
		private function entryBtnHandler(m:MouseEvent):void {
			m.stopPropagation ();
			var EntryBtn:Sprite = m.currentTarget;
			switch (m.type) {
				case 'rollOver' :
					TweenMax.to (EntryBtn, .3, {scaleX:1.2, scaleY:1.2 });
					EntryBtn.filters = [new GlowFilter (0xFF8800, 1, 8, 8)];
					return;
				case 'rollOut' :
					TweenMax.to (EntryBtn, .3, {scaleX:1, scaleY:1, glowFilter:{ } });
					return;
				case 'click' :
					Main.instance.getEntry (EntryBtn.entryXML);
					break;
			}
		}
		public static function get instance():EntryButtonField { return _instance; }
	}
}
