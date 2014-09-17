package com.borch {

	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.text.StyleSheet;
	import flash.text.TextField;

	import mx.utils.NameUtil;

	public class Story extends MovieClip {

		private var Content:MovieClip;

//		SCROLLING FIELD VARS
		private var ScrollField:TextField;
		private var scrollHTML:XML = <main></main>;
		private var scrollStartY:Number;
		private var scrollRange:int;
		private var padFrames:int;
		private var playingNow:Boolean = false;
		private var _url:String;
		private static const SCROLL_OFFSET:int = 40;
		private static var styles:StyleSheet = new StyleSheet ();

		public function Story (url:String):void {
			super ();
			_url = url;
//			mouseEnabled = mouseChildren = false;
			addEventListener (Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		private function init (e:Event = null):void {
			removeEventListener (Event.ADDED_TO_STAGE, init);
			var StoryLoader:LoaderThing = new LoaderThing (_url);
			StoryLoader.addEventListener ('LOADED', setupContent, false, 0, true);
			addChild (StoryLoader);
		}
		private function setupContent (e:Event):void {
			Content = e.target.contents;

//          ADD MASK
			var Mask:Shape = addChild (new Shape);
			Mask.graphics.beginFill (0);
			Mask.graphics.drawRect (0, 0, 550, 400);
			Mask.graphics.endFill ();
			Content.mask = Mask;
			addChild (Content);

			setupScrollField ();
			addEventListener ('startPlay', startPlay, false, 0, true);
			addEventListener ('stopPlay', stopPlay, false, 0, true);

			StoryManager.instance.activateNewStory (this);
			Content.visible = true;
		}
		private function setupScrollField ():void {
			if (!Content.TextBG) return;
			var fldIndex:int = Content.numChildren;
			while (--fldIndex) if (Content.getChildAt (fldIndex) is TextField) break;
			if (fldIndex == 0) return;

			// MAKE NEW SCROLLING FIELD AND SET TO ORIGINAL FIELD PARAMS
			ScrollField = Content.getChildAt (fldIndex);
			scrollStartY = ScrollField.y;
			padFrames = Content.totalFrames - SCROLL_OFFSET * 2;

			scrollHTML.title = ScrollField.text.substring (0, ScrollField.text.indexOf ('\r'));
			scrollHTML.body = ScrollField.text.substring (ScrollField.text.indexOf ('\r'), ScrollField.text.lastIndexOf ('\r'));
			scrollHTML.ref = ScrollField.text.substring (ScrollField.text.lastIndexOf ('\r'));
			ScrollField.htmlText = scrollHTML.toXMLString ();

			// ADD HTML TEXT WITH CSS TO NEW FIELD
			styles.setStyle ('main', { leading:-1, fontFamily:'Trebuchet MS', color:0 });
			styles.setStyle ('title', { color:'#1F6600', fontSize:18 });
			styles.setStyle ('ref', { color:0x333333, fontStyle:'italic', fontSize:11, textAlign:'center' });
			updateStyles ();
			addEventListener (Event.ADDED_TO_STAGE, updateStyles, false, 0, true);
			addEventListener ('updateStory', updateStory, false, 0, true);
			addEventListener ('updateStyles', updateStyles, false, 0, true);
		}
		private function updateStyles (e:Event = null):void {
			styles.setStyle ('body', { fontSize:[CBRXML.the().bodyTextSize] });
			ScrollField.htmlText = scrollHTML.toXMLString ();
			ScrollField.styleSheet = styles;
			ScrollField.htmlText = scrollHTML.toXMLString ();
			ScrollField.height = ScrollField.textHeight + 5;
			scrollRange = int (ScrollField.height - 130);
			updateStory ();
			setTextVisibility ();
		}
		public function setTextVisibility (vis:Boolean = true):void {
			if (ScrollField) ScrollField.visible = Content.TextBG.visible = vis;
		}
		public function gotoFrame (frame:Number):void {
			var gotoFunction:Function = (playingNow) ? Content.gotoAndPlay:Content.gotoAndStop;
			gotoFunction (Math.round (Content.totalFrames * frame));
		}
		private function startPlay (e:Event = null):void {
			addEventListener (Event.ENTER_FRAME, updateStory, false, 0, true);
			Content.play ();
			playingNow = true;
//			(Capabilities.playerType == 'External') ? Content.gotoAndPlay (Content.totalFrames - 80):Content.play ();
		}
		private function stopPlay (e:Event = null):void {
			playingNow = false;
			removeEventListener (Event.ENTER_FRAME, updateStory);
			Content.stop ();
			if (e) e.stopImmediatePropagation ();
		}
		private function updateStory (e:Event = null):void {
			if (Content.currentFrame >= Content.totalFrames) {
				Content.gotoAndStop (1);
				stopPlay ();
				dispatchEvent (new Event ('storyAtEnd', true, true));
			}
			StoryManager.instance.setMarkerPosition (Number (Content.currentFrame / Content.totalFrames));
			if (ScrollField) ScrollField.y = scrollStartY - scrollRange * Util.inRange ((Content.currentFrame - SCROLL_OFFSET) / padFrames, 0, 1);
		}
		public function get url ():String { return _url; }
	}
}
