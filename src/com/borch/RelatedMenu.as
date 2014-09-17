/**
 * Created with IntelliJ IDEA.
 * User: yeldarb
 * Date: 4/4/12
 * Time: 10:56 AM
 * To change this template use File | Settings | File Templates.
 */
package com.borch {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import org.casalib.layout.Distribution;
	import com.greensock.TweenMax;

	public class RelatedMenu extends MovieClip {
		private var entryXML:XML;
		private var entry:String;

		public function RelatedMenu (_entryXML:XML) {
			super ();
			entryXML = _entryXML;
			addEventListener (Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		private function init (e:Event = null):void {
			removeEventListener (Event.ADDED_TO_STAGE, init);
			addChild (new Backdrop (null, 0xFFFFFF, .7));
			Util.initBtn (CloseBtn);
			Util.initBtn (BackBtn);
			var Dist:Distribution = new Distribution (Field.height, true);
			var fontTitle:String = 'Myriad Pro Bold';
			Dist.marginBottom = 4;
			addChild (Dist);
			Dist.x = 220;
			Dist.y = 210;

			if (entryXML.name ().localName == 'story') {
				if (entryXML.related.hasOwnProperty ('bible')) addMenuButton (entryXML.related.bible.@reference, 'bible', Dist);
				for each (entry in entryXML.related.games.game) addMenuButton (entry, 'game', Dist);
			} else {
				for each (entry in entryXML.related.story) addMenuButton (entry, 'story', Dist);

//				MAKE SUGGESTED LABEL
				var SuggestedLabel:TextField = new TextField ();
				SuggestedLabel.defaultTextFormat = new TextFormat (fontTitle, 16, 0xFFFFFF, true);
				SuggestedLabel.wordWrap = true;
				SuggestedLabel.text = CBRXML.the().xml.relMenu.suggest;
				SuggestedLabel.appendText (' ');
				var goodArray:Array = CBRXML.the().xml.relMenu.good.toString().split(',');
				SuggestedLabel.appendText (goodArray[Util.randomize (goodArray.length)]);
				SuggestedLabel.appendText (' ');
				SuggestedLabel.appendText (CBRXML.the().xml.relMenu.type.@[entryXML.type]);
				SuggestedLabel.width = 350;
				SuggestedLabel.height = SuggestedLabel.textHeight + 5;
				Dist.addChild (SuggestedLabel);

//				GENERATE LIST OF SIMILAR GAMES
				var suggestedGameList:XMLList = CBRXML.the().getGameTypeXML (entryXML.type);
				var randArray:Array = Util.randArray (Math.min (3, suggestedGameList.length ()));
				for each (var ind:int in randArray) addMenuButton (suggestedGameList[ind].title, 'game', Dist);
			}
			Dist.position ();
			addEventListener ('buttonClick', buttonClick, false, 0, true);
		}
		private function buttonClick (e:Event):void {
			TweenMax.to (this, .6, { alpha:0, scaleX:.1, scaleY:.1, onComplete:Destroy.it, onCompleteParams:[this] });

			switch (e.target.name.toUpperCase()) {
				case 'CLOSEBTN':
					GameManager.instance.dispatchEvent (new Event ('resumeGame', true, true));
					break;
				case 'BACKBTN':
					Main.instance.dispatchEvent (new Event ('removeEntry', true, true));
					break;
				default:
					e.target.dispatchEvent (new Event ('relatedEntryButton', true, true));
			}
		}
		private function addMenuButton (entryTitle:String, type:String, Dist:Distribution):void {
			var NewRelEntry:MovieClip = new RelEntryBtn ();
			Util.initBtn (NewRelEntry);
			NewRelEntry.title = entryTitle;
			NewRelEntry.type = type;
			NewRelEntry.Label.text = (type == 'game') ? entryTitle : CBRXML.the().xml.relMenu [type] + ' ' + entryTitle;
			if (type == 'bible') NewRelEntry.bible = entryXML.related.bible;
			NewRelEntry.Label.mouseEnabled = false;
			Dist.addChild (NewRelEntry);
		}
	}
}
