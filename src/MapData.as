package  
{
	import flash.utils.Dictionary;
	
	
	/**
	 * 
	 * 
	 */
	public class MapData 
	{
		//地图元素的宽度
		public static  const ISO_W:uint = 50;
		//地图元素的高度
		public static  const ISO_H:uint = 50;
		//单个单元格的宽度
		public static const GRID_WIDTH:int = 50;
		public static const GRID_HEIGHT:int = 50;
		
		//游戏地图数据
		//_gameMap[mapID][pathArray]  为A寻路路径二维数组
		//_gameMap[mapID][numX]      横向的格数
		//_gameMap[mapID][numY]      纵向的格数
		private static var _gameMap:Dictionary;
		
		public function MapData()
		{
			
		}
		
		//===========================================================================================================
		//  Public method
		//===========================================================================================================
		
		/**
		 * 通过地图ID获取相关的地图数据
		 * @param	mapID
		 * @return
		 */
		public static function getMapData(mapID:String):Object 
		{
			if (!(mapID in MapData._getMap()))
				throw new Error('Cannot get Stage ("' + mapID + '") before it has been set.');
			
			return MapData._getMap()[mapID];
		}
		
		/**
		 * 设置地图数据
		 * @param	data
		 * @param	mapID
		 */
		public static function setMapData(data:Object, mapID:String):void 
		{
			MapData._getMap()[mapID] = data;
		}
		
		/**
		 * 删除某地图ID的地图数据
		 * @param	mapID
		 * @return
		 */
		public static function removeMapData(mapID:String):Boolean 
		{
			if (!(mapID in MapData._getMap()))
				return false;
			
			MapData.setMapData(null,mapID);
			
			return true;
		}
		
		//===========================================================================================================
		//  Private method
		//===========================================================================================================
		
		//获取所有的地图数据
		private static function _getMap():Dictionary 
		{
			if (MapData._gameMap == null)
				MapData._gameMap = new Dictionary();
			
			return MapData._gameMap;
		}
		
	}//end class
}