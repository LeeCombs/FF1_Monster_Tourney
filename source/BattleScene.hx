package;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;

class BattleScene extends FlxGroup {
	public var x:Int;
	public var y:Int;
	
	private var scene:FlxSprite;
	private var sceneBackground:FlxSprite;
	
	private var monsters:Array<Monster>;
	private var monsterPositions:Array<Array<Int>> = [[7, 38], [72, 38], [7, 86], [72, 86]];
	
	public var spellManager:SpellManager; // TODO: Necessary?
	
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
		
		monsters = [null, null, null, null];
		
		spellManager = new SpellManager();
	}
	
	/**
	 * Add a monster to the given position
	 * 
	 * @param	monster		Monster to add
	 * @param	position	Index to add it true
	 * @return	True: Success, False: Error
	 */
	public function addMonster(monster:Monster, position:Int, ?Flip:Bool = false):Bool {
		if (monster == null || position < 0 || position > 4) return false;
		if (monsters[position] != null) return false;
		
		if (Flip) monster.facing = FlxObject.LEFT;
		monsters[position] = monster;
		add(monster);
		monster.x = x + monsterPositions[position][0];
		monster.y = y + monsterPositions[position][1];
		
		return true;
	}
	
	/**
	 * Return monster at supplied position
	 * 
	 * @param	position	Index of monster
	 * @return	Monster if exists, null if not
	 */
	public function getMonster(position:Int):Monster {
		if (position < 0 || position > 4) return null;
		return monsters[position];
	}
	
	/**
	 * Remove the monster at the supplied position
	 * 
	 * @param	position	Index of monster
	 * @return	True: Success, False: Error
	 */
	public function removeMonster(monster:Monster):Bool {
		if (monster == null) return false;
		
		monsters[monsters.indexOf(monster)] = null; //?
		remove(monster);
		monster.destroy();
		monster = null;
		
		return true;
	}
	
	/**
	 * Remove the monster at the supplied position
	 * 
	 * @param	position	Index of monster
	 * @return	True: Success, False: Error
	 */
	public function removeMonsterByIndex(index:Int):Bool {
		if (index < 0 || index > 4) return false;
		
		var monster:Monster = getMonster(index);
		monsters[index] = null;
		monster.destroy();
		remove(monster);
		monster = null;
		
		return true;
	}
	
	/**
	 * Return array of all monsters/nulls
	 * 
	 * @return
	 */
	public function getMonsters():Array<Monster> {
		return monsters;
	}
	
	/**
	 * Remove all monsters from the scene
	 */
	public function clearScene() {
		for (monster in monsters) {
			monster.destroy();
			remove(monster);
			monster = null;
		}
		monsters = [null, null, null, null];
	}
	
	/**
	 * Check if there are any valid monsters alive
	 * 
	 * @return	True: A monster exists, False: No monsters exist
	 */
	public function checkForMonsters():Bool {
		for (monster in monsters) {
			if (monster != null) return true;
		}
		return false;
	}
	
	/**
	 * Selects a random background scene graphic
	 */
	private function shuffleBackground() {
		sceneBackground.loadGraphic("assets/images/BattleBackgrounds/BattleBackground-" + Std.string(FlxG.random.int(1, 16)) + ".png");
	}
	
}
