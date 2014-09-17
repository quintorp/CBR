/**
 * Created with IntelliJ IDEA.
 * User: yeldarb
 * Date: 6/11/12
 * Time: 10:51 AM
 * To change this template use File | Settings | File Templates.
 */
package com.borch {
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.Security;

	public class Preloader extends MovieClip {
		private static var _instance:Preloader;
		private static var _baseURL:String;

		public function Preloader() {
			_instance = this;
			super ();
			stop ();

			_baseURL = unescape (LoaderInfo (this.root.loaderInfo).url);
			_baseURL = _baseURL.substring (0, 1 + _baseURL.lastIndexOf ('/'));
			Security.allowDomain (_baseURL);
trace (_baseURL);
			var clipToLoad:String = LoaderInfo (this.root.loaderInfo).parameters['clipToLoad'];
			for (var key:Object in LoaderInfo (this.root.loaderInfo).parameters) trace (key, LoaderInfo (this.root.loaderInfo).parameters[key])
			addChild (new Backdrop (this, [0x2976C0, 0xA8E8E7], 1));
			var MainLoader:LoaderThing = new LoaderThing (clipToLoad);
			MainLoader.addEventListener ('LOADED', MainLoaded, false, 0, true);
			addChild (MainLoader);
		}
		private function MainLoaded(e:Event):void {
			var MainClip:MovieClip = e.target.contents;
			addChild (MainClip);
		}
		public static function get instance ():Preloader { return _instance; }
		public static function get baseURL ():String { return _baseURL; }
	}
}
