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
	
	private var monsters:Array<Monster> = [null, null, null, null];
	private var monsterPositions:Array<Array<Int>> = [[7, 38], [72, 38], [7, 86], [72, 86]];
	
	/**
	 * Initializer
	 * 
	 * @param	X
	 * @param	Y
	 */
	public function new(X:Int, Y:Int):Void {
		super();
		x = X;
		y = Y;
		
		// Graphics setup
		scene = new FlxSprite(x, y);
		scene.loadGraphic("assets/images/BattleScreen.png");
		add(scene);
		
		sceneBackground = new FlxSprite(x + 7, y + 5);
		sceneBackground.centerOffsets();
		sceneBackground.loadGraphic("assets/images/BattleBackgrounds/BattleBackground-" + Std.string(FlxG.random.int(1, 16)) + ".png");
		add(sceneBackground);
	}
	
	/**
	 * Add a monster to the given position
	 * 
	 * @param	monster		Monster to add
	 * @param	position	Index to add it true
	 * @return				Whether the monster was added or not
	 */
	public function addMonster(monster:Monster, position:Int, ?Flip:Bool = false):Bool {
		// Error checking
		if (monster == null) {
			FlxG.log.warn("Cannot add null monster");
			return false;
		}
		// TODO: This upper position boundary will change depending on the scene type
		if (position < 0 || position > 4) {
			FlxG.log.warn("Cannot add monster with invalid position index: " + position);
			return false;
		}
		if (monsters[position] != null) {
			FlxG.log.warn("Cannot add monster to already occupied position: " + position);
			return false;
		}
		
		// Now we can add the monster
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
	 * @return				The Monster, Null if invalid
	 */
	public function getMonster(position:Int):Monster {
		// TODO: This upper position boundary will change depending on the scene type
		if (position < 0 || position > 4) {
			FlxG.log.warn("A Monster cannot exist out of postion bounds: " + position);
			return null;
		}
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
	public function clearScene():Void {
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
	 * @return	Whether there are valid monsters remaining or not
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
