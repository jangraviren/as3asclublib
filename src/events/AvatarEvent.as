package events 
{
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class AvatarEvent extends Event
	{
		//角色行走时
		public static const AVATAR_WALKING:String = "avatarWalking";
		
		//角色到达目标点
		public static const AVATAR_ARRIVE:String = "avatarArrive";
		
		//每次移动的x、y轴上的距离
		public var stepPoint:Point;
		
		public function AvatarEvent(type:String)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new AvatarEvent(AvatarEvent.AVATAR_WALKING);
		}
		
	}//end class
}