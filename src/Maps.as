package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import events.AvatarEvent;
	import astar.AStar;
	
	import org.asclub.display.DrawUtil;
	import org.asclub.display.FrameUtil;
	import org.asclub.utils.ReflectUtil;
	
	
	public class Maps extends Sprite
	{
		//地图网格数据
		private var _mapArray:Array;
		
		//背景缓存 关联数组
		private var _bgMaps:Dictionary;
		
		//角色缓存 关联数组
		private var _avatarMaps:Dictionary;
		
		//背景层各位图速率
		private var _bgBitmapSpeed:Array = [];
		
		//地图可显示区域
		private var _range:Rectangle;
		
		//可见区域宽度
		private var _rangeWidth:Number = 0;
		
		// 可见区域高度
		private var _rangeHeight:Number = 0;
		
		//背景区域宽度(因为多个背景层的移动速度不一致，背景层坐标位置也不一致，通过_bgLayer.width 获得的是移位后扩大的背景宽度)
		private var _bgWidth:Number;
		
		
		//背景层(因为背景可能不止一层,所以不用bitmap而用Sprite)
		private var _bgLayer:Sprite;
		//背景位图层
		//private var _bgBitmapLayer:Bitmap;
		
		//传送门图层
		private var _transmissionGateLayer:Sprite;
		
		//热区层(某些区域可点击，角色可活动,而某些区域不可点击，角色不可活动)
		private var _activeLayer:Sprite;
		//可活动区域
		private var _interactiveArae:InteractiveObject;
		//不可活动区域
		private var _uninteractiveArae:InteractiveObject;
		
		//角色层
		private var _avatarLayer:Sprite;
		
		//效果层（鼠标效果等等）
		private var _effectLayer:Sprite;
		
		//玩家自己
		private var _myself:Avatar;
		
		//鼠标在地图上可点击时的效果
		private var _clickEffectMc:MovieClip;
		
		//鼠标在地图上不可点击时的效果
		private var _noClickEffectMc:MovieClip;
		
		
		//===========================================================================================================
		//  Constructor
		//===========================================================================================================
		
		/**
		 * 构造函数
		 * @param	rangeWidth    可见区域宽度
		 * @param	rangeHeight   可见区域高度
		 */
		public function Maps(rangeWidth:Number,rangeHeight:Number)
		{
			_rangeWidth = rangeWidth;
			_rangeHeight = rangeHeight;
			
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
		//  Public method
		//===========================================================================================================
		
		/**
		 * 设置地图背景
		 * @param	bg:Object  ,bg可能为显示对象，也可能是字符串(先搜索类定义，如未搜索到而认为是url地址，再进行下载)
		 * 如果bg是数组的话，则结构为[{bitmap:位图/位图数据,vx:x轴上的速度}]，vx > 1,则移动速度比正常速度快，vx = 1，
		 * 为正常速度，vx < 1,则比正常速度慢
		 * @param	id
		 */
		public function setBG(bg:Object,mapID:String):void
		{
			
			_mapArray = MapData.getMapData(mapID)["pathArray"];
			
			//如果背景已经缓存
			if(_bgMaps[mapID])
			{
				
			}
			
				//_bgBitmapSpeed.length = 0;
				//removeBgLayerChild();
			
				if (bg is String)
				{
					
					
				}
				//如果bg为数组,则背景可能不止一层
				else if (bg is Array)
				{
					var numLayer:int = (bg as Array).length;
					for (var i:int = 0; i < numLayer; i++)
					{
						_bgBitmapSpeed.push(bg[i]["vx"]);
						setBG(bg[i]["bitmap"],mapID);
					}
				}
				//当bg为BitmapData,则背景只有一层
				else if (bg is BitmapData || bg is Bitmap)
				{
					addBgLayerBitmap(bg);
					_interactiveArae.width = _bgLayer.width;
					_interactiveArae.height = _bgLayer.height;
				}
				_bgWidth = _bgLayer.width;
			trace("_bgLayer.numChildren:" + _bgLayer.numChildren);
		}
		
		public function changeMap():void
		{
			
		}
		
		/**
		 * 添加游戏角色
		 * @param	avatar
		 * @param	x
		 * @param	y
		 */
		public function addAvatar(avatar:Avatar, x:Number, y:Number):void
		{
			//如果缓存中有就不重复添加
			if (!(avatar.avatarID in _avatarMaps))
			{	
				//刚添加到地图上时，起点==终点
				avatar.startPoint = new Point(x, y);
				//avatar.targetPoint = avatar.startPoint.subtract(avatar.mouseOffest);
				avatar.targetPoint = avatar.startPoint;
				_avatarLayer.addChild(avatar);
				//如果角色ID等于自己的ID，则这个角色就是自己
				if (avatar.avatarID == String(Main.myAvatarID))
				{
					_myself = avatar;
					//将自己所在的位置移动到显示区域中央(如果玩家的出生地在地图右侧，而显示区域只显示左侧区域，这时就看不到玩家自己)
					var stepX:Number = x - _rangeWidth * 0.5;
					stepX = stepX < 0 ? 0 : (stepX > _bgWidth - _rangeWidth ? _bgWidth - _rangeWidth : stepX);
					var stepY:Number = y - _rangeHeight * 0.5;
					stepY = stepY < 0 ? 0 : (stepY > _bgLayer.height - _rangeHeight ? _bgLayer.height - _rangeHeight : stepY);
					//trace("stepX:" + stepX, "  stepY:" + stepY);
					//_range.x = stepX;
					//_range.y = stepY;
					//this.scrollRect = _range;
					
					updateSceneScrollRect(new Point(stepX, stepY));
					//移动过程监听
					_myself.addEventListener(AvatarEvent.AVATAR_WALKING, myselfWalkingHandler);
					//移动到目标点时监听
					_myself.addEventListener(AvatarEvent.AVATAR_ARRIVE, myselfWalkingArriveHandler);
				}
			}
		}
		
		/**
		 * 通过角色ID获取角色实例
		 * @param	avatarID
		 * @return
		 */
		public function getAvatarByID(avatarID:String):Avatar
		{
			if (!(avatarID in _avatarMaps))
			{
				return null;
			}
			return _avatarMaps[avatarID];
		}
		
		/**
		 * 移除游戏角色
		 * @param	avatarID
		 * @return
		 */
		public function removeAvatar(avatarID:String):Boolean
		{
			if (!(avatarID in _avatarMaps))
			{
				return false;
			}
			
			_avatarLayer.removeChild(_avatarMaps[avatarID]);
			_avatarMaps[avatarID] = null;
			
			return true;
		}
		
		/**
		 * 添加传送门
		 * @param	tg
		 * @param	x
		 * @param	y
		 */
		public function addTransmissionGate(tg:*, x:Number, y:Number):void
		{
			
		}
		
		/**
		 * 移除地图上所有元素
		 */
		public function removeAll():void
		{
			
		}
		
		//===========================================================================================================
		//  Private method
		//===========================================================================================================
		
		
		
		//初始化
		private function init(event:Event = null):void
		{
			//移除监听
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//地图可见区域
			_range = new Rectangle(0, 0, _rangeWidth, _rangeHeight);
			this.scrollRect = _range;
			
			//缓存角色 的 关联数组
			_avatarMaps = new Dictionary();
			
			//存放背景 的 关联数组
			_bgMaps = new Dictionary();
			
			_bgLayer = new Sprite();
			
			_transmissionGateLayer = new Sprite();
			
			_activeLayer = new Sprite();
			_interactiveArae = new Sprite();
			DrawUtil.drawRoundRect((_interactiveArae as Sprite).graphics, 100, 100, 0xff0000, -1, 0, 0, 0);
			_interactiveArae.addEventListener(MouseEvent.CLICK, interactiveAraeClickedHandler);
			_activeLayer.addChild(_interactiveArae);
			//_activeLayer.addChild(_uninteractiveArae);
			
			//角色层
			_avatarLayer = new Sprite();
			
			//效果层
			_effectLayer = new Sprite();
			addClickEffect();
			addNoClickEffect();
			
			this.addChild(_bgLayer);
			this.addChild(_transmissionGateLayer);
			this.addChild(_activeLayer);
			this.addChild(_avatarLayer);
			this.addChild(_effectLayer);
		}
		
		//可活动区域被点击的时候，只有自己会走动
		private function interactiveAraeClickedHandler(event:MouseEvent):void
		{
			//先将自己在可活动区域的坐标转为this(maps)的坐标
			//var parentPoint:Point = this.localToGlobal(new Point(event.currentTarget.mouseX, event.currentTarget.mouseY));
			//再将this(maps)的坐标转为角色层的坐标
			//var targetPoint:Point = _avatarLayer.globalToLocal(parentPoint);
			
			//_myself.moveTo(targetPoint.x, targetPoint.y);
			
			var clickedX:int = Math.floor(this.mouseX/MapData.ISO_W);
			var clickedY:int = Math.floor(this.mouseY / MapData.ISO_H);
			
			var nowX:int = Math.floor(_myself.position.x / MapData.ISO_W);
			var nowY:int = Math.floor(_myself.position.y / MapData.ISO_H);
			
			
			trace("现在所在网格x:" + nowX);
			trace("现在所在网格y:" + nowY);
			trace("鼠标点击x：" + clickedX);
			trace("鼠标点击y：" + clickedY);
			
			if (_mapArray[clickedX][clickedY] == 0)
			{
				showClickEffect();
				_myself.moveTo(this.mouseX, this.mouseY);
				//var walkArray:Array = SearchRoad.startSearch(_mapArray, clickedX, clickedY, nowX, nowY);
				var walkArray:Array = AStar.searchRoad(_mapArray, clickedX, clickedY, nowX, nowY);
				if (walkArray)
				{
					trace("路径长度:" + walkArray.length);
					for (var i:* in walkArray)
					{
						trace("x:" + walkArray[i]["x"] / 50 + "  y:" + walkArray[i]["y"] / 50);
					}
				}
				else
				{
					trace("死路一条");
				}
				
			}
			else
			{
				trace("不能点击");
				showNoClickEffect();
			}
		}
		
		//自己走动时触发(以为只有当玩家自己走动时背景才会跟随相应运动)
		private function myselfWalkingHandler(event:AvatarEvent):void
		{
			updateSceneScrollRect(event.stepPoint);
		}
		
		//角色移动到目标点时触发
		private function myselfWalkingArriveHandler(event:AvatarEvent):void
		{
			hideClickEffect();
		}
		
		//更新场景可见矩形滚动区域
		private function updateSceneScrollRect(stepPoint:Point):void
		{
			//如果背景高度比显示高度高，当角色进行纵向走动时，则进行滚动
			if (_bgLayer.height > _rangeHeight)
			{
				//为什么多这个判断，其实我也不知道，前几天写的时候忘了注释，等想起来补上
				if (this.scrollRect.y > (_rangeHeight - _bgLayer.height))
				//if (true)
				{
					_range.y += stepPoint.y;
					//trace("_range.y:" + _range.y,"   stepPoint.y:" + stepPoint.y);
					//如果位移增量大于0则向下走
					if (stepPoint.y > 0)
					{
						//如果角色还没跑过可见区域的一半，背景则静止不滚动
						if ((_myself.position.y) < _range.height * 0.5)
						{
							_range.y = 0;
						}
						
						//当背景滚动到末端时，背景则静止不滚动
						if (_range.y > _bgLayer.height - _range.height)
						{
							_range.y = _bgLayer.height - _range.height;
						}
					}
					else
					{
						//角色从背景末端开始往回跑，如果角色还没跑过可见区域的一半，背景则静止不滚动
						if ((_myself.position.y) > (_bgLayer.height - _range.height * 0.5))
						{
							//trace("角色从背景末端开始往回跑");
							_range.y = _bgLayer.height - _range.height;
						}
						//如果位移增量小于0则向上走
						if (_range.y < 0)
						{
							_range.y = 0;
						}
					}
				}
			}
			
			//如果背景宽度比显示宽度宽，当角色进行横向走动时，则进行滚动,否则不进行滚动
			if (_bgWidth > _rangeWidth)
			{
				if (this.scrollRect.x > (_rangeWidth - _bgWidth))
				{
					_range.x += stepPoint.x;
					//如果位移增量大于0则向右走
					if (stepPoint.x >= 0)
					{
						//如果角色还没跑过可见区域的一半，背景则静止不滚动
						if ((_myself.position.x) < _range.width * 0.5)
						{
							_range.x = 0;
						}
						
						//当背景滚动到末端时，背景则静止不滚动
						if (_range.x > _bgWidth - _range.width)
						{
							_range.x = _bgWidth - _range.width;
						}
					}
					else
					{
						//角色从背景末端开始往回跑，如果角色还没跑过可见区域的一半，背景则静止不滚动
						if ((_myself.position.x) > (_bgWidth - _range.width * 0.5))
						{
							_range.x = _bgWidth - _range.width;
						}
						//如果位移增量小于0则向左走
						if (_range.x < 0)
						{
							_range.x = 0;
						}
					}
				}
			}
			//trace("_range.x:::" + _range.x);
			//trace("this.scrollRect.x:::" + this.scrollRect.x);
			relocationBgLayer(_range.x - this.scrollRect.x);
			this.scrollRect = _range;
		}
		
		//给背景层添加位图
		private function addBgLayerBitmap(value:Object):void
		{
			if (value is Bitmap)
			{
				_bgLayer.addChild(value as Bitmap);
				return;
			}
			else if (value is BitmapData)
			{
				var bitmap:Bitmap = new Bitmap(value as BitmapData);
				_bgLayer.addChild(bitmap);
			}
		}
		
		//移除背景层上的所有子显示对象
		private function removeBgLayerChild():void
		{
			var numChild:int = _bgLayer.numChildren;
			for (var i:int = numChild - 1; i > -1; i--)
			{
				_bgLayer.removeChildAt(i);
			}
		}
		
		//背景位图层重新定位
		private function relocationBgLayer(value:Number):void
		{
			var numLayer:int = _bgBitmapSpeed.length;
			var numChild:int = _bgLayer.numChildren;
			if (numLayer == 0 || numChild != numLayer)
			{
				return;
			}
			for (var i:int = 0; i < numLayer; i++)
			{
				//_bgLayer.getChildAt(i).x += (1 - _bgBitmapSpeed[i]) * value;
				//
				_bgLayer.getChildAt(i).x = (1 - _bgBitmapSpeed[i]) * this.scrollRect.x * 0.8;
				//trace(_bgLayer.getChildAt(i).x);
			}
		}
		
		//添加鼠标在地图上点击时的效果
		private function addClickEffect():void
		{
			var ref:Class = ReflectUtil.getDefinitionByName("ClickEffectMc");
			if (ref)
			{
				_clickEffectMc = new ref();
				_clickEffectMc.visible = false;
				_clickEffectMc.gotoAndStop(1);
				_effectLayer.addChild(_clickEffectMc);
			}
		}
		
		//显示鼠标在地图上点击时的效果
		private function showClickEffect():void
		{
			if (_clickEffectMc)
			{
				_clickEffectMc.visible = true;
				_clickEffectMc.x = this.mouseX;
				_clickEffectMc.y = this.mouseY;
				_clickEffectMc.gotoAndPlay(1);
			}
		}
		
		//隐藏鼠标在地图上点击时的效果
		private function hideClickEffect():void
		{
			if (_clickEffectMc)
			{
				_clickEffectMc.visible = false;
				_clickEffectMc.gotoAndStop(1);
			}
		}
		
		//添加鼠标在地图上不可点击时的效果
		private function addNoClickEffect():void
		{
			var ref:Class = ReflectUtil.getDefinitionByName("NoClickEffectMc");
			if (ref)
			{
				_noClickEffectMc = new ref();
				_noClickEffectMc.visible = false;
				_noClickEffectMc.gotoAndStop(1);
				FrameUtil.addFrameScript(_noClickEffectMc, _noClickEffectMc.totalFrames, noClickEffectMcPlayOver);
				_effectLayer.addChild(_noClickEffectMc);
			}
		}
		
		//显示鼠标在地图上点击时的效果
		private function showNoClickEffect():void
		{
			if (_noClickEffectMc)
			{
				_noClickEffectMc.visible = true;
				_noClickEffectMc.x = this.mouseX;
				_noClickEffectMc.y = this.mouseY;
				_noClickEffectMc.gotoAndPlay(1);
			}
		}
		
		//不可点击影片剪辑播放完毕
		private function noClickEffectMcPlayOver():void
		{
			_noClickEffectMc.visible = false;
			_noClickEffectMc.gotoAndStop(1);
		}
		
	}//end of class
}