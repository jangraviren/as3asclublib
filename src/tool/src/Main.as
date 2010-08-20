package 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import org.asclub.game.DefaultConfig;
	import org.asclub.net.WebLoader;
	import org.asclub.ui.ContextMenuManager;
	import org.asclub.system.MonitorKit;
	
	/**
	 * ...横版地图数据生成器
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class Main extends Sprite
	{
		//图形文件
		private var _imageTypes:FileFilter;
		
		//文件加载器(用于打开)
		private var _fileRef:FileReference;
		
		//文件加载器(用于保存)
		private var _fileSaveRef:FileReference;
		
		//单元格宽度
		private var _gridWidth:int = 0;
		
		//单元格高度
		private var _gridHeight:int = 0;
		
		//横向单元格个数
		private var _numGridWidth:int = 0;
		
		//纵向单元格个数
		private var _numGridHeight:int = 0;
		
		//网格线颜色
		private var _lineColor:uint = 0;
		
		//颜色定义
		private var _colorDefineList:XMLList;
		
		//颜色容器
		private var _colorContainer:Array;
		
		//网格是否显示
		private var _griddingVisible:Boolean = false;
		
		//地图是否完全载入
		private var _loadComplete:Boolean = false;
		
		//地图宽度
		private var _mapWidth:int = 0;
		
		//地图高度
		private var _mapHeight:int = 0;
		
		//容器(放置地图层和网格层，用于鼠标拖动)
		private var _container:Sprite;
		
		//地图层
		private var _mapLayer:Sprite;
		
		//网格层
		private var _griddingLayer:Sprite;
		
		//图像加载器
		private var _imageLoader:Loader;
		
		
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		//===========================================================================================================
		//  Private method
		//===========================================================================================================
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//配置
			DefaultConfig.stageSetting(this.stage);
			
			//图形文件类型
			_imageTypes = new FileFilter("Flash图像(*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png");
			
			//文件上传
			_fileRef = new FileReference();
			_fileRef.addEventListener(Event.SELECT, fileSelectedHandler);
			_fileRef.addEventListener(Event.COMPLETE, fileLoadedCompleteHandler);
			
			//文件保存
			_fileSaveRef = new FileReference();
			_fileSaveRef.addEventListener(Event.COMPLETE, fileSaveCompleteHandler);
			
			//载入配置文件
			var webLoader:WebLoader = new WebLoader();
			webLoader.addEventListener(Event.COMPLETE, loadConfigFileCompleteHandler);
			webLoader.load("../xml/setting.xml");
		}
		
		//生成网格
		private function createGridding():void
		{
			_griddingLayer.graphics.lineStyle(1,_lineColor);
			//画横线(第一条不画)
			for (var i:int = 1; i < _numGridHeight; i++)
			{
				_griddingLayer.graphics.moveTo(0, i * _gridHeight);
				_griddingLayer.graphics.lineTo(_mapWidth,i * _gridHeight);
			}
			//画竖线(第一条不画)
			for (var j:int = 1; j < _numGridWidth; j++)
			{
				_griddingLayer.graphics.moveTo(j * _gridWidth, 0);
				_griddingLayer.graphics.lineTo(j * _gridWidth, _mapHeight);
			}
			
		}
		
		//===========================================================================================================
		//  Event Handlers
		//===========================================================================================================
		
		//载入配置文件成功
		private function loadConfigFileCompleteHandler(event:Event):void
		{
			trace("loadConfigFileCompleteHandler");
			var config:XML = XML(event.currentTarget.data);
			_gridWidth = config.gridWidth;
			_gridHeight = config.gridHeight;
			_lineColor = config.lineColor;
			_colorDefineList = config.colorDefine.item;
			trace("_colorDefineList:" + _colorDefineList[0]["name"]);
			
			//添加右键
			ContextMenuManager.hideBuiltInItems(this, true);
			ContextMenuManager.addMenu(this, "打开地图", openMapFile);
			ContextMenuManager.addMenu(this, "显示网格",griddingHandler, false);
			ContextMenuManager.addMenu(this, "生成地图数据",saveMapData, true);
			ContextMenuManager.addMenu(this, "圈圈叉叉编辑器",navigate, true);
			
			//
			_container = new Sprite();
			_mapLayer = new Sprite();
			_imageLoader = new Loader();
			_griddingLayer = new Sprite();
			this.addChild(_container);
			_container.addChild(_mapLayer);
			_mapLayer.addChild(_imageLoader);
			_container.addChild(_griddingLayer);
			
			
			//添加内存占用观察器
			var monitorKit:MonitorKit = new MonitorKit("MKMODE_TR");
			this.addChild(monitorKit);
		}
		
		//用户选中文件
		private function fileSelectedHandler(event:Event):void
		{
			_fileRef.load();
		}
		
		//成功载入用户选中的文件
		private function fileLoadedCompleteHandler(event:Event):void
		{
			trace("fileLoadedCompleteHandler");
			_imageLoader.loadBytes(_fileRef.data);
			_imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, mapLoadedComleteHandler);
		}
		
		//文件成功保存时触发
		private function fileSaveCompleteHandler(event:Event):void
		{
			trace("fileSaveCompleteHandler");
		}
		
		//地图完全载入
		private function mapLoadedComleteHandler(event:Event):void
		{
			trace("地图完全载入");
			_loadComplete = true;
			_mapWidth = _imageLoader.contentLoaderInfo.width;
			_mapHeight = _imageLoader.contentLoaderInfo.height;
			_numGridWidth = _mapWidth / _gridWidth >> 0;
			_numGridHeight = _mapHeight / _gridHeight >> 0;
		}
		
		//打开文件
		private function openMapFile(event:Event):void
		{
			_fileRef.browse([_imageTypes]);
		}
		
		//显示/隐藏网格
		private function griddingHandler(event:Event):void
		{
			if (!_loadComplete) return;
			
			//如果网格当前已经显示
			if (_griddingVisible)
			{
				_griddingLayer.graphics.clear();
				ContextMenuManager.editMenu(this, "隐藏网格", "显示网格", griddingHandler, true);
			}
			else
			{
				createGridding();
				ContextMenuManager.editMenu(this, "显示网格", "隐藏网格", griddingHandler, true);
			}
			_griddingVisible = !_griddingVisible;
		}
		
		//跳动首页
		private function navigate(event:Event):void
		{
			navigateToURL(new URLRequest("http://www.google.com.hk"));
		}
		
		//保存地图数据
		private function saveMapData(event:Event):void
		{
			var mapBitmapData:BitmapData = new BitmapData(_mapWidth, _mapHeight);
			mapBitmapData.draw(_imageLoader);
			var pixelValue:uint = mapBitmapData.getPixel(0, 0);
			trace(pixelValue.toString(16)); // ffffff;
			//trace(pixelValue); // 16777215;
			
			//定义的颜色数量
			var numColor:int = _colorDefineList.length();
			
			mapDataInit();
			
			//因为是逐个像素进行比较，所以耗cpu比较严重(可以想象 2500 * 600 * 2 次循环...)
			for (var i:int = 0; i < _mapWidth; i++)
			{
				for (var j:int = 0; j < _mapHeight; j++)
				{
					var color:String = mapBitmapData.getPixel(i, j).toString(16);
					var pointX:int = i / _gridWidth >> 0;
					var pointY:int = j / _gridHeight >> 0;
					for (var k:int = 0; k < numColor; k++)
					{
						if (_colorDefineList[k]["color"] == color)
						{
							_colorContainer[pointX][pointY][_colorDefineList[k]["name"]] ++;
							//如果颜色一样则就没有再进行本轮的循环的必要，当定义的颜色多的时候效果较好
							continue;
						}
						
					}
				}
			}
			
			
			createMapdata();
		}
		
		//地图数据初始化
		private function mapDataInit():void
		{
			//定义的颜色数量
			var numColor:int = _colorDefineList.length();
			_colorContainer = [];
			//var testObject:Object = {};
			//testObject["a"] ++;
			//trace(testObject["a"]);   //得到 NaN
			//所以 先 testObject["a"] = 0;  再 testObject["a"] ++;
			for (var i:int = 0; i < _numGridWidth; i++)
			{
				_colorContainer[i] = [];
				for (var j:int = 0; j < _numGridHeight; j++)
				{
					var colorObject:Object = { };
					for (var k:int = 0; k < numColor; k++)
					{
						colorObject[_colorDefineList[k]["name"]] = 0;
					}
					_colorContainer[i][j] = colorObject;
				}
			}
		}
		
		//创建地图数据
		private function createMapdata():void
		{
			var t1:int = getTimer();
			//定义的颜色数量
			var numColor:int = _colorDefineList.length();
			
			//存放将进行排序的颜色，结构如下 [{num:1500,value:0},{num:500,value:1},{num:1000,value:2}]
			var sortArray:Array = [];
			//
			var mapData:Array = [];
			
			for (var i:int = 0; i < _numGridWidth; i++)
			{
				for (var j:int = 0; j < _numGridHeight; j++)
				{
					var colorObject:Object = _colorContainer[i][j];
					sortArray.length = 0;
					//var sortArray:Array = [];
					for (var k:int = 0; k < numColor; k++)
					{
						sortArray.push( { num:colorObject[_colorDefineList[k]["name"]], value:_colorDefineList[k]["value"] } );
					}
					sortArray.sortOn("num", Array.NUMERIC | Array.DESCENDING);
					//var value:int = sortArray[0]["value"];
					mapData.push(sortArray[0]["value"]);
				}
			}
			
			
			trace("生成数据耗时:" + (getTimer() - t1));
			
			var data:String = "w=" + _numGridWidth + "&h=" + _numGridHeight + "&data=" + mapData.join("|");
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeUTFBytes(data);
			
			_fileSaveRef.save(byteArray, "mapData.txt");
			
		}
		
	}//end class
}