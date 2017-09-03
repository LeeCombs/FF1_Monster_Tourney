package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;


class PlayState extends FlxState {
	var text1:FlxText;
	var text2:FlxText;
	var monster1:Monster;
	var monster2:Monster;
	
	var battleScreen:FlxSprite;
	var battleScreenBG:FlxSprite;
	
	var battleScreen2:FlxSprite;
	var battleScreenBG2:FlxSprite;
	
	private var sceneArray:Array<BattleScene>;
	var playerOneScene:BattleScene;
	var playerTwoScene:BattleScene;
	
	private var magicManager:MagicManager;
	
	
	override public function create():Void {
		super.create();
		
		FlxG.sound.playMusic("assets/music/Battle_Scene.ogg", 0.1);
		
		playerOneScene = new BattleScene(25, 25);
		add(playerOneScene);
		
		playerTwoScene = new BattleScene(300, 25);
		add(playerTwoScene);
		
		sceneArray = [playerOneScene, playerTwoScene];
		
		for (i in 0...4) {
			monster1 = new Monster(0, 0, "Tyro");
			playerOneScene.addMonster(monster1, i);
			
			monster2 = new Monster(0, 0, "Eye");
			monster2.facing = FlxObject.LEFT;
			playerTwoScene.addMonster(monster2, i);
		}
		
		var btn:FlxButton = new FlxButton(200, 50, "Get Moves", takeTurn);
		add(btn);
	}
	
	private function takeTurn():Void {
		
		var turnSchedule:Array<Int> = getTurnSchedule();
		for (turn in turnSchedule) {
			// Set up the active/target scene, and which monster slot is taking action
			var activeScene:BattleScene = sceneArray[Std.int(turn / 10) - 1];
			var targetScene:BattleScene = sceneArray[(Std.int(turn / 10)) % 2];
			var slotNum:Int = turn % 10;
			
			// Grab the monster that will take the action
			var monstersArray:Array<Monster> = activeScene.getMonsters();
			var monster:Monster = monstersArray[slotNum];
			if (monster != null) {
				// Get the action and target of the monster
				var action:Action = monster.getAction();
				
				// TODO - Get the target type from the action first, then get who to target
				// Target Types: Single Enemy, Single Ally, All Enemies, All Allies, Caster (Self)
				
				var targetSlot:Int = getMonsterTarget(targetScene.getMonsters());
				targetScene.attackMonster(targetSlot, action);
			}
		}
		FlxG.log.add("---");
	}
	
	private function getTurnSchedule():Array<Int> {
		/* Turn Order Logic
		* Every creature (alive, dead, statused) gets a turn
		* 
		* Scheduling is done by starting with:
		* 00 01 02 03 04 05 06 07 08 80 81 82 83
		* 00-08 Represent Enemies
		* 80-83 Represent PCs
		* 
		* Pick two random numbers 0...12, and swap numbers at those positions
		* Do this 17 times
		*/
		
		var turnOrder:Array<Int> = [10, 11, 12, 13, 20, 21, 22, 23];
		
		for (i in 0...17) {
			// Get the two indexs to swap, then swap them
			var posOne:Int = FlxG.random.int(0, turnOrder.length - 1);
			var posTwo:Int = FlxG.random.int(0, turnOrder.length - 1);
			
			var tempVal:Int = turnOrder[posOne];
			turnOrder[posOne] = turnOrder[posTwo];
			turnOrder[posTwo] = tempVal;
		}
		
		return turnOrder;
	}
	
	private function getMonsterTarget(teamSlots:Array<Monster>):Int {
		/* Targeting Logic
		* 
		* Roll 1...8
		* Slot 1: 1-4
		* Slot 2: 5-6
		* Slot 3: 7
		* Slot 4: 8
		* 
		* If target is dead/petrified, reroll until valid
		*/
		
		var targetSlot:Int;
		while(true) {
			var targetRoll:Int = FlxG.random.int(1, 8);
			
			if (targetRoll <= 4) targetSlot = 0;
			else if (targetRoll <= 6) targetSlot = 1;
			else if (targetRoll == 7) targetSlot = 2;
			else targetSlot = 3;
			
			if (teamSlots[targetSlot] != null) return targetSlot;
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
