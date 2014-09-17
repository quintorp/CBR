package com.borch {

	import org.casalib.display.CasaMovieClip;

	public class EntryManager extends CasaMovieClip {
		protected static var _instance:EntryManager;
		protected var _entryXML:XML;
		public function EntryManager (entryXML:XML) {
			_instance = this;
			_entryXML = entryXML;
			super();
		}
		public function get entryXML ():XML { return _entryXML; }
		public function set entryXML (xml):void { _entryXML = xml; }
	}
}
