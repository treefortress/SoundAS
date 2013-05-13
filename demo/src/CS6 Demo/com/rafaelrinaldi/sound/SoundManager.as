package com.rafaelrinaldi.sound
{
	import com.rafaelrinaldi.data.list.List;
	import com.rafaelrinaldi.data.list.ListItem;

	import flash.display.InteractiveObject;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;

	/**
	 * 
	 * <code>SoundManager</code> keeps sound management intuitive and organized.
	 *
	 * @author Rafael Rinaldi (rafaelrinaldi.com)
	 * @since Aug 1, 2011
	 *
	 */
	public class SoundManager extends SoundControl
	{
		/** Internal list instance. **/
		protected var list : List;
		
		/** @private **/
		protected var _global : SoundGlobal;
		
		/**
		 * @param p_id Manager id.
		 */
		public function SoundManager( p_id : String = null )
		{
			list = new List(p_id == null ? "sound_manager" : p_id);
			list.listClass = SoundManager;
			
			if(SoundMixer.areSoundsInaccessible()) trace("[SoundManager] There's something wrong! Some of the sounds aren't acessible.");
		}

		/**
		 * Add a mute/unmute sound control to context menu.
		 * @param p_target Target to receive the context menu.
		 */
		public function addContextMenu( p_target : InteractiveObject ) : void
		{
			p_target.contextMenu = SoundContextMenu.getContextMenu();
		}

		/**
		 * Add a new item. Available values are:
		 * 
		 * <ul>
		 *		<li>Sound instance. E.g.: <code>add("instance", new MySoundClassInstance);</code></li>
		 *		<li>Sound class. E.g.: <code>add("class", MySoundClass);</code></li>
		 *		<li>Class definition. E.g.: <code>add("definition", "my.pkg.MySoundClass");</code></li>
		 * </ul>
		 * 
		 * @param p_id Item id.
		 * @param p_value Item value.
		 */
		public function add( p_id : String, p_value : * = null ) : SoundItem
		{
			var sound : Sound;
			
			if(p_value is Sound) {
				
				sound = p_value;
				
			} else if(p_value is Class) {
				
				sound = new p_value as Sound;
				
			} else if(p_value is String) {
				
				// Stop if doesn't exist any definition for the class.
				if(!ApplicationDomain.currentDomain.hasDefinition(p_value)) {
					trace("[SoundManager] No definition found for '" + p_value + "'.");
					return null;
				}
				
				// Okay, we've got a definition. Let's do this!
				const klass : * = getDefinitionByName(p_value); 
				sound = new klass as Sound;
			}
			
			// <code>SoundItem</code> reference.
			const item : SoundItem = new SoundItem(sound);
			
			list.add(p_id, item);
			
			return item;
		}
		
		/**
		 * Remove an existing item.
		 * @param p_id Item id.
		 */
		public function remove( p_id : String ) : SoundManager
		{
			list.remove(p_id);
			return this;
		}

		/**
		 * Get an existing item.
		 * @param p_id Item id.
		 */
		public function item( p_id : String ) : SoundItem
		{
			return list.item(p_id) as SoundItem;
		}

		/**
		 * Get or create a group.
		 * @param p_id Group id.
		 */
		public function group( p_id : String ) : SoundManager
		{
			return list.group(p_id) as SoundManager;
		}

		/**
		 * @param p_id Try to match an id.
		 * @return <strong>true</strong> if it matches, <strong>false</strong> otherwise.
		 */
		public function match( p_id : String ) : Boolean
		{
			return list.match(p_id);
		}

		/**
		 * @return Global sound manager aka <code>SoundMixer</code>.
		 * @see SoundGlobal
		 */
		public function global() : SoundGlobal
		{
			if(_global == null) _global = new SoundGlobal;
			return _global	;
		}
		
		/** Stop list items. **/
		override public function stop() : SoundControl
		{
			for each(var item : ListItem in list.items) (item.value as SoundItem).stop();
			return super.stop();
		}

		/**
		 * Play list items.
		 * @param p_loops Loops. Use <strong>-1</strong> to loop forever (<strong>0</strong> by default).
		 * @param p_delay Delay (<strong>0</strong> by default).
		 */
		override public function play( p_loops : int = 0, p_delay : int = 0 ) : SoundControl
		{
			for each(var item : ListItem in list.items) (item.value as SoundItem).play(p_loops, p_delay);
			return super.play();
		}
		
		/** Pause list items. **/
		override public function pause() : SoundControl
		{
			for each(var item : ListItem in list.items) (item.value as SoundItem).pause();
			return super.pause();
		}
		
		/** @return List length. **/
		public function get length() : Number
		{
			return list.length;
		}
		
		/** @return List volume. **/
		override public function get volume() : Number
		{
			// Use the first item of list as reference.
			return (list.index(0) as SoundItem).volume;
		}
		
		/** List volume setter. **/
		override public function set volume( value : Number ) : void
		{
			for each(var item : ListItem in list.items) (item.value as SoundItem).volume = value;
		}
		
		/** @return List pan. **/
		override public function get pan() : Number
		{
			return (list.index(0) as SoundItem).pan;
		}
		
		/** List pan setter. **/
		override public function set pan( value : Number ) : void
		{
			for each(var item : ListItem in list.items) (item.value as SoundItem).pan = value;
		}

		/** Clear from memory. **/
		override public function dispose() : void
		{
			if(list != null) {
				list.dispose();
				list = null;
			}
			
			super.dispose();
		}
	}
}