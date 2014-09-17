package com.borch {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.sensors.Accelerometer;

	public class CBRXML {
		private static var instance:CBRXML;
		private var _xml:XML;
		private var ButtonsNeedingLabels:Array = [];
		private var _readerTextSizes:Array;
		private var _playerVolumes:Array = [.7, 0];
		private var _autoPlay:Boolean = true;
		private var _showStoryText:Boolean = true;
		private var _lastStoryNum:int;
		private var _lang:String = null;

		public function CBRXML(p_key:SingletonBlocker):void {
			if (p_key == null) {
				throw new Error('Error: Instantiation failed: Use CBRXML.the() instead of new.');
			}
		}
		public static function the():CBRXML {
			if (instance == null) {
				instance = new CBRXML(new SingletonBlocker());
			}
			return instance;
		}
		public function loadXML (url:String, lang:String):void {
			_lang = lang;
			var XMLLoader:LoaderThing = new LoaderThing (url);
			XMLLoader.addEventListener ('LOADED', XMLloaded, false, 0, true);
			Main.instance.addChild (XMLLoader);
		}
		private function XMLloaded (e:Event):void {
			/* This function parses the XML for each entry and looks for a corresponding game XML tag.
			 * If one is found, the various tags associated with that game are added to the entry's XML.
			 * */
			_xml = XML (e.target.contents);
			var entryXML:XML, i:int = 0, j:int = 0, k:int = 0, itemXML:XML = null;
			for each (entryXML in _xml.groups.*.*) {
				if (entryXML.name ().localName == 'game') {
					entryXML.num = i++;
					var gameXref:XMLList = _xml.gamesXref [entryXML.engine];
					for each (itemXML in gameXref.*) (entryXML)[itemXML.name ()] = itemXML;
					if (!entryXML.hasOwnProperty ('options')) entryXML.options = _xml.playOptions.toString();
					if (entryXML.hasOwnProperty ('subtitle')) entryXML.title = entryXML.title + ': ' + entryXML.subtitle;
					if ((entryXML.hasOwnProperty ('source')) && (entryXML.source.indexOf ('.') != -1)) entryXML.URL = Main.instance.baseURL + entryXML.engine + '/' + entryXML.source;
					if (entryXML.hasOwnProperty ('help') && Accelerometer.isSupported) {
						entryXML.help = entryXML.help.toString ().replace (_xml.mobileHelp.arrowKeys.find, _xml.mobileHelp.arrowKeys.replace);
						entryXML.help = entryXML.help.toString ().replace (_xml.mobileHelp.spaceBar.find, _xml.mobileHelp.spaceBar.replace);
//						TODO : mobile help for ArkGame
//						TODO : mobile help for BoatGame
					}
				} else {
					entryXML.num = ++j;
					entryXML.URL = Main.instance.baseURL + _xml.storyPath + entryXML.@num + '.swf';
				}
				entryXML.id = k++;
			}
			_lastStoryNum = j;
//			CREATES A RELATED NODE IN GAME XML
			var relatedGameList:XMLList = _xml.groups.*.story.related.games.game;
			for each (entryXML in _xml.groups.*.game) {
				entryXML.appendChild (<related></related>);
				for each (itemXML in relatedGameList) {
					if (String (itemXML) == String (entryXML.title)) {
						var relatedStorySource:XML = itemXML.parent ().parent ().parent ();
						entryXML.related.appendChild (<story num={relatedStorySource.@num}>{relatedStorySource.title.toString ()}</story>);
					}
				}
			}
			var orphanGames:XMLList = _xml.groups.*.game.related.(!hasOwnProperty ('story'));
			trace (orphanGames.length () + ' ORPHAN GAMES (no corresponding game entry in story:related.)');
			for each (itemXML in orphanGames) trace (itemXML.parent ().toXMLString ());
			for each (var groupXML:XML in _xml.groups.*) {
				for each (itemXML in groupXML.story) itemXML.group = groupXML.name ();
			}
			var groupTitleArray:Array = [];
			for each (var story:XML in _xml.groups.*) groupTitleArray.push (story.@title);
			_xml.storyGroups.options = groupTitleArray.join ('|');
			for each (var Button:ButtonText in ButtonsNeedingLabels) Button.setLabelText (_xml.buttonLabels);

			if (! _readerTextSizes) _readerTextSizes = _xml.readerTextSizes.split (',');
			Main.instance.dispatchEvent (new Event ('languageSetup', true, true));
		}
		public function buttonLabelRequest (requester:Sprite):void {
			ButtonsNeedingLabels.push (requester);
			if (_xml) requester.setLabelText (_xml.buttonLabels);
		}
		public function cycleTextSize (e:Event = null):void {
			_readerTextSizes.push (_readerTextSizes.shift());
			_showStoryText = true;
		}
		public function getGameTypeXML(gameType:String):XMLList {
			return _xml.groups.*.game.(elements ('type') == gameType);
		}
		public function get xml ():XML { return _xml; }
		public function get lang ():String { return _lang; }
		public function get lastStoryNum ():int { return _lastStoryNum; }
		public function get playerVolume ():Number { return _playerVolumes[0]; }
		public function set playerVolume (dummy:Number):void { _playerVolumes.push (_playerVolumes.shift ()); }
		public function get bodyTextSize ():int { return _readerTextSizes[0]; }
		public function get autoPlay ():Boolean { return _autoPlay; }
		public function set autoPlay (value:Boolean):void { _autoPlay = value; }
		public function get showStoryText ():Boolean { return _showStoryText; }
		public function set showStoryText (show:Boolean):void { _showStoryText = show; }
	}
}
internal class SingletonBlocker {}
