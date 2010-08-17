package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import org.asclub.display.Animation;
	import org.asclub.display.FrameSequence;
	import org.asclub.events.TickerEvent;
	
	/**
	 * ...
	 * 游戏角色,是游戏中所有角色的抽象类(真实玩家、NPC、怪物等等)
	 */
	public class Avatar extends Sprite
	{
		//当前正在播放的动画
		protected var _curPlayingAnimation:Animation;
		
		//存放每一小段动画的集合(_animation[标签名] = 动画)
		protected var _animation:Object = { };
		
		//当前所播放片段的标签
		protected var _curLabel:String;
		
		//角色的从地图出现时的起始点
		protected var _startPoint:Point;
		
		//角色要去的目标点(当角色到达时，目标点就在角色脚下)
		public var targetPoint:Point;
		
		//角色行走速度(1秒钟150像素)
		public var speed:Number = 150;
		
		//皮肤是否完全载入
		protected var _skinLoadedComlete:Boolean;
		
		public function Avatar(timer:Timer, sourceBitmapDatas:Array, labels:Array)
		{
			
			//动画片段数(一个标签即一个片段)
			var numAnimation:int = labels.length;
			//每个片段帧数
			//var numFrame:int = sourceBitmapDatas.length / numAnimation;
			//驱动动画用的时基
			timer.addEventListener(TickerEvent.TICKER, tickHandler);
			
			for (var i:int = 0; i < numAnimation; i++)
			{
				//每个片段帧数
				var numFrame:int = i + 1 == numAnimation ? (sourceBitmapDatas.length - labels[i].frame + 1) : (labels[i + 1].frame - labels[i].frame);
				var frameSequence:FrameSequence = new FrameSequence(numFrame);
				trace("每个片段帧数:" + numFrame);
				for (var j:int = 0; j < numFrame; j++)
				{
					//trace(sourceBitmapDatas[labels[i].frame + j - 1]);
					frameSequence.setFrameAt(j + 1, sourceBitmapDatas[labels[i].frame + j - 1]);
					//trace(labels[i].frame + j - 1);
					
					
					//frameSequence.setFrameAt(j + 1, sourceBitmapDatas[i * numFrame + j]);
					//trace(i * numFrame + j);
				}
				var animation:Animation = new Animation(timer, frameSequence, timer.delay);
				_animation[labels[i].name] = animation;
			}
			_curLabel = labels[0].name;
			_curPlayingAnimation = _animation[labels[0].name];
			_animation[labels[0].name].play();
			addChild(_curPlayingAnimation);
		}
		
		//九宫格帧标签(角色的八个方向)
		protected const labelNames:Array = [
			"leftup","up","rightup",
			"left",null,"right",
			"leftdown","down","rightdown",
		];
		
		//鼠标偏移量(鼠标偏移量是指角色这个显示对象的原点与角色的脚的坐标偏移量，
		//根据角色的不同而不同，比如角色有坐骑，则偏移点是坐骑的脚)
		public var mouseOffest:Point = new Point( -30, -80);
		
		public var avatarID:String = "";
		
		//===========================================================================================================
		//  GETTER AND SETTER
		//===========================================================================================================
		
		/**
		 * 设置角色名
		 */
		public function set avatarName(value:String):void
		{ 
			throw new Error("请在子类中重写此方法");
		}
		
		/**
		 * 获取角色名
		 */
		public function get avatarName():String
		{ 
			throw new Error("请在子类中重写此方法");
			return "";
		}
		
		/**
		 * 设置角色当前站立的坐标点(一般以脚部为准)
		 */
		public function set position(value:Point):void
		{
			this.x = value.x + mouseOffest.x;
			this.y = value.y + mouseOffest.y;
		}
		
		/**
		 * 获取角色当前站立的坐标点(一般以脚部为准)
		 */
		public function get position():Point
		{
			return new Point(this.x,this.y).subtract(mouseOffest);
		}
		
		/**
		 * 获取角色的从地图出现时的起始点
		 */
		public function get startPoint():Point
		{
			return _startPoint;
		}
		
		/**
		 * 玩家的从地图出现时的起始点
		 */
		public function set startPoint(value:Point):void
		{
			_startPoint = value;
			this.x = value.x + mouseOffest.x;
			this.y = value.y + mouseOffest.y;
		}
		
		/**
		 * 将角色移动到其父级指定位置
		 * @param	x  
		 * @param	y
		 */
		public function moveTo(x:Number, y:Number):void { }
		
		
		/**
		 * 角色更换皮肤
		 * @param	value
		 */
		public function changeSkin(value:Object):void { }
		
		//时基
		protected function tickHandler(event:TickerEvent):void { }
		
	}//end of class
}