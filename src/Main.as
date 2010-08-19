﻿package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.asclub.engine.Ticker;
	import org.asclub.display.Animation;
	import org.asclub.display.BitmapDataUtil;
	import org.asclub.display.FrameSequence;
	import org.asclub.display.FrameUtil;
	import org.asclub.game.DefaultConfig;
	import org.asclub.system.MonitorKit;
	import org.asclub.net.SWFLibrary;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class Main extends Sprite
	{
		
		//[Embed(source='../image/stand.png')]
		//[Embed(source='../image/stand8.png')]
		//[Embed(source='../image/f.png')]
		[Embed(source='../image/all.png')]
		private var stand:Class;
		//[Embed(source='../image/stand_l.png')]
		//private var stand_l:Class;
		//[Embed(source = '../image/walk.png')]
		//[Embed(source='../image/walk8.png')]
		//[Embed(source='../image/f.png')]
		[Embed(source='../image/walk_t.png')]
		public var walk:Class;
		//[Embed(source = '../image/bg1.jpg')]
		//[Embed(source = '../image/city.jpg')]
		//[Embed(source='../image/bg_new.jpg')]
		[Embed(source = '../image/bjpt.png')]
		private var BG1:Class;
		[Embed(source='../image/bjpt2.png')]
		private var BG2:Class;
		
		[Embed(source = '../image/popup.png')]
		private var Popup:Class;
		
		//是否是横板游戏
		public static const isTabula:Boolean = true;
		
		public static var myAvatarID:int;
		
		//===========================================================================================================
		//  Constructor
		//===========================================================================================================
		
		public function Main()
		{
			
			
			if (stage)
			{
				init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		//===========================================================================================================
		//  Private method
		//===========================================================================================================
		
		//初始化
		private function init(event:Event = null):void
		{
			//
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//DefaultConfig.stageSetting(this.stage);
			
			//载入swf ui 库
			var gameAssets:SWFLibrary = new SWFLibrary();
			//gameAssets.load("../swf/lib.swf");
			gameAssets.load("lib.swf");
			gameAssets.addEventListener(Event.COMPLETE, gameAssetsLoadedCompleteHandler);
		}
		
		//===========================================================================================================
		//  Event Handlers
		//===========================================================================================================
		
		//游戏ui资源载入完毕时触发
		private function gameAssetsLoadedCompleteHandler(event:Event):void
		{
			//先模拟一个地图数据
			var mapData:Object = { };
			mapData["pathArray"] = [];
			mapData["numX"] = 50;
			mapData["numY"] = 13;
			
			//for (var y1:int = 0; y1 < 13; y1++)
			//{
				//mapData["pathArray"][y1] = [];
				//for (var x1:int = 0; x1 < 50; x1++)
				//{
					//mapData["pathArray"][y1][x1] = 1;
				//}
			//}
			//
			//for (var y2:int = 7; y2 < 13; y2++)
			//{
				//mapData["pathArray"][y2] = [];
				//for (var x2:int = 0; x2 < 50; x2++)
				//{
					//mapData["pathArray"][y2][x2] = 0;
				//}
			//}
			
			for (var x1:int = 0; x1 < 50; x1++)
			{
				mapData["pathArray"][x1] = [];
				for (var y1:int = 0; y1 < 13; y1++)
				{
					mapData["pathArray"][x1][y1] = 0;
				}
			}
			
			MapData.setMapData(mapData, "map0001");
			
			
			for (var y4:int = 0; y4 < mapData["numY"]; y4++)
			{
				for (var x4:int = 0; x4 < mapData["numX"]; x4++)
				{
					//trace("y:" + y4 + "x" + x4 + ":" + mapData["pathArray"][y4][x4]);
				}
			}
			
			
			//myAvatarID = (Math.random() * 10000 >> 0);
			myAvatarID = new Date().getTime();
			
			//添加地图到舞台
			var gameMap:Maps = new Maps(stage.stageWidth, stage.stageHeight);
			gameMap.addEventListener(Event.ADDED_TO_STAGE, mapAddToStage);
			addChild(gameMap);
			
			//
			var popup:Bitmap = new Popup();
			addChild(popup);
			
			//添加内存占用观察器
			var monitorKit:MonitorKit = new MonitorKit("MKMODE_TR");
			addChild(monitorKit);
		}
		
		//地图被添加到舞台上时触发		
		private function mapAddToStage(event:Event):void
		{
			trace("mapAddToStage");
			var standImage:Bitmap = new stand();
			//var standLeftImage:Bitmap = new stand_l();
			//var walkImage:Bitmap = new walk();
			var bg1:Bitmap = new BG1();
			var bg2:Bitmap = new BG2();
			bg1.smoothing = true;
			
			//动画分段
			//var labels:Array = FrameUtil.createFromObject({
				//"down":1,"left":9,"right":17,"up":25,
				//"leftdown":33,"rightdown":41,"leftup":49,"rightup":57,
				//"walkdown":65,"walkleft":73,"walkright":81,"walkup":89,
				//"walkleftdown":97,"walkrightdown":105,"walkleftup":113,"walkrightup":121
			//});
			
			var labels:Array = FrameUtil.createFromObject({
				"right":1,"left":9,"walkright":17,"walkleft":25
			});
			
			var standBitmapDatas:Array = BitmapDataUtil.separateBitmapData(standImage.bitmapData, 100, 120);
			var allBitmapDatas:Array = standBitmapDatas.concat();
			var animationTimer:Ticker = new Ticker(70);
			animationTimer.start();
			
			
			var t1:int = getTimer();
			//event.currentTarget.setBG(bg1.bitmapData, "bg1");
			event.currentTarget.setBG([ { bitmap:bg2, vx:0.8 }, { bitmap:bg1, vx:1 } ], "map0001");
			trace("设置背景耗时:" + (getTimer() - t1));
			
			
			function addAvatar(playerID:String, startX:int, startY:int):void
			{
				var testPlayer:Player = new Player(animationTimer, allBitmapDatas, labels);
				testPlayer.avatarID = playerID;
				testPlayer.mouseOffest = new Point( -40, -110);
				testPlayer.avatarName = playerID;
				event.currentTarget.addAvatar(testPlayer, startX, startY);
			}
			
			SocketClient.SetPlayerId(myAvatarID);
			SocketClient.EnterCity(1);
			
			
		
			//玩家进入的时候
			SocketClient.OnOtherPlayerEnterCity = 
				function (playerId : int, startX:int, startY:int) : void {
					trace("玩家进入的时候playerId" + playerId + "x:" + startX + "y:" + startY);
					addAvatar(String(playerId), startX, startY);
				};
				//
			//玩家移动的时候
			SocketClient.OnOtherPlayerMoveTo = 
				function (playerId : int, fromX:int, fromY:int, toX:int, toY:int) : void {
					trace(
						"Player " + playerId + " move to {" + toX + ", " + toY + "}\n"
					);
					
					if (playerId != myAvatarID)
					{
						//event.currentTarget.getAvatarByID(String(playerId)).moveTo(fromX,fromY);
						event.currentTarget.getAvatarByID(String(playerId)).position.x = fromX;
						event.currentTarget.getAvatarByID(String(playerId)).position.y = fromY;
						event.currentTarget.getAvatarByID(String(playerId)).moveTo(toX, toY);
					}
				};
				//
			//玩家离开的时候
			SocketClient.OnOtherPlayerLeaveCity = 
				function (playerId : int) : void {
					trace("Player " + playerId + " leave city!\n");
					
					var s:Boolean = event.currentTarget.removeAvatar(String(playerId));
					trace("移除玩家是否成功:" + s);
					
				};
				
				
			//接收当前已经在此场景中的角色
			SocketClient.OnGetPlayerListReturn = 
				function (playerList : Array) : void {
					trace("接收当前已经在此场景中的角色:" + playerList);
					var numAvatar:int = playerList.length;
					for (var i:int = 0; i < numAvatar; i++ )
					{
						//if (String(playerList[i]["id"]) != myAvatarID)
						//{
							trace("playerID:" + String(playerList[i]["id"]));
							addAvatar(String(playerList[i]["id"]), playerList[i]["x"], playerList[i]["y"]);
						//}
					}
					
				};
			SocketClient.GetPlayerList();
			
			//自己的出生地
			//var startPointX:int = Math.random() * 200 + 300;
			//var player:Player = new Player(animationTimer, allBitmapDatas, labels);
			//player.avatarID = String(myAvatarID);
			//player.mouseOffest = new Point( -40, -110);
			//event.currentTarget.addAvatar(player, startPointX, 400);
			
			//添加测试人物
			for (var j:int = 0; j < 0; j++)
			{
				var testPlayer:Player = new Player(animationTimer, allBitmapDatas, labels);
				testPlayer.avatarID = "008";
				event.currentTarget.addAvatar(testPlayer, Math.random() * bg1.width + 50, Math.random() * 30 + 300);
			}
			
			
		}
		
	}//end of class
}