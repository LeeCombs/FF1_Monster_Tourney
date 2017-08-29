package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class BattleScene extends FlxGroup {
	public var x:Int;
	public var y:Int;
	
	public var text:FlxText;
	public var scene:FlxSprite;
	public var sceneBackground:FlxSprite;
	public var monsters:FlxGroup;
	
	
	public function new(x:Int, y:Int) {
		
		scene = new FlxSprite(x, y);
		scene.loadGraphic("assets/images/BattleScreen.png");
		add(scene);
		
		sceneBackground = new FlxSprite(x + 7, y + 5);
		sceneBackground.centerOffsets();
		sceneBackground.loadGraphic("assets/images/BattleBackgrounds/BattleBackground-" + Std.string(FlxG.random.int(1, 16)) + ".png");
		add(sceneBackground);
		
		text = new FlxSprite(x, y + 175);
		add(text);
		
		monsters = new FlxGroup();
		add(monsters);
	}
	
}