package com.borch {
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;

	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.system.Security;
	import flash.ui.Mouse;
	import flash.utils.getDefinitionByName;

	public class Main extends MovieClip {

		private static var _instance:Main;

//      ENVIRONMENT VARS

//      CLASS OBJECTS & VARS
		private var loadedStories:Array = [];
		private var GroupBtnSet:MovieClip;
		private var GroupBtn:ButtonGroup;
		private var GroupBtnBG:Sprite;
		private var languageXML:XML;
		private var _baseURL:String;

		public function Main():void {
			_instance = this;
			super ();
			(stage) ? init ():addEventListener (Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		private function init(e:Event = null):void {
			removeEventListener (Event.ADDED_TO_STAGE, init);

			_baseURL = unescape (LoaderInfo (this.root.loaderInfo).url);
			_baseURL = _baseURL.substring (0, 1 + _baseURL.lastIndexOf ('/'));
			Security.allowDomain (_baseURL);

			var languageXMLLoader:LoaderThing = new LoaderThing ('languages.xml');
			languageXMLLoader.addEventListener ('LOADED', languageXMLLoaded, false, 0, true);
			addEventListener ('languageSetup', languageSetup, false, 0, true);
			addChild (languageXMLLoader);
		}
		private function languageXMLLoaded (e:Event):void {
			languageXML = XML (e.target.contents);
			CBRXML.the().loadXML (languageXML.lang[0].url, languageXML.lang[0].name);
			interfaceSetup ();
			if (languageXML.lang.length () < 2) {
				MenuLanguage.visible = false;
				return;
			}

			var options:String = '';
			for each (var lang:XML in languageXML.lang) options += lang.name + '|';
			languageXML.popup.options = options.substr (0, options.length - 1);
			addChild( new GamePopup (languageXML.popup, 0, false));
		}
		private function languageSetup (e:Event = null):void {
//			ADD MAIN GROUP BUTTONS
			var ActiveGroup:String = null;
			if (GroupBtnSet) {
//				GET ACTIVE GROUP (IF NOT HOME, i.e. BG NOT AT 0)
				if (GroupBtnSet.getChildIndex (GroupBtnBG)) ActiveGroup = GroupBtnSet.getChildAt (GroupBtnSet.numChildren - 1).name;
				Destroy.it (GroupBtnSet);
			}
			GroupBtnSet = new (getDefinitionByName ('GroupBtns' + CBRXML.the().lang) as Class);
			addChildAt (GroupBtnSet, getChildIndex (Overlay));
			for each (GroupBtn in Util.childArray (GroupBtnSet)) GroupBtn.init ();
			GroupBtnBG = GroupBtnSet.addChild (new Backdrop (GroupBtnSet, [0x2976C0, 0xA8E8E7], 1, true));
			(ActiveGroup) ? GroupBtnSet[ActiveGroup].bringFront () : null;
		}
		private function interfaceSetup():void {
			addEventListener ('buttonClick', buttonClick, false, 0, true);
			addEventListener ('activateGroup', activateGroup, false, 0, true);
			addEventListener ('removeEntry', removeEntry, false, 0, true);
			addEventListener ('relatedEntryButton', getRelatedEntry, false, 0, true);

			var BG:Backdrop = new Backdrop (this, [0x2976C0, 0xA8E8E7], 1);
			addChild (BG);

			Util.initBtn (Overlay.TestNewBtn);
			Util.initBtn (Overlay.TestOldBtn);
			Util.initBtn (MenuGames);
			Util.initBtn (MenuColoring);
			Util.initBtn (MenuStories);
			Util.initBtn (MenuHome);
			Util.initBtn (MenuLanguage);
			Util.asButton (MenuHome, false);
			Util.initBtn (MenuHelp);

			Overlay.TestOldBtn.visible = false;
		}
		private function activateGroup(e:Event):void {
//			EACH OF THE GROUP BUTTONS IS NAMED TO CORRESPOND TO AN XML GROUP
			if (EntryButtonField.instance) Destroy.it (EntryButtonField.instance);
			var layer:int = (StoryManager.instance) ? this.getChildIndex(StoryManager.instance) : this.numChildren;
			addChildAt (new EntryButtonField (CBRXML.the ().xml.groups [e.target.name]), layer - 1);

//			TRANSITION FROM HOME TO GROUP
			TweenMax.fromTo (GroupBtnBG, 3, { autoAlpha:0}, { autoAlpha:1 });
			Util.bringFront (GroupBtnBG);
			TweenMax.to (Overlay, 1.5, { autoAlpha:0 });
			TweenMax.fromTo (EntryButtonField.instance, 2, { alpha:0, scaleX:.2, scaleY:.2}, { alpha:1, scaleX:1, scaleY:1, delay:1 });
			Util.asButton (MenuHome, true);
		}
		private function getRelatedEntry(e:Event):* {
			if (e.target.type == 'bible') return addChild (new Reader (e.target.bible, CBRXML.the().xml.bible + e.target.bible.@reference, parseInt(CBRXML.the().xml.readerBGColor,16),.7));

			var newEntryXML:XML = CBRXML.the().xml.groups.*.*.(title == e.target.title)[0];
			if (!newEntryXML) return trace ('No entry found for related entry button: ' + e.target.name);
			removeEntry ();
			getEntry (newEntryXML);
		}
		public function getEntry (entryObj:Object = 0):void {
			Mouse.show ();
			var Entry:MovieClip,
				entryXML:XML;
			Destroy.it (GamePopup.instance, .7);
			if (entryObj is XML) {
				entryXML = entryObj;
			} else if (entryObj is TextEvent) {
				entryXML = XML (CBRXML.the().xml.groups.*.*.(elements ('id') == entryObj.text));
			} else if (entryObj is int) {
				entryXML = XML (CBRXML.the().xml.groups.*.*.(elements ('id') == entryObj));
			} else if (entryObj is String) {
				entryXML = entryObj;
			}
			Entry = (entryXML.name ().localName == 'game') ? new GameManager (entryXML):new StoryManager (entryXML);
			addChild (Entry);

			Util.bringFront (Frame);
			Util.bringFront (FullScreenBtn);
		}
		private function buttonClick(clickEvent:Event):void {
			var Btn:MovieClip = MovieClip (clickEvent.target);
			if (languageXML.lang.(name == Btn.name).length()) {
				if (Btn.name == CBRXML.the().lang) return;
				CBRXML.the().loadXML (languageXML.lang.(name == Btn.name)[0].url, Btn.name);
				return;
			}

			switch (Btn.name.toUpperCase ()) {
				case 'CLOSE' :
					if (Btn.parent is EntryTypeMenu) Destroy.it (Btn.parent, 0.6);
					break;
				case 'AUTOPLAY' :
					Btn.parent.gotoAndStop (3 - Btn.parent.currentFrame);
					CBRXML.the().autoPlay = Boolean (2 - Btn.parent.currentFrame);
					break;
				case 'MENUSTORIES' :
					addChild (new GamePopup (CBRXML.the().xml.storyGroups, 0, true));
					return;
				case 'HOME' :
				case 'MENUHOME' :
//      			TRANSITION FROM GROUP TO HOME
					removeEntry ();
					GroupBtnSet.dispatchEvent (new Event ('sendBack', true, true));
					TweenMax.to (GroupBtnBG, 2, { autoAlpha:0, delay:1 });
					TweenMax.to (Overlay, 3, { autoAlpha:1, ease:Cubic.easeIn });
					if (EntryButtonField.instance) TweenMax.to (EntryButtonField.instance, 1.5, { alpha:0, onComplete:Destroy.it, onCompleteParams:[EntryButtonField.instance]});
					Util.asButton (MenuHome, false);
					break;
				case 'MENUHELP' :
					addChild (new GamePopup (CBRXML.the().xml.globalHelp, 0, true));
					break;
				case 'TESTOLDBTN' :
					switchTestaments ('prophets');
					break;
				case 'TESTNEWBTN' :
					switchTestaments ('jesus');
					break;
				case 'MENUGAMES' :
					addChild (new GamePopup (CBRXML.the().xml.gameTypes, 0, true));
					break;
				case 'MENULANGUAGE' :
					addChild (new GamePopup (languageXML.popup, 0, false));
					break;
				case 'MENUCOLORING' :
					addChild (new EntryTypeMenu(CBRXML.the().getGameTypeXML ('Coloring'), CBRXML.the().xml.coloringTitle));
					break;
				default :
					var gameOptions:Array = CBRXML.the().xml.gameTypes.options.split ('|');
					if (gameOptions.indexOf (Btn.name) != -1) {
						addChild (new EntryTypeMenu (CBRXML.the().getGameTypeXML (Btn.name), Btn.name + ' ' + CBRXML.the().xml.gameTitle));
					} else {
						var newGroup:XMLList = CBRXML.the().xml.groups.*.(@title == Btn.name);
						if (newGroup.length ()) {
							switchGroups (newGroup[0].name ());
						} else {
							Util.badButtonMessage (this, clickEvent);
						}
					}
					return;
			}
			clickEvent.stopPropagation ();
		}
		private function switchTestaments(newGroupName:String):void {
			var NewTest:Boolean = CBRXML.the().xml.groups [newGroupName].childIndex () >= 6;
			TweenMax.to (GroupBtnSet, .5, {x:-200 * int (NewTest) });
			Overlay.TestOldBtn.visible = NewTest;
			Overlay.TestNewBtn.visible = !NewTest;
		}
		private static function removeEntry(e:Event = null):void {
			Mouse.show ();
			if (StoryManager.instance) {
				StoryManager.instance.dispatchEvent(new Event('stopPlay', true, true));
				Destroy.it (StoryManager.instance, .6);
			}
			if (GameManager.instance) GameManager.instance.dispatchEvent(new Event ('cleanup', true, true));
		}
		public function putInSWFArchive(story:Story):void {
			if (loadedStories [story.url]) return;
			var keys:Array = [];
			for (var key:Object in loadedStories) keys.push (key);
			if (keys.length >= 5) delete loadedStories [keys[0]];
			loadedStories [story.url] = story;
		}
		public function getFromSWFArchive(key:String):Story { return (loadedStories [key]) ? loadedStories [key]:null; }

		public function switchGroups(newGroupName:String):void {
			if (GroupBtnSet.getChildAt (GroupBtnSet.numChildren - 1).name == newGroupName) return;
			GroupBtnSet.dispatchEvent (new Event ('sendBack', true, true));
			switchTestaments (newGroupName);
			TweenMax.delayedCall (.5, activateNewGroup, [GroupBtnSet [newGroupName]]);
		}
		private static function activateNewGroup (NewGroup:ButtonGroup):void {
			NewGroup.dispatchEvent (new Event ('buttonClick', true, true));
		}
		public static function get instance ():Main { return _instance; }
		public function get baseURL ():String { return _baseURL; }
		public function get PrintLogo ():Class { return GOARCH_logo; }
	}
}
