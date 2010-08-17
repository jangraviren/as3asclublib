package
{
	//import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import events.AvatarEvent;
	
	import org.asclub.events.TickerEvent;
	
	/**
	 * 
	 * 
	 */
	public class Player extends Avatar
	{
		private var hasPassed:Boolean;
		
		[Embed(source = '../image/shadow.png')]
		private var Shadow:Class;
		
		//===========================================================================================================
		//  Constructor
		//===========================================================================================================
		public function Player(timer:Timer, sourceBitmapDatas:Array, labels:Array)
		{
			super(timer, sourceBitmapDatas, labels);
			var shadow:Bitmap = new Shadow();
			shadow.x = 18;
			shadow.y = 103;
			addChild(shadow);
		}
		
		
		
		//-----------------------------PROTECTED FUNCTION--------------------------------
		
		//时基
		override protected function tickHandler(event:TickerEvent):void
		{
			//trace(position);
			//trace(targetPoint);
			//var tar:Point = targetPoint.add(mouseOffest);//目标坐标
			//var tar:Point = targetPoint;//目标坐标
			var p:Point = targetPoint.subtract(position);//坐标差值
			//trace(event.realDelay);
			
			//在原来的方向上走一段距离
			var step:Number = event.realDelay * speed / 1000;
			//如果移动距离大于单步最大，则进行约束
			if (p.length > step)
				p.normalize(step);
			
			this.position = this.position.add(p);
			
			//如果移动距离小于一定程度，则不进行移动
			if (p.length > 0)
			{
				var avatarEvent:AvatarEvent = new AvatarEvent(AvatarEvent.AVATAR_WALKING);
				avatarEvent.stepPoint = p;
				this.dispatchEvent(avatarEvent);
				//(event as TimerEvent).updateAfterEvent();
			}
			
			//根据差值计算朝向状态
			var newState:String = labelNames[
				(p.x < -Math.abs(p.y / 2) ? 0 : p.x >  Math.abs(p.y / 2) ? 2 : 1) + 
				(p.y <  -Math.abs(p.x / 2)  ? 0 : p.y >  Math.abs(p.y / 2) ? 6 : 3)
			];
			if (newState)
			{
				
				//如果是横板类型游戏
				if (Main.isTabula)
				{
					if (newState.indexOf("right") != -1)
					{
						newState = "right";
					}
					else if (newState.indexOf("left") != -1)
					{
						newState = "left";
					}
					else
					{
						if (_curLabel.indexOf("right") != -1)
						{
							newState = "right";
						}
						else
						{
							newState = "left";
						}
					}
				}
				
				
				if ((int(this.position.x) != int(targetPoint.x)) || (int(this.position.y) != int(targetPoint.y)))
				//if(!targetPoint.equals(new Point(this.position.x - mouseOffest.x,this.position.y - mouseOffest.y)))
				{
					
					newState = "walk" + newState;
					
					hasPassed = false;
				}
				else
				{
					//trace("到达目标点");
					if (!hasPassed)
					{
						hasPassed = true;
						dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_ARRIVE));
					}
				}
				
				changeState(newState);
				
			}
			
		}
		
		
		
		//-----------------------------PUBLIC FUNCTION-----------------------------------
		
		
		override public function moveTo(x:Number, y:Number):void
		{
			targetPoint.x = x;
			targetPoint.y = y;
		}
		
		
		//----------------------------PRIVATE FUNCTION------------------------------------
		private function changeState(state:String):void
		{
			if (_curLabel == state)
				return;
			
			//	trace(state);
			_animation[_curLabel].stop();
			removeChild(_animation[_curLabel]);
			_curPlayingAnimation = _animation[state];
			_curPlayingAnimation.play();
			addChild(_curPlayingAnimation);
			_curLabel = state;
		}
	}//end of class
}