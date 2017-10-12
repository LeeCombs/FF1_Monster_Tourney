package;

import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MonsterInput extends FlxGroup {
	
	private var x:Int;
	private var y:Int;
	private var idText:FlxText;
	public var textInput:FlxInputText;
	public var monsterSize:String;
	
	
	
	private var bgColors:Map<String, FlxColor> = [
		"small" => FlxColor.BLUE.getLightened(0.4),
		"medium" => FlxColor.ORANGE.getLightened(0.4),
		"large" => FlxColor.RED.getLightened(0.4)
	];
	
	/**
	 * Creation function
	 * 
	 * @param	X
	 * @param	Y
	 * @param	idText	Identifying letter, must be A-I
	 */
	override public function new(X:Int, Y:Int, IDText:String):Void {
		super();
		
		var alph:Array<String> = ["A", "B", "C", "D", "E", "F", "G", "H", "I"];
		if (alph.indexOf(IDText.toUpperCase()) == -1) {
			trace("Invalid idText given: " + IDText);
			return;
		}
		idText = new FlxText(X, Y, 0, IDText);
		add(idText);
		
		textInput = new FlxInputText(X + 15, Y, 100, ".");
		textInput.text = "";
		add(textInput);
	}
	
	/**
	 * 
	 * @param	Size
	 */
	public function setSize(Size:String):Void {
		// Set size, then update the textInput's color to match, and clear it's input
		switch(Size.toLowerCase()) {
			case "small", "medium", "large":
				monsterSize = Size.toLowerCase();
			default:
				trace("Invalid setSize size supplied: " + monsterSize);
				return;
		}
		textInput.backgroundColor = bgColors[monsterSize];
		textInput.text = "";
	}
	
}