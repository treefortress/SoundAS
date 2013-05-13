package com.rafaelrinaldi.sound
{
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	/**
	 * 
	 * Add a context menu to easily mute/unmute global sound.
	 * @example
	 * <listing version="3.0">
	 * sound().addContextMenu(stage);
	 * </listing>
	 *
	 * @author Rafael Rinaldi (rafaelrinaldi.com)
	 * @since Aug 9, 2011
	 *
	 */
	public class SoundContextMenu
	{
		public static const STATUS_MUTED : String = "Unmute sound";
		public static const STATUS_UNMUTED : String = "Mute sound";
		
		/** Menu instance. **/
		public static var menu : ContextMenu;
		
		/** Current status. **/
		public static var status : String = STATUS_UNMUTED;
		
		/** @return Always the same <code>ContextMenu</code> instance. If it's not created yet, create it. **/
		public static function getContextMenu() : ContextMenu
		{
			if(menu == null) {
				menu = new ContextMenu;
				menu.hideBuiltInItems();
				menu.customItems.push(new ContextMenuItem(status));
				(menu.customItems[0] as ContextMenuItem).addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, itemSelectHandler);
			}
			
			return menu;
		}

		/** Toggle sound status. **/
		protected static function toggle( p_status : String ) : void
		{
			if(p_status == STATUS_MUTED) {
				status = STATUS_UNMUTED;
			} else if(p_status == STATUS_UNMUTED) {
				status = STATUS_MUTED;
			}
			
			sound().global().toggleMute();
			
			(menu.customItems[0] as ContextMenuItem).caption = status;
		}
		
		/** @private **/
		protected static function itemSelectHandler( event : ContextMenuEvent ) : void
		{
			toggle(event.currentTarget["caption"]);
		}
	}
}