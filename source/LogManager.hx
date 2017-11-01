package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;

import flixel.util.FlxDestroyUtil;

enum MessageType {
	NONE;
	COMBAT;
	SYSTEM;
}

/**
 * Manages a group of FlxText objects to display text in a scrollable manner
 */
class LogManager extends FlxGroup {
	private var x:Int;
	private var y:Int;
	
	// Text displays
	private var arrayTracker = 0;
	private var textGroup:FlxTypedGroup<FlxText>;
	private var numOfEntries = 20; // How many events to keep track of
	private var numOfDisplays = 5; // How many events to display
	private var infoArray:Array<Array<Dynamic>>; // [[Text, Type],...]
	
	// Sprite Objects
	private var bgSprite:FlxSprite;
	private var scrollbarSprite:FlxSprite;
	private var upButton:FlxButton;
	private var downButton:FlxButton;
	
	/**
	 * Creation Function
	 * 
	 * @param	x
	 * @param	y
	 * @param	numOfEntries	How many log entries to display at a time
	 * @param	numOfEntries	How many log entries to keep track of
	 */
	override public function new(x:Int = 0, y:Int = 0, numOfDisplays:Int = 5, numOfEntries:Int = 20):Void {
		super();
		
		this.x = x;
		this.y = y;
		this.numOfEntries = numOfEntries > 0 ? numOfEntries : 20; // Ensure there are some number of entries to track
		this.numOfDisplays = numOfDisplays > 0 ? numOfDisplays : 5; // Ensure there are some number of entries to display
		
		// Ensure there aren't more displays than there are entries
		if (numOfEntries < numOfDisplays) {
			FlxG.log.warn("Cannot have more text displays than there are entries to track");
			numOfDisplays = numOfEntries;
		}
		
		// The background sprite
		bgSprite = new FlxSprite(x, y);
		bgSprite.makeGraphic(200, numOfDisplays * 10, FlxColor.GRAY.getDarkened(), true);
		add(bgSprite);
		
		// The scroll bar sprite
		scrollbarSprite = new FlxSprite(x, y + 10);
		scrollbarSprite.makeGraphic(10, 10, FlxColor.BROWN);
		add(scrollbarSprite);
		
		// Initialize and fill the info array
		infoArray = new Array<Array<Dynamic>>();
		for (i in 0...numOfEntries) {
			infoArray[i] = new Array<Dynamic>();
			infoArray[i] = [" ", MessageType.NONE];
		}
		
		// Create the FlxText objects that will display on screen
		textGroup = new FlxTypedGroup<FlxText>();
		add(textGroup);
		
		for (i in 0...numOfDisplays) {
			var text = new FlxText(x + 10, y - 1 + i * 10, 290, " ");
			text.color = FlxColor.WHITE;
			textGroup.add(text);
		}
		
		// Add the up and down buttons for scrolling through text
		upButton = new FlxButton(x, y, "", scrollTextUp);
		upButton.makeGraphic(10, 10);
		add(upButton);
		
		downButton = new FlxButton(x, y + bgSprite.height - 10, "", scrollTextDown);
		downButton.makeGraphic(10, 10);
		add(downButton);
		
		// Setup the default empty text
		newGameText();
	}
	
	/**
	 * Set default displayed text
	 */
	public function newGameText():Void {
		clearEntries();
		infoArray[0] = ["Press Start to begin!", MessageType.NONE];
		updateDisplay();
	}
	
	/**
	 * Add a string to the textGroup. It will add it to the top and cycle the other text down
	 * DOES NOT check for valid width, make sure to check each input
	 * 
	 * @param	messageString	The string to display
	 * @param	messageType		The type of message: NONE, SYSTEM, COMBAT, etc.
	 */
	public function addEntry(messageString:String, messageType:MessageType):Void {
		// Ensure there are at least default values
		if (messageString == null) messageString = " ";
		if (messageType == null) messageType = MessageType.NONE;
		
		// Iterate bottom-up and set each array element to the one above it
		for (i in 0...19) {
			infoArray[19 - i] = infoArray[18 - i];
		} 
		
		// Set the first elements
		infoArray[0] = [messageString, messageType];
		
		// Set the FlxText objects to display the new text
		updateDisplay();
	}
	
	/**
	 * Set every text object to an empty string
	 */
	public function clearEntries():Void {
		// Set the arrays as defaults and update the display
		for (i in 0...20) {
			infoArray[i] = ["", MessageType.NONE];
		}
		updateDisplay();
	}
	
	/**
	 * Update the FlxText objects to the appropiate values
	 */
	public function updateDisplay():Void {
		// Iterate through the text objects and update displayed text and color
		for (i in 0...numOfDisplays) {
			var flxText:FlxText = textGroup.members[i];
			flxText.text = infoArray[arrayTracker + i][0];
			
			// Set text color based on Message Type
			switch(infoArray[arrayTracker + i][1]) {
				case MessageType.NONE:   flxText.color = FlxColor.WHITE;
				case MessageType.COMBAT: flxText.color = FlxColor.PINK;
				case MessageType.SYSTEM: flxText.color = FlxColor.BLUE.getLightened(0.4);
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
			// Diff is the y position step height between the two scroll buttons
			var diff = ((y + bgSprite.height - 20) - (y + 10)) / (numOfEntries - numOfDisplays);
			scrollbarSprite.y = y + 10 + (diff * arrayTracker);
			updateDisplay();
		}
	}
	
	/**
	 * Scroll the displayed text down
	 */
	private function scrollTextDown():Void {
		if (arrayTracker < (numOfEntries - numOfDisplays)) {
			arrayTracker++;
			// Diff is the y position step height between the two scroll buttons
			var diff = ((y + bgSprite.height - 20) - (y + 10)) / (numOfEntries - numOfDisplays);
			scrollbarSprite.y = y + 10 + (diff * arrayTracker);
			updateDisplay();
		}
	}
	
	/**
	 * Object clean up
	 */
	override public function destroy():Void {
		infoArray = null;
		textGroup = FlxDestroyUtil.destroy(textGroup);
		bgSprite = FlxDestroyUtil.destroy(bgSprite);
		upButton = FlxDestroyUtil.destroy(upButton);
		downButton = FlxDestroyUtil.destroy(downButton);
		scrollbarSprite = FlxDestroyUtil.destroy(scrollbarSprite);
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
