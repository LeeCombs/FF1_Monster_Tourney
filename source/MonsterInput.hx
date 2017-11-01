package;

import flixel.FlxG;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MonsterInput extends FlxGroup {
	
	private var x:Int;
	private var y:Int;
	private var idText:FlxText;
	public var textInput:FlxInputText;
	public var monsterSize(default, null):String;
	
	// Helper for ensuring color correctness based on size
	private var bgColors:Map<String, FlxColor> = [
		"small" => FlxColor.BLUE.getLightened(0.4),
		"medium" => FlxColor.ORANGE.getLightened(0.4),
		"large" => FlxColor.RED.getLightened(0.4)
	];
	
	/**
	 * Creation function
	 * 
	 * @param	x
	 * @param	y
	 * @param	IDText	Identifying letter, must be A-I
	 */
	override public function new(x:Int = 0, y:Int = 0, IDText:String):Void {
		super();
		
		this.x = x;
		this.y = y;
		
		var alph:Array<String> = ["A", "B", "C", "D", "E", "F", "G", "H", "I"];
		if (alph.indexOf(IDText.toUpperCase()) == -1) {
			FlxG.log.warn("Invalid idText given: " + IDText);
			return;
		}
		idText = new FlxText(x, y, 0, IDText);
		add(idText);
		
		textInput = new FlxInputText(x + 15, y, 100, ".");
		textInput.text = "";
		add(textInput);
	}
	
	/**
	 * Set the Monster size of the object. Updates size restriction and color display.
	 * 
	 * @param	size	Size of the monster to update to.
	 */
	public function setSize(size:String):Void {
		if (size == null || size == "") {
			FlxG.log.warn("Invalid monster size supplied: " + size);
			return;
		}
		
		// Set size, then update the textInput's color to match, and clear it's input
		switch(size.toLowerCase()) {
			case "small", "medium", "large":
				monsterSize = size.toLowerCase();
			default:
				trace("Invalid monster size supplied: " + size);
				return;
		}
		textInput.backgroundColor = bgColors[monsterSize];
		textInput.text = "";
	}
}
