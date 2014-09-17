package com.borch {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class EntryTypeMenu extends Sprite {
		private var _entryXMLList:XMLList;
		private var _title:String;
		public function EntryTypeMenu(entryXMLList:XMLList, title:String) {
			super ();
			_entryXMLList = entryXMLList;
			_title = title;
			(stage) ? init ():addEventListener (Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		private function init (e:Event = null):void {
			removeEventListener (Event.ADDED_TO_STAGE, init);
//			CREATE GAME LIST HTML
			var entryListHtml:String = '';
			var fontTitle:String = 'Myriad Pro Bold';
			var fontBody:String = 'Myriad Pro Regular';
			for each (var entryXML:XML in _entryXMLList)
				entryListHtml += "<a href='event:" + entryXML.id + "'>" + entryXML.title + '</a>\n';

//          CREATE PIECES OF SELECT OVERLAY
			var Title:TextField = new TextField ();
			addChild (Title);
			Title.defaultTextFormat = new TextFormat (fontTitle, 20, 0xD0D0FF, true, null, null, null, null, 'center');
			Title.text = _title;
			Title.width = 450;
			Title.height = Title.textHeight + 5;
			Title.selectable = false;

			var Field:TextField = new TextField;
			addChild (Field);
			Field.y = Title.height + 10;
			Field.width = 420;
			Field.selectable = false;
			Field.defaultTextFormat = new TextFormat (fontBody, 16, 0xE0E0E0);

			var CSS:StyleSheet = new StyleSheet ();
			var list:Object = new Object ();
			list.leading = '5';
			CSS.setStyle ('list', list);
			var hover:Object = new Object ();
			hover.color = '#FFFFFF';
			CSS.setStyle ('a:hover', hover);
			Field.addEventListener (TextEvent.LINK, getEntry, false, 0, true);
			Field.multiline = true;
			Field.styleSheet = CSS;
			entryListHtml = '<list>' + entryListHtml + '</list>';
			Field.htmlText = entryListHtml;
			Field.height = Math.min (Field.textHeight + 5, stage.stageHeight - 80);

			addChild (new RoundBack ());

			var CloseBtn:CloseButton = new CloseButton ();
			addChild (CloseBtn);
//			CloseBtn.addEventListener (MouseEvent.CLICK, buttonAction, false, 0, true);
//			Util.asButton (CloseBtn, true);

			var Scroller:ScrollBar = new ScrollBar (Field);
			Scroller.update (entryListHtml);

			Center.it (this);
			addChild (new Backdrop (this));
		}
		function getEntry (textEvent:TextEvent){
			Main.instance.getEntry(textEvent);
			Destroy.it (this);
		}
	}
}
