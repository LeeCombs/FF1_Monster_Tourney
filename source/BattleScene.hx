package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class BattleScene extends FlxGroup {
	public var x:Int;
	public var y:Int;
	
	public var sceneText:FlxText;
	public var scene:FlxSprite;
	public var sceneBackground:FlxSprite;
	public var monsters:FlxTypedGroup<Monster>;
	
	
	public function new(X:Int, Y:Int) {
		super();
		x = X;
		y = Y;
		
		scene = new FlxSprite(x, y);
		scene.loadGraphic("assets/images/BattleScreen.png");
		add(scene);
		
		sceneBackground = new FlxSprite(x + 7, y + 5);
		sceneBackground.centerOffsets();
		sceneBackground.loadGraphic("assets/images/BattleBackgrounds/BattleBackground-" + Std.string(FlxG.random.int(1, 16)) + ".png");
		add(sceneBackground);
		
		sceneText = new FlxText(x, y + 175);
		add(sceneText);
		
		monsters = new FlxTypedGroup<Monster>();
		add(monsters);
	}
	
	public function addMonster(monster:Monster):Bool {
		if (monster == null) return false;
		
		if (monsters.length < 4) {
			monster.x = x + 7;
			monster.y = y + 38;
			monsters.add(monster);
			return true;
		}
		
		return false;
	}
	
	public function getMonster(index:Int):Monster {
		return monsters.members[index];
	}
	
}