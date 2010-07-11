﻿package org.asclub.ui
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	/**
	 * MouseWheelTrap - Simultaneous browser/Flash mousewheel scroll issue work-around
	 * 鼠标滚轮捕获，当flash嵌入网页中，用于防止在flash中滚动时，网页也跟着滚动
	 * @version 0.1
	 * @author Liam O'Donnell
	 * @usage Simply call the static method MouseWheelTrap.setup(stage)
	 * @see http://www.spikything.com/blog/?s=mousewheeltrap for updates
	 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
	 * (c) 2009 spikything.com
	 * @example
	 * <code>
	 * 		import org.asclub.ui.MouseWheelTrap;
	 * 		MouseWheelTrap.setup ( stage ) ;
	 * </code>
	 */
	public class MouseWheelTrap
	{
		static private var _mouseWheelTrapped :Boolean;
		
		/**
		 * 鼠标滚轮设置
		 * @param	stage  显示舞台
		 */
		public static function setup(stage:Stage):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function():void { allowBrowserScroll(false); } );
			stage.addEventListener(Event.MOUSE_LEAVE, function():void { allowBrowserScroll(true); } );
		}
		
		private static function allowBrowserScroll(allow:Boolean):void
		{
			createMouseWheelTrap();
			if (ExternalInterface.available) 
			{
				ExternalInterface.call("allowBrowserScroll", allow);
			}
		}
		
		private static function createMouseWheelTrap():void
		{
			if (_mouseWheelTrapped) 
			{
				return;
			} 
			_mouseWheelTrapped = true; 
			if (ExternalInterface.available)
			{
				ExternalInterface.call("eval", "var browserScrolling;function allowBrowserScroll(value){browserScrolling=value;}function handle(delta){if(!browserScrolling){return false;}return true;}function wheel(event){var delta=0;if(!event){event=window.event;}if(event.wheelDelta){delta=event.wheelDelta/120;if(window.opera){delta=-delta;}}else if(event.detail){delta=-event.detail/3;}if(delta){handle(delta);}if(!browserScrolling){if(event.preventDefault){event.preventDefault();}event.returnValue=false;}}if(window.addEventListener){window.addEventListener('DOMMouseScroll',wheel,false);}window.onmousewheel=document.onmousewheel=wheel;allowBrowserScroll(true);");
			}
		}
		
		
	}//end of class
}