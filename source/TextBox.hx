package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;

class TextBox extends FlxGroup {
	
	private var x:Int;
	private var y:Int;
	
	private var boxGraphic:FlxSprite;
	private var boxText:FlxText;
	
	/**
	 * Initializer
	 * 
	 * @param	X
	 * @param	Y
	 * @param	long	If set, loads the long graphic sprite
	 */
	public function new(X:Int, Y:Int, long:Bool = false):Void {
		super();
		x = X;
		y = Y;
		
		// Setup box graphic abd default text
		boxGraphic = new FlxSprite(x, y);
		if (!long) boxGraphic.loadGraphic("assets/images/TextBox.png");
		else boxGraphic.loadGraphic("assets/images/TextBoxLong.png");
		add(boxGraphic);
		
		boxText = new FlxText(x + 5, y + 10, boxGraphic.width - 10, "", 8);
		add(boxText);
		
		// Be hidden initally, until needed
		visible = false;
	}
	
	/**
	 * Display the text provided, and become visible
	 * 
	 * @param	text
	 */
	public function displayText(text:String) {
		boxText.text = text;
		visible = true;
	}
	
	/**
	 * Check if the box has text
	 * 
	 * @return
	 */
	public function hasText():Bool {
		if (boxText.text == "" || boxText.text == null) return false;
		return true;
	}
	
	/**
	 * Remove the displayed text and hide the textbox
	 */
	public function clearText() {
		boxText.text = "";
		visible = false;
	}
}
