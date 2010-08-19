package astar{
	
	public class Sign{
		
		private var _ix:Number;
		private var _iy:Number;
		private var _p:Sign;
		private var _f:int = 0;
		private var _g:int = 0;
		private var _h:int = 0;
		//f表示路径评分、g表示当前移动耗费、h表示当前估计移动耗费
		//公式：f = g + h，表示路径评分的算法
		//ng值表示以父标记为主标记的g值
		//nh值表示当前估计移动耗费
		
		public function Sign(_ix:Number,_iy:Number,ng:int,nh:int,_p:Sign = null){
			this._ix = _ix;
			this._iy = _iy;
			this._p = _p;
			
			if(_p){
				_g = _p.g + ng;
				_h = nh;
				_f = _g + _h;
			}
		}
		
		//获取该标记的坐标
		public function getSign():Object{
			//return {x:_ix * MapData.GRID_WIDTH,y:_iy * MapData.GRID_HEIGHT};
			return {x:_ix,y:_iy};
		}
		
		//获取它表示的x坐标
		public function get ix():int{
			return _ix;
		}
		
		//获取它表示的y坐标
		public function get iy():int{
			return _iy;
		}
		
		//获取父标记
		public function get p():Sign{
			return _p;
		}
		
		//获取路径评分
		public function get f():int{
			return _f;
		}
		
		//获取当前路径移动耗费
		public function get g():int{
			return _g;
		}
		
		//获取当前路径耗费估值
		public function get h():int{
			return _h;
		}
		
		//重写toString值
		public function toString():String{
			return ix + "," + iy;
		}
		
	}
	
}