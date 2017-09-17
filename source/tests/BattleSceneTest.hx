package tests;

import haxe.unit.TestCase;

class BattleSceneTest extends TestCase {
	var x:Int;
	var y:Int;
	var scene:BattleScene;
	
	var monsterA:Monster;
	var monsterB:Monster;
	var monsterC:Monster;
	var monsterD:Monster;
	var monsters:Array<Monster>;
	
	override public function setup() {
		x = 1;
		y = 2;
		scene = new BattleScene(x, y);
		monsterA = new Monster(0, 0, "TYRO");
		monsterB = new Monster(0, 0, "TYRO");
		monsterC = new Monster(0, 0, "TYRO");
		monsterD = new Monster(0, 0, "TYRO");
		monsters = [monsterA, monsterB, monsterC, monsterD];
	}
	
	public function testDefaults() {
		assertEquals(scene.x, x);
		assertEquals(scene.y, y);
		for (monster in scene.getMonsters()) {
			assertEquals(monster, null);
		}
	}
	
	public function testAddMonster() {
		for (i in 0...4) {
			assertEquals(scene.getMonster(i), null);
			assertEquals(scene.addMonster(monsters[i], i), true);
			// Ensure you can't add monster to existing postions
			assertEquals(scene.addMonster(monsters[i], i), false);
			assertEquals(scene.getMonster(i), monsters[i]);
		}
	}
	
	public function testMonsterUniqueness() {
		populateMonsters();
		for (monster in monsters) {
			assertTrue(monster == scene.getMonster(monsters.indexOf(monster)));
			assertFalse(monster == scene.getMonster(monsters.indexOf(monster) + 1));
		}
	}
	
	public function testRemoveMonster() {
		populateMonsters();
		for (i in 0...4) {
			assertEquals(scene.getMonster(i), monsters[i]);
			assertTrue(scene.removeMonster(i));
			assertEquals(scene.getMonster(i), null);
		}
	}
	
	public function testOutOfBounds() {
		for (i in [-1, 5]) {
			assertFalse(scene.addMonster(new Monster(0, 0, "TYRO"), i));
			assertFalse(scene.removeMonster(i));
			assertEquals(scene.getMonster(i), null);
		}
	}
	
	public function testSceneClear() {
		populateMonsters();
		for (monster in scene.getMonsters()) assertFalse(monster == null);
		scene.clearScene();
		for (monster in scene.getMonsters()) assertTrue(monster == null);
	}
	
	/**
	 * Helper to populate scene monsters
	 */
	private function populateMonsters() {
		for (i in 0...4) scene.addMonster(monsters[i], i);
	}
}
