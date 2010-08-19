package  
{
	import flash.geom.Point;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.events.ProgressEvent;
	
	public class SocketClient
	{
		private static var init : Boolean = false;
		
		private static var socket : Socket;
		
		private static var onOtherPlayerMoveTo : Function;
		private static var onGetPlayerListReturn : Function;
		private static var onOtherPlayerEnterCity : Function;
		private static var onOtherPlayerLeaveCity : Function;
		
		private static function Init () : void
		{
			if (init)
				return;
			
			init = true;
			
			socket = new Socket();
			
			socket.connect("192.168.1.35", 10086);
			
			socket.flush();
			
			socket.addEventListener(ProgressEvent.SOCKET_DATA, OnSocketData);
		}
		
		/******************************************************************************/
		/* Property                                                                   */
		/******************************************************************************/

		public static function set OnOtherPlayerMoveTo (callback : Function) : void
		{
			onOtherPlayerMoveTo = callback;
		}
		
		public static function set OnGetPlayerListReturn (callback : Function) : void
		{
			onGetPlayerListReturn = callback;
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
				// other player enter city
				case 1:
					var playerId1 : int = data.readInt();
					var startX : int = data.readShort();
					var startY : int = data.readShort();
					
					if (onOtherPlayerEnterCity != null)
						onOtherPlayerEnterCity(playerId1, startX, startY);
						
					break;
				
				// other player leave city
				case 2:
					var playerId2 : int = data.readInt();
					
					if (onOtherPlayerLeaveCity != null)
						onOtherPlayerLeaveCity(playerId2);
						
					break;
				
				// on get player list result
				case 3:
					var playerList : Array = new Array();
					
					while (data.bytesAvailable > 0)
					{
						playerList.push(
							{id:data.readInt(), x:data.readShort(), y:data.readShort() }
						);
					}
					
					if (onGetPlayerListReturn != null)
						onGetPlayerListReturn(playerList);
					
					break;
				
				// other player move
				case 4:
					var playerId3 : int = data.readInt();
					var fromX : int = data.readShort();
					var fromY : int = data.readShort();
					var toX : int = data.readShort();
					var toY : int = data.readShort();
					
					onOtherPlayerMoveTo(playerId3, fromX, fromY, toX, toY);
					
					break;
			}
			
			if (socket.bytesAvailable > 0)
			{
				trace(socket.bytesAvailable);
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
		
		public static function GetPlayerList () : void
		{
			Init();
			
			var data : ByteArray = new ByteArray();
			
			data.writeShort(2);			//head
			data.writeShort(3); 		//type
			
			socket.writeBytes(data, 0, data.length);
			
			socket.flush();
		}
		
		public static function MoveTo (fromX : int, fromY : int, toX : int, toY : int) : void
		{
			Init();
			
			var data : ByteArray = new ByteArray();
			
			data.writeShort(10);		//head
			data.writeShort(4); 		//type
			data.writeShort(fromX);
			data.writeShort(fromY);
			data.writeShort(toX);
			data.writeShort(toY);
			
			socket.writeBytes(data, 0, data.length);
			
			socket.flush();
		}
	}
}