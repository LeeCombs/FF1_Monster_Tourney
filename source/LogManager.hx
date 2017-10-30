package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;

import flixel.util.FlxDestroyUtil;

enum MessageType {
	None; Combat; System;
}

/**
 * Manages a group of text objects
 * 
 * MYTODO 
 * Add message filters (Combat, system, etc)
 * Think about adding a proper scroll bar (Dynamic)
 */
class LogManager extends FlxGroup {
	private var x:Int;
	private var y:Int;
	
	// Text displays
	private var arrayTracker:Int = 0;
	private var stringArray:Array<String>;
	private var colorArray:Array<FlxColor>;
	private var textGroup:FlxTypedGroup<FlxText>;
	
	private var infoLength:Int = 20;
	private var infoArray:Array<Array<Dynamic>>; // [[Text, Type],...]
	
	// Sprite Objects
	private var bgSprite:FlxSprite;
	private var scrollbarSprite:FlxSprite;
	private var upButton:FlxButton;
	private var downButton:FlxButton;
	
	override public function new(X:Int = 0, Y:Int = 0, ?NumOfEntries:Int = 5):Void {
		super();
		
		x = X;
		y = Y;
		
		// The background sprite
		bgSprite = new FlxSprite(x, y);
		bgSprite.makeGraphic(200, NumOfEntries * 10, FlxColor.GRAY.getDarkened(), true);
		add(bgSprite);
		
		// The scroll bar sprite
		scrollbarSprite = new FlxSprite(x, y + 10);
		scrollbarSprite.makeGraphic(10, 10, FlxColor.BROWN);
		add(scrollbarSprite);
		
		// Initialize and fill the arrays
		infoArray = new Array<Array<Dynamic>>();
		for (i in 0...infoLength) {
			infoArray[i] = new Array<Dynamic>();
			infoArray[i] = ["Default Message", MessageType.None];
		}
		
		// Create the 10 FlxText objects that will display on screen
		textGroup = new FlxTypedGroup<FlxText>();
		add(textGroup);
		
		for (i in 0...NumOfEntries) {
			var text:FlxText = new FlxText(x + 10, y - 1 + i * 10, 290, "DEFAULT STATEMENT " + i);
			text.color = FlxColor.WHITE;
			textGroup.add(text);
		}
		
		// Add the up and down arrows for scrolling through text
		upButton = new FlxButton(x, y, "", scrollTextUp);
		upButton.makeGraphic(10, 10);
		add(upButton);
		downButton = new FlxButton(x, y + 40, "", scrollTextDown); // TODO: y position math
		downButton.makeGraphic(10, 10);
		add(downButton);
		
		// Misc
		newGameText();
	}
	
	/**
	 * Set default displayed text
	 */
	public function newGameText():Void {
		clearEntries();
		
		infoArray[0] = ["This is a logger", MessageType.None];
		
		updateDisplay();
	}
	
	/**
	 * Add a string to the textGroup. It will add it to the top and cycle the other text down
	 * DOES NOT check for valid width, make sure to check each input
	 * 
	 * @param	MessageString	The string to display
	 * @param	MsgType			The type of message: None, System, Combat, Event
	 * 
	 */
	public function addEntry(MessageString:String, MsgType:MessageType):Void {
		// Iterate bottom-up and set each array element to the one above it
		for (i in 0...19) {
			infoArray[19 - i] = infoArray[18 - i];
		} 
		
		// Set the first elements
		if (MsgType == null) MsgType = MessageType.None;
		infoArray[0] = [MessageString, MsgType];
		
		// Set the FlxText objects to display the new text
		updateDisplay();
	}
	
	/**
	 * Set every text object to an empty string
	 */
	public function clearEntries():Void {
		// Set the arrays as defaults and update the display
		for (i in 0...20) {
			infoArray[i] = ["", MessageType.None];
		}
		updateDisplay();
	}
	
	/**
	 * Update the FlxText objects to the appropiate values
	 */
	public function updateDisplay():Void {
		// Iterate through the text objects and update displayed text and color
		for (i in 0...5) { //numofentries
			var flxText:FlxText = textGroup.members[i];
			flxText.text = infoArray[arrayTracker + i][0];
			
			// Set text color based on Message Type
			switch(infoArray[arrayTracker + i][1]) {
				case MessageType.None:
					flxText.color = FlxColor.WHITE;
				case MessageType.Combat:
					flxText.color = FlxColor.PINK;
				case MessageType.System:
					flxText.color = FlxColor.GREEN;
				default:
					FlxG.log.warn('Invalid message type given: $infoArray[arrayTracker + i][1]');
					flxText.color = FlxColor.WHITE;
			}
		}
	}
	
	/**
	 * Scroll the displayed text up
	 */
	private function scrollTextUp():Void {
		if (arrayTracker > 0) {
			arrayTracker--;
			scrollbarSprite.y -= 4; //TODO: Math
			updateDisplay();
		}
	}
	
	/**
	 * Scroll the displayed text down
	 */
	private function scrollTextDown():Void {
		if (arrayTracker < 5) { //numofentry
			arrayTracker++;
			scrollbarSprite.y += 4; //TODO: Math
			updateDisplay();
		}
	}
	
	/**
	 * Object clean up
	 */
	override public function destroy():Void {
		stringArray = null;
		colorArray = null;
		infoArray = null;
		textGroup = FlxDestroyUtil.destroy(textGroup);
		bgSprite = FlxDestroyUtil.destroy(bgSprite);
		upButton = FlxDestroyUtil.destroy(upButton);
		downButton = FlxDestroyUtil.destroy(downButton);
		super.destroy();
	}
	
	/**
	 * Game logic
	 * 
	 * @param	elapsed
	 */
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
