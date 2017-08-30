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
	
	var playerOneScene:BattleScene;
	var playerTwoScene:BattleScene;
	
	
	override public function create():Void {
		super.create();
		
		playerOneScene = new BattleScene(25, 25);
		add(playerOneScene);
		
		playerTwoScene = new BattleScene(300, 25);
		add(playerTwoScene);
		
		for (i in 0...4) {
			monster1 = new Monster(0, 0, "Tyro");
			playerOneScene.addMonster(monster1);
			
			monster2 = new Monster(0, 0, "Eye");
			monster2.facing = FlxObject.LEFT;
			playerTwoScene.addMonster(monster2);
		}
		
		
		var btn:FlxButton = new FlxButton(200, 50, "Get Moves", getMonsterActions);
		add(btn);
		
		getMonsterActions();
		
		FlxG.log.add(getTurnSchedule());
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
	
	private function getMonsterActions():Void {
		playerOneScene.sceneText.text = playerOneScene.getMonster(0).getAction();
		playerOneScene.sceneText.text += "\r\ntarget : " + getMonsterTarget([1, 0, 0, 0]);
		
		playerTwoScene.sceneText.text = playerTwoScene.getMonster(0).getAction();
		playerTwoScene.sceneText.text += "\r\ntarget : " + getMonsterTarget([1, 0, 0, 0]);
		
		playerOneScene.sceneBackground.loadGraphic("assets/images/BattleBackgrounds/BattleBackground-" + Std.string(FlxG.random.int(1, 16)) + ".png");
		playerTwoScene.sceneBackground.loadGraphic("assets/images/BattleBackgrounds/BattleBackground-" + Std.string(FlxG.random.int(1, 16)) + ".png");
	}
	
	private function getMonsterTarget(teamSlots:Array<Int>):Int {
		/* Targeting Logic
		* 
		* Roll 1...8
		* Slot 1: 1-4
		* Slot 2: 5-6
		* Slot 3: 7
		* Slot 4: 8
		* If target is dead/petrified, reroll until valid
		*/
		var targetSlot:Int;
		while(true) {
			var targetRoll:Int = FlxG.random.int(1, 8);
			
			if (targetRoll <= 4) targetSlot = 0;
			else if (targetRoll <= 6) targetSlot = 1;
			else if (targetRoll == 7) targetSlot = 2;
			else targetSlot = 3;
			
			if (teamSlots[targetSlot] == 1) return targetSlot;
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
