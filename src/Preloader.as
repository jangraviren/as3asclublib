package 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author 
	 */
	public class Preloader extends MovieClip 
	{
		
		private var proglabel : TextField;
		
		public function Preloader() 
		{
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			proglabel = new TextField();
			
			proglabel.x = (stage.stageWidth - 300) / 2;
			proglabel.y = (stage.stageHeight - 19) / 2;
			
			addChild(proglabel);
		}
		
		private function progress(e:ProgressEvent):void 
		{
			proglabel.text = e.bytesLoaded + "/" + e.bytesTotal;
		}
		
		private function checkFrame(e:Event):void 
		{
			if (currentFrame == totalFrames) 
			{
				removeEventListener(Event.ENTER_FRAME, checkFrame);
				startup();
			}
		}
		
		private function startup():void 
		{
			removeChild(proglabel);
			
			stop();
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
	}
	
}