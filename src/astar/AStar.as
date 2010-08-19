package astar 
{
	import flash.utils.getTimer;
	
	public class AStar
	{
		//路径耗费固定值
		public static const BIAS_VALUE:int = 14;
		public static const LINE_VALUE:int = 10;
		//纵横方块格数
		public static const WIDTH_NUMBER:int = 50;
		public static const HEIGHT_NUMBER:int = 50;
		//没有任何东西
		public static const NO_THING:int = 0;
		
		private static var _mapArr:Array;
		
		private static var unlockList:Array;
		
		private static var lockList:Object;
		
		private static var targetIX:int;
		
		private static var targetIY:int;
		
		private static var ix:int;
		
		private static var iy:int;
		
		
		
		//public function AStar
		//{
			//trace("静态方法，请勿实例化");
		//}
		
		//===========================================================================================================
		//  Public method
		//===========================================================================================================
		
		/**
		 * 寻路
		 * @param	mapArr      地图数组
		 * @param	endX        目标点的x网格坐标，而非x显示坐标
		 * @param	endY		目标点的y网格坐标，而非y显示坐标
		 * @param	startX		起点的x网格坐标，而非x显示坐标
		 * @param	startY		起点的y网格坐标，而非y显示坐标
		 * @return
		 */
		public static function searchRoad(mapArr:Array, endX:uint, endY:uint, startX:uint, startY:uint):Array
		{
			_mapArr = mapArr;
			
			targetIX = endX;
			
			targetIY = endY;
			
			ix = startX;
			
			iy = startY;
			
			//时间记录
			var startTime:int = getTimer();
			var path:Array = seekRoad();
			var endTime:int = getTimer();
			trace("寻路耗时：" + (endTime - startTime));
			return path;
		}
		
		
		
		
		//===========================================================================================================
		//  Private method
		//===========================================================================================================
		
		private static function seekRoad():Array
		{
			//判断目标点是不是有障碍，或者是不是死路
			//if(c[targetIX][targetIY].isThing || c[targetIX][targetIY].isWalk){
				//return new Array;
			//}
			
			//寻路初始化
			var path:Array = new Array;
			unlockList = new Array();
			lockList = new Object();
			
			//创建开始标记
			var sign:Sign = new Sign(ix,iy,0,0,null);
			lockList[ix + "_" + iy] = sign;
			
			while(true){
				//生成八个方向的标记开启
				addUnlockList(createSign(ix + 1,iy - 1,true ,sign));
				addUnlockList(createSign(ix + 1,iy    ,false,sign));
				addUnlockList(createSign(ix + 1,iy + 1,true ,sign));
				addUnlockList(createSign(ix - 1,iy + 1,true ,sign));
				addUnlockList(createSign(ix    ,iy + 1,false,sign));
				addUnlockList(createSign(ix - 1,iy    ,false,sign));
				addUnlockList(createSign(ix - 1,iy - 1,true ,sign));
				addUnlockList(createSign(ix    ,iy - 1,false,sign));
				
				//判断开启列表是否已经为空
				if(unlockList.length == 0){
					break;
				}
				
				//从开启列表中取出h值最低的标记
				unlockList.sortOn("f",Array.NUMERIC);
				sign = unlockList.shift();
				lockList[sign.ix + "_" + sign.iy] = sign;
				ix = sign.ix;
				iy = sign.iy;
				
				//判断是否找出路径
				if(ix == targetIX && iy == targetIY){
					while(sign != null){
						path.push(sign.getSign());
						sign = sign.p;
					}
					break;
				}
			}
			
			sign = null;
			
			return path.reverse();
			
		}
		
		
		
		//添加到开启标记列表
		private static function addUnlockList(sign:Sign):void{
			if(sign){
				unlockList.push(sign);
				unlockList[sign.ix + "_" + sign.iy] = sign;
			}
		}
		
		//生成标记
		private static function createSign(ix:int,iy:int,p:Boolean,_p:Sign):Sign{
			//是否出格
			if(ix < 0 || iy < 0 || ix >= WIDTH_NUMBER || iy >= HEIGHT_NUMBER){
				return null;
			}
			
			//是否有障碍物
			//if(c[ix][iy].isThing){
				//return null;
			//}
			
			if(_mapArr[ix][iy] != 0){
				return null;
			}
			
			//是否已经加入关闭标记列表
			if(lockList[ix + "_" + iy]){
				return null;
			}
			
			//是否已经加入开启标记列表
			if(unlockList[ix + "_" + iy]){
				return null;
			}
			
			//判断当斜着走的时候，它的上下或者左右是否有障碍物
			if(p){
				if(_mapArr[_p.ix][iy] != 0 || _mapArr[ix][_p.iy] != 0){
					return null;
				}
			}
			
			var cx:Number = Math.abs(targetIX - ix);
			var cy:Number = Math.abs(targetIY - iy);
			return new Sign(ix,iy,
							p ? BIAS_VALUE : LINE_VALUE,
							(cx + cy) * 10,
							_p);
		}
		
		
		
	}//end class
}