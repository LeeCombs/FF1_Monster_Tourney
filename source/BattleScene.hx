package;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;

class BattleScene extends FlxGroup {
	public var x(default, null):Int;
	public var y(default, null):Int;
	private var flipped:Bool;
	
	private var scene:FlxSprite;
	public var sceneType(default, null):String;
	private var sceneBackground:FlxSprite;
	
	private var monsters:Array<Monster> = [null, null, null, null];
	
	// TODO: This is the same as SceneBuilder's positions.
	// Look into having the builder pull from here
	private var activePositions:Array<Array<Int>> = [];
	private var sceneAPositions:Array<Array<Int>> = [for (i in 0...3) for (j in 0...3) [7 + i * 33, 38 + j * 33]];
	private var sceneBPositions:Array<Array<Int>> = [[6, 38], [6, 88], [55, 38], [55, 71], [55, 104], [88, 38], [88, 71], [88, 104]];
	private var sceneCPositions:Array<Array<Int>> = [for (i in 0...2) for (j in 0...2) [7 + i * 65, 38 + j * 48]];
	private var sceneDPositions:Array<Array<Int>> = [[9, 40]];
	
	/**
	 * Initializer
	 * 
	 * @param	x
	 * @param	y
	 * @param	flipped	Whether the scene is facing left or not
	 */
	public function new(x:Int = 0, y:Int = 0, flipped:Bool = false):Void {
		super();
		this.x = x;
		this.y = y;
		this.flipped = flipped;
		
		// Mirror scene Positions if the scene is flipped
		if (flipped) {
			// Flip and realign scene A x positions to the right
			sceneAPositions.reverse();
			for (pos in sceneAPositions) pos[0] += 14;
			
			// Move mediums to the right side, and reverse by hand
			sceneBPositions = [[6, 104], [6, 71], [6, 38], [39, 104], [39, 71], [39, 38], [72, 88], [72, 38]];
			
			sceneCPositions.reverse();
		}
		
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
	 * Set the scene and load the monsters of a given string
	 * 
	 * @param	intputString	String in the format of "A;NAME,NAME,NAME,..."
	 * @return					Whether the load was successful or not
	 */
	public function loadMonsters(intputString:String):Bool {
		if (intputString == null || intputString == "") {
			FlxG.log.warn("Invalid inputString: " + intputString);
			return false;
		}
		
		// Break the input string up into it's parts
		var split = intputString.split(";");
		var sceneType = split[0];
		var monsterNames = split[1].split(",");
		if (flipped) monsterNames.reverse();
		
		// Set up the scene and add the monsters
		if (!setSceneType(sceneType)) return false;
		
		for (i in 0...monsterNames.length) {
			var mon = MonsterManager.getMonsterByName(monsterNames[i]);
			
			// Ignore monsters that cannot be created
			if (mon == null) continue;
			
			// Attempt to add the monster to the scene. If there's a problem, destroy it and carry on
			if (addMonster(mon, i)) {
				mon.setScene(this);
			}
			else {
				FlxG.log.warn("Could not add monster: " + mon.name + ", destroying...");
				mon.destroy();
			}
		}
		
		return true;
	}
	
	/**
	 * Set the scene's type (A, B, C, D), which will load postitions and monster types
	 * 
	 * @param	sceneType	The Scene type to load. Must be "A", "B", "C", or "D"
	 * @return				Whether or not the change was successful
	 */
	public function setSceneType(sceneType:String):Bool {
		if (sceneType == null) {
			FlxG.log.warn("Invalid sceneType supplied");
			return false;
		}
		
		// Set scene positions based on supplied type
		switch(sceneType.toUpperCase()) {
			case "A": activePositions = sceneAPositions;
			case "B": activePositions = sceneBPositions;
			case "C": activePositions = sceneCPositions;
			case "D": activePositions = sceneDPositions;
			default:
				FlxG.log.warn("Invalid scene type supplied: " + sceneType);
				return false;
		}
		
		this.sceneType = sceneType;
		return true;
	}
	
	/**
	 * Add a monster to the given position
	 * 
	 * @param	monster		Monster to add
	 * @param	index		Index to add it to
	 * @return				Whether the monster was added or not
	 */
	public function addMonster(monster:Monster, index:Int):Bool {
		// Error checking
		if (monster == null) {
			FlxG.log.warn("Cannot add null monster");
			return false;
		}
		if (index < 0 || index >= activePositions.length) {
			FlxG.log.warn("Cannot add monster with invalid position index: " + index);
			return false;
		}
		if (monsters[index] != null) {
			FlxG.log.warn("Cannot add monster to already occupied position: " + index);
			return false;
		}
		
		// Now we can add the monster
		if (flipped) monster.facing = FlxObject.LEFT;
		monsters[index] = monster;
		add(monster);
		monster.x = x + activePositions[index][0];
		monster.y = y + activePositions[index][1];
		
		return true;
	}
	
	/**
	 * Return monster at supplied position
	 * 
	 * @param	index	Index of monster
	 * @return			The Monster, Null if invalid
	 */
	public function getMonster(index:Int):Monster {
		if (index < 0 || index >= activePositions.length) {
			FlxG.log.warn("A Monster cannot exist out of index bounds: " + index);
			return null;
		}
		return monsters[index];
	}
	
	/**
	 * Remove a specific monster
	 * 
	 * @param	monster	The monster to remove
	 * @return			Whether the removal was successful
	 */
	public function removeMonster(monster:Monster):Bool {
		if (monster == null) {
			FlxG.log.warn("Cannot remove null monster");
			return false;
		}
		
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
	 * @return				Whether the removal was successful
	 */
	public function removeMonsterByIndex(index:Int):Bool {
		if (index < 0 || index > activePositions.length - 1) {
			FlxG.log.warn("Cannot remove monster outside of index bounds: " + index);
			return false;
		}
		
		var monster = getMonster(index);
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
			if (monster == null) continue;
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
	
	/**
	 * Object clean up
	 */
	override public function destroy():Void {
		scene = FlxDestroyUtil.destroy(scene);
		sceneBackground = FlxDestroyUtil.destroy(sceneBackground);
		
		activePositions = [];
		sceneAPositions = [];
		sceneBPositions = [];
		sceneCPositions = [];
		sceneDPositions = [];
		for (monster in monsters) {
			monster = FlxDestroyUtil.destroy(monster);
		}
		monsters = [];
		
		super.destroy();
	}
}
