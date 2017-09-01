package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;

class BattleScene extends FlxGroup {
	public var x:Int;
	public var y:Int;
	
	public var sceneText:FlxText;
	public var scene:FlxSprite;
	public var sceneBackground:FlxSprite;
	
	
	public var monsters:Array<Monster>;
	private var monsterPositions:Array<Array<Int>> = [[7, 38], [72, 38], [7, 86], [72, 86]];
	
	
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
		
		monsters = [null, null, null, null];
	}
	
	public function addMonster(monster:Monster, position:Int):Bool {
		
		if (monster == null || position < 0 || position > 4) return false;
		
		monsters[position] = monster;
		add(monster);
		monster.x = x + monsterPositions[position][0];
		monster.y = y + monsterPositions[position][1];
		
		return true;
	}
	
	public function attackMonster(position:Int, attack:String) {
		if (position < 0 || position > 4 || attack == "" || attack == null) return;
		
		var monster:Monster = getMonster(position);
		if (monster == null) return;
		
		var attackType:String = attack.split(":")[0];
		var attackName:String = attack.split(":")[1];
		
		FlxG.log.add("attacking position: " + position + " monster: " + monster.monsterName);
		FlxG.log.add("attackType: " + attackType);
		FlxG.log.add("attackName: " + attackName);
		
	}
	
	public function clearScene() {
		for (monster in monsters) {
			monster.destroy();
			monster = null;
			remove(monster);
		}
	}
	
	public function getMonsters():Array<Monster> {
		return monsters;
	}
	
	private function getMonster(position:Int):Monster {
		if (position < 0 || position > 4) return null;
		return monsters[position];
	}
	
}