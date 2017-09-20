package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;

/**
 * ...
 * @author HellaBored
 */
class TextBox extends FlxGroup {
	
	private var x:Int;
	private var y:Int;
	
	private var boxGraphic:FlxSprite;
	private var boxText:FlxText;
	public function new(X:Int, Y:Int, long:Bool = false) {
		super();
		x = X;
		y = Y;
		
		boxGraphic = new FlxSprite(x, y);
		if (!long) boxGraphic.loadGraphic("assets/images/TextBox.png");
		else boxGraphic.loadGraphic("assets/images/TextBoxLong.png");
		add(boxGraphic);
		
		boxText = new FlxText(x + 5, y + 10, boxGraphic.width - 10, "", 8);
		add(boxText);
	}
	
	public function displayText(text:String) {
		boxText.text = text;
	}
	
	public function hasText():Bool {
		if (boxText.text == "" || boxText.text == null) return false;
		return true;
	}
	
	public function clearText() {
		boxText.text = "";
	}
	
}