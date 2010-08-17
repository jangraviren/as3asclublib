package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class MapEvent extends Event
	{
		//地图切换
		public static  const CHANGE_MAP:String = "changeMap";
		
		private var _nextMapId:uint;
		
		public function MapEvent(type:String) 
		{
			super(type);
		}
		
		public function set nextMapId(changeId:uint):void 
		{
			_nextMapId = changeId;
		}
		
		public function get nextMapId():uint
		{
			return _nextMapId;
		}
	}//end class
}