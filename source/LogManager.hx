package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;

import flixel.util.FlxDestroyUtil;

/**
 * Manages a group of text objects
 * 
 * MYTODO 
 * Add message filters (Combat, story, system, etc)
 * Think about adding a proper scroll bar
 * Adjust the text position to ensure it's all within the sprite borders
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
	private var infoArray:Array<Array<Dynamic>>;
	
	private var spriteGroup:FlxTypedGroup<FlxSprite>;
	
	// Sprite Objects
	private var bgSprite:FlxSprite;
	private var scrollbarSprite:FlxSprite;
	private var upButton:FlxButton;
	private var downButton:FlxButton;
	
	override public function new(X:Int = 0, Y:Int = 0):Void {
		super();
		
		x = X;
		y = Y;
		
		// The background sprite
		bgSprite = new FlxSprite(x, y);
		bgSprite.makeGraphic(300, 100, FlxColor.BLACK, true);
		add(bgSprite);
		
		// The scroll bar sprite
		scrollbarSprite = new FlxSprite(x, y + 10);
		scrollbarSprite.makeGraphic(10, 10, FlxColor.BROWN);
		add(scrollbarSprite);
		
		// Initialize and fill the arrays
		infoArray = new Array<Array<Dynamic>>();
		for (i in 0...infoLength) {
			infoArray[i] = new Array<Dynamic>();
			infoArray[i] = ["Default", FlxColor.WHITE, "None"];
		}
		
		// Create the 10 FlxText objects that will display on screen
		textGroup = new FlxTypedGroup<FlxText>();
		add(textGroup);
		spriteGroup = new FlxTypedGroup<FlxSprite>();
		add(spriteGroup);
		
		for (i in 0...10) {
			var text:FlxText = new FlxText(x + 20, y - 1 + i * 10, 290, "DEFAULT STATEMENT " + i);
			text.color = FlxColor.WHITE;
			textGroup.add(text);
			var textGraphic = new FlxSprite(x + 10, y + i * 10);
			textGraphic.makeGraphic(10, 10, FlxColor.PINK);
			spriteGroup.add(textGraphic);
		}
		
		// Add the up and down arrows for scrolling through text
		upButton = new FlxButton(x, y, "", moveTextUp);
		upButton.makeGraphic(10, 10);
		add(upButton);
		downButton = new FlxButton(x, y + 90, "", moveTextDown);
		downButton.makeGraphic(10, 10);
		add(downButton);
		
		// Misc
		newGameText();
		addEntry("Another entry test", FlxColor.WHITE, "Event");
		addEntry("Bananas", FlxColor.YELLOW, "Event");
		addEntry("", FlxColor.WHITE, "None");
		addEntry("WHAT WHAT", FlxColor.PINK, "Combat");
		
	}
	
	private function newGameText():Void {
		//clearEntries();
		
		infoArray[0] = ["You're a fledgling wizard in search of great power.", FlxColor.WHITE, "None"];
		infoArray[1] = ["You come across an elusive Mana Pool.", FlxColor.CYAN, "None"];
		infoArray[2] = ["You decide to build a Wizard Tower.", FlxColor.WHITE, "Combat"];
		
		updateDisplay();
	}
	
	/**
	 * Add a string to the textGroup. It will add it to the top and cycle the other text down
	 * DOES NOT check for valid width, make sure to check each input
	 * 
	 * @param	_str	The string to display
	 * @param	_color	The color of the string
	 * @param	_type	The type of message: None, System, Combat, Event
	 * 
	 */
	public function addEntry(_str:String, _color:FlxColor, _type:String):Void {
		// Iterate bottom-up and set each array element to the one above it
		for (i in 0...19) {
			infoArray[19 - i] = infoArray[18 - i];
		} 
		
		// Then set the first elements to _str and _color
		infoArray[0] = [_str, _color, _type];
		
		// Set the FlxText objects to display the new text
		updateDisplay();
	}
	
	/**
	 * Set every text object to an empty string
	 */
	public function clearEntries():Void {
		// Set the arrays as defaults and update the display
		for (i in 0...20) {
			infoArray[i] = ["", FlxColor.WHITE, "None"];
		}
		updateDisplay();
	}
	
	/**
	 * Update the FlxText objects to the appropiate array values
	 */
	public function updateDisplay():Void {
		// Reminder: infoArray is built as [["text", color, "type"], ["text", color, "type"]];
		for (i in 0...10) {
			textGroup.members[i].text = infoArray[arrayTracker + i][0];
			textGroup.members[i].color = infoArray[arrayTracker + i][1];
			
			switch(infoArray[arrayTracker + i][2]) {
				case "System":
					spriteGroup.members[i].makeGraphic(10, 10, FlxColor.GRAY);
				case "Combat":
					spriteGroup.members[i].makeGraphic(10, 10, FlxColor.RED);
				case "Event":
					spriteGroup.members[i].makeGraphic(10, 10, FlxColor.GREEN);
				case "None":
					spriteGroup.members[i].makeGraphic(10, 10, FlxColor.BLACK);
				default:
					FlxG.log.error('Invalid text type given: $infoArray[arrayTracker + i][2]');
					spriteGroup.members[i].makeGraphic(10, 10, FlxColor.LIME);
			}
		}
	}
	
	public function moveTextUp():Void {
		if (arrayTracker > 0) {
			arrayTracker--;
			scrollbarSprite.y -= 7;
			updateDisplay();
		}
	}
	
	public function moveTextDown():Void {
		if (arrayTracker < 10) {
			arrayTracker++;
			scrollbarSprite.y += 7;
			updateDisplay();
		}
	}
	
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

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}