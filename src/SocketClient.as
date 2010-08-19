package  
{
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.events.ProgressEvent;
	
	public class SocketClient
	{
		private static var init : Boolean = false;
		
		private static var socket : Socket;
		
		private static var onOtherPlayerMove : Function;
		private static var onOtherPlayerEnterCity : Function;
		private static var onOtherPlayerLeaveCity : Function;
		
		private static function Init () : void
		{
			if (init)
				return;
			
			init = true;
			
			socket = new Socket();
			
			socket.connect("192.168.1.28", 10086);
			
			socket.flush();
			
			socket.addEventListener(ProgressEvent.SOCKET_DATA, OnSocketData);
		}
		
		/******************************************************************************/
		/* Property                                                                   */
		/******************************************************************************/

		public static function set OnOtherPlayerMove (callback : Function) : void
		{
			onOtherPlayerMove = callback;
		}
		
		public static function set OnOtherPlayerEnterCity (callback : Function) : void
		{
			onOtherPlayerEnterCity = callback;
		}
		
		public static function set OnOtherPlayerLeaveCity (callback : Function) : void
		{
			onOtherPlayerLeaveCity = callback;
		}
		
		/******************************************************************************/
		/* Method                                                                     */
		/******************************************************************************/

		private static function OnSocketData (event:ProgressEvent) : void
		{
			var length : int = socket.readShort();
			
			var data : ByteArray = new ByteArray();
			
			socket.readBytes(data, 0, length);
			
			var type : int = data.readShort();
			
			switch (type) 
			{
				// Other player enter city
				case 1:
					var playerId1 : int = data.readInt();
					
					if (onOtherPlayerEnterCity != null)
						onOtherPlayerEnterCity(playerId1);
						
					break;
				
				// Other player leave city
				case 2:
					var playerId2 : int = data.readInt();
					
					if (onOtherPlayerLeaveCity != null)
						onOtherPlayerLeaveCity(playerId2);
						
					break;
				
				// Other player move
				case 3:
					var playerId3 : int = data.readInt();
					var targetX : int = data.readShort();
					var targetY : int = data.readShort();
					
					onOtherPlayerMove(playerId3, targetX, targetY);
					
					break;
			}
		}
		
		public static function SetPlayerId (playerId : int) : void
		{
			Init();
			
			var data : ByteArray = new ByteArray();
			
			data.writeShort(6); 		//head
			data.writeShort(0); 		//type
			data.writeInt(playerId);
			
			socket.writeBytes(data, 0, data.length);
			
			socket.flush();
		}
		
		public static function EnterCity (cityId : int) : void
		{
			Init();
			
			var data : ByteArray = new ByteArray();
			
			data.writeShort(4);			//head
			data.writeShort(1); 		//type
			data.writeShort(cityId);
			
			socket.writeBytes(data, 0, data.length);
			
			socket.flush();
		}
		
		public static function LeaveCity () : void
		{
			Init();
			
			var data : ByteArray = new ByteArray();
			
			data.writeShort(2);			//head
			data.writeShort(2); 		//type
			
			socket.writeBytes(data, 0, data.length);
			
			socket.flush();
		}
		
		public static function Move (targetX : int, targetY : int) : void
		{
			Init();
			
			var data : ByteArray = new ByteArray();
			
			data.writeShort(6);			//head
			data.writeShort(3); 		//type
			data.writeShort(targetX);
			data.writeShort(targetY);
			
			socket.writeBytes(data, 0, data.length);
			
			socket.flush();
		}
	}
}