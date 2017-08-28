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
	
	override public function create():Void {
		super.create();
		
		
		battleScreen = new FlxSprite(25, 25);
		battleScreen.loadGraphic("assets/images/BattleScreen.png");
		battleScreen.centerOffsets();
		add(battleScreen);
		
		battleScreenBG = new FlxSprite(battleScreen.x + 7, battleScreen.y + 5);
		battleScreenBG.centerOffsets();
		battleScreenBG.loadGraphic("assets/images/BattleBackgrounds/BattleBackground-" + Std.string(FlxG.random.int(1, 16)) + ".png");
		add(battleScreenBG);
		
		text1 = new FlxText(200, 100);
		add(text1);
		text2 = new FlxText(200, 150);
		add(text2);
		
		var btn:FlxButton = new FlxButton(200, 50, "Get Moves", getMonsterActions);
		add(btn);
		
		monster1 = new Monster(battleScreen.x + 7, battleScreen.y + 38, "Tyro");
		monster2 = new Monster(battleScreen.x + 65, battleScreen.y + 38, "Eye");
		monster2.facing = FlxObject.LEFT;
		
		add(monster1);
		add(monster2);
		
		getMonsterActions();
	}
	
	
	
	
	
	private function getMonsterActions():Void {
		text1.text = monster1.getAction();
		text1.text += "\r\ntarget:" + getMonsterTarget([1, 0, 0, 0]);
		
		text2.text = monster2.getAction();
		text2.text += "\r\ntarget:" + getMonsterTarget([1, 0, 0, 0]);
		
		
		// battleScreenBG.loadGraphic("assets/images/BattleBackgrounds/BattleBackground-" + Std.string(FlxG.random.int(1, 16)) + ".png");
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
