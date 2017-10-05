package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import Action;
import Monster.Status;
import SkillSpellManager.SkillSpell;
import flixel.util.FlxSpriteUtil;
import haxe.Json;
import haxe.Resource;
import openfl.Assets;

class PlayState extends FlxState {
	// Battle Scenes
	private var sceneArray:Array<BattleScene>;
	private var playerOneScene:BattleScene;
	private var playerTwoScene:BattleScene;
	
	// Managers
	private var spellManager:SkillSpellManager;
	private var skillManager:SkillManager;
	private var attackManager:AttackManager;
	
	// Text displays
	private var actorTextBox:TextBox;	// Top left
	private var targetTextBox:TextBox;	// Mid left
	private var actionTextBox:TextBox;	// Top right
	private var valueTextBox:TextBox;	// Mid right
	private var resultTextBox:TextBox;	// Bottom box
	private var turnText:TextBox;
	
	// Turn logic
	private var timerDelay:Int = 60;
	private var turnCount:Int = 0;
	private var turnSchedule:Array<Int> = [];
	
	private var activeScene:BattleScene;
	private var targetScene:BattleScene;
	private var currentActor:Monster;
	private var currentAction:Action;
	private var currentTarget:Monster;
	private var currentResult:ActionResult;
	private var targetQueue:Array<Monster> = [];
	private var resultQueue:Array<ActionResult> = [];
	
	// TESTING
	private var doneTurn:Bool = false;
	private var doneSetup:Bool = false;
	private var doneApplyAction:Bool = false;
	private var doneResults:Bool = false;
	
	private var messageQueue:Array<Array<Dynamic>> = [];
	private var textBoxStack:Array<Dynamic> = [];
	
	private var actingMonster:Monster;
	private var targetMonster:Monster;
	private var activeAction:Action;
	
	override public function create():Void {
		super.create();
		
		FlxG.sound.playMusic("assets/music/Battle_Scene.ogg", 0.1);
		
		// Set up managers
		spellManager = new SkillSpellManager();
		attackManager = new AttackManager();
		MonsterManager.loadData();
		
		// Battle Scenes
		playerOneScene = new BattleScene(25, 50);
		add(playerOneScene);
		playerTwoScene = new BattleScene(155, 50);
		add(playerTwoScene);
		sceneArray = [playerOneScene, playerTwoScene];
		
		// Text display
		turnText = new TextBox(0, 0);
		add(turnText);
		actorTextBox = new TextBox(25, 195);
		add(actorTextBox);
		targetTextBox = new TextBox(25, 225);
		add(targetTextBox);
		actionTextBox = new TextBox(120, 195);
		add(actionTextBox);
		valueTextBox = new TextBox(120, 225);
		add(valueTextBox);
		resultTextBox = new TextBox(25, 255, true);
		add(resultTextBox);
		
		// Add monsters
		for (i in 0...4) {
			var mon1 = MonsterManager.getMonsterByName("TYRO");
			mon1.setScene(playerOneScene);
			playerOneScene.addMonster(mon1, i);
		}
		
		var mon2 = MonsterManager.getMonsterByName("EYE");
		mon2.setScene(playerTwoScene);
		playerTwoScene.addMonster(mon2, 0, true);
	}
	
	/**
	 * Returns the turn order of the monsters for both sides
	 * 
	 * @return
	 */
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
		trace("getTurnSchedule");
		
		var turnOrder:Array<Int> = [10, 11, 12, 13, 20, 21, 22, 23];
		
		for (i in 0...17) {
			// Get the two indexs to swap, then swap them
			var posOne:Int = FlxG.random.int(0, turnOrder.length - 1);
			var posTwo:Int = FlxG.random.int(0, turnOrder.length - 1);
			
			var tempVal:Int = turnOrder[posOne];
			turnOrder[posOne] = turnOrder[posTwo];
			turnOrder[posTwo] = tempVal;
		}
		
		trace("turnOrder: " + turnOrder);
		return turnOrder;
	}
	
	/**
	 * Determine what slow the monster will target
	 * 
	 * @param	teamSlots
	 * @return
	 */
	private function getMonsterTarget(teamSlots:Array<Monster>):Monster {
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
		
		// Being careful of the infinite loop below
		if (teamSlots.length <= 0 || teamSlots == [] || teamSlots == null) return null;
		
		var targetSlot:Int;
		while(true) {
			var targetRoll:Int = FlxG.random.int(1, 8);
			
			if (targetRoll <= 4) targetSlot = 0;
			else if (targetRoll <= 6) targetSlot = 1;
			else if (targetRoll == 7) targetSlot = 2;
			else targetSlot = 3;
			
			if (teamSlots[targetSlot] != null) return teamSlots[targetSlot];
		}
	}
	
	/**
	 * Retrieve the acting Monster for the current turn
	 * 
	 * @return
	 */
	private function getCurrentActor():Monster {
		trace("getCurrentActor");
		
		// Ensure there's a turn schedule to execute
		if (turnSchedule.length <= 0) {
			turnSchedule = getTurnSchedule();
			turnCount++;
			turnText.displayText("Turn: " + Std.string(turnCount));
		}
		
		// Grab the first turn value
		var turn = turnSchedule.shift();
		
		// Set up the active/target scene, and which monster slot is taking action
		activeScene = sceneArray[Std.int(turn / 10) - 1];
		targetScene = sceneArray[(Std.int(turn / 10)) % 2];
		var slotNum:Int = turn % 10;
		
		// Grab the active monster
		var monstersArray:Array<Monster> = activeScene.getMonsters();
		if (monstersArray[slotNum] == null) return null;
		trace("getCurrentActor: " + monstersArray[slotNum]);
		
		return(monstersArray[slotNum]);
	}
	
	/**
	 * Retrieve the next action and build the targetQueue
	 * 
	 * @return
	 */
	private function getCurrentAction(monster:Monster):Action {
		trace("getCurrentAction: " + monster.mData.name);
		
		// Get the monster's action and build targetQueue
		var action:Action = monster.getAction();
		switch(action.actionType) {
			case ActionType.Attack:
				// Grab a single, random target from the target scene
				targetQueue.push(getMonsterTarget(targetScene.getMonsters()));
			case ActionType.Spell, ActionType.Skill:
				var skillSpell:SkillSpell = spellManager.getSkillSpellByName(action.actionName);
				if (skillSpell == null) {
					trace("Invalid spell retrieved: " + skillSpell);
					return null;
				}
				
				// Build the target queue as dictated by the skillSpell's targetting
				switch(skillSpell.target) {
					case "Caster":
						targetQueue.push(monster);
					case "Single Enemy", "Single Target":
						// Grab a single, random target from the target scene
						targetQueue.push(getMonsterTarget(targetScene.getMonsters()));
					case "Single Ally":
						// Grab a single, random target from the active scene
						targetQueue.push(getMonsterTarget(activeScene.getMonsters()));
					case "All Enemies", "All Targets":
						var monsters:Array<Monster> = targetScene.getMonsters();
						for (monster in monsters) {
							if (monster != null) targetQueue.push(monster);
						}
					case "All Allies":
						var monsters:Array<Monster> = activeScene.getMonsters();
						for (monster in monsters) {
							if (monster != null) targetQueue.push(monster);
						}
					default:
						trace("Invalid spell target: " + skillSpell.target);
				}
			default:
				trace("Invalid actionType: " + action.actionType);
		}
		
		return action;
	}
	
	/**
	 * Display the next message queued, if any, and build the stack
	 * 
	 * @return	False: No more messages, True: Message was applied
	 */
	private function handleMessageQueue():Bool {
		// Ensure the messages are displayed and the textbox stack is built
		if (messageQueue.length > 0) {
			var item = messageQueue.shift();
			var tb:TextBox = item[0];
			var message:String = item[1];
			textBoxStack.push(tb);
			tb.displayText(message);
			return true;
		}
		return false;
	}
	
	/**
	 * 
	 * @param	result
	 * @param	monster
	 */
	private function handleResult(result:ActionResult, monster:Monster, ?Physical:Bool = false) {
		if (result.hits > 1) {
			messageQueue.push([actionTextBox, Std.string(result.hits) + "Hits!"]);
		}
		if (result.damage > 0) {
			messageQueue.push([valueTextBox, Std.string(result.damage) + "DMG"]);
		}
		else {
			if (Physical) messageQueue.push([valueTextBox, "Missed!"]);
		}
		if (result.message != "") {
			messageQueue.push([resultTextBox, result.message]);
		}
		if (monster.checkForStatus(Status.Petrified) || monster.checkForStatus(Status.Death) || monster.mData.hp < 0) {
			messageQueue.push([resultTextBox, "Terminated"]);
			monster.removeSelf();
		}
	}
	
	private function handleSkillSpellResult(result:ActionResult, monster:Monster) {
		if (result.damage > 0) {
			messageQueue.push([valueTextBox, Std.string(result.damage) + "DMG"]);
		}
		if (result.message != "") {
			messageQueue.push([resultTextBox, result.message]);
		}
		
		if (monster.checkForStatus(Status.Petrified) || monster.checkForStatus(Status.Death) || monster.mData.hp < 0) {
			messageQueue.push([resultTextBox, "Terminated"]);
			monster.removeSelf();
		}
	}
	/**
	 * Game logic
	 * 
	 * @param	elapsed
	 */
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		// Execute the turn logic
		if (timerDelay > 0) timerDelay--;
		if (timerDelay <= 0) {
			timerDelay = 10;
			trace("");
			trace("Execute turn");
			
			if (doneTurn) {
				if (textBoxStack.length > 0) {
					textBoxStack.pop().clearText();
					timerDelay = 5;
					
					if (textBoxStack.length == 0) {
						// Don't progress turns if either scene has no monsters left
						if (!playerOneScene.checkForMonsters() || !playerTwoScene.checkForMonsters()) {
							trace("Done");
							FlxG.sound.playMusic("assets/music/Victory_Fanfare.ogg", 0.1, false);
							timerDelay = 120000;
							resultTextBox.displayText("Monsters perished");
						}
					}
					return;
				}
				else {
					doneTurn = false;
					doneSetup = false;
					doneApplyAction = false;
					doneResults = false;
					
					turnCount++;
					turnText.displayText("Turn: " + Std.string(turnCount));
				}
			}
			
			// Setup the turn by getting the actor and it's action
			if (!doneSetup) {
				do (actingMonster = getCurrentActor()) while (actingMonster == null);
				messageQueue.push([actorTextBox, actingMonster.mData.name]);
				
				// Spells and Skills show their name on setup, physical attacks dont
				activeAction = getCurrentAction(actingMonster);
				if (activeAction.actionType != ActionType.Attack) {
					messageQueue.push([actionTextBox, activeAction.actionName]);
				}
				
				doneSetup = true;
			}
			
			// Apply the actions to the target(s)
			if (!doneApplyAction) {
				// Ensure the messages are displayed
				if (handleMessageQueue()) return;
				
				// No targets? The turn is done
				if (targetQueue.length <= 0) {
					doneTurn = true;
					return;
				}
				
				if (doneResults) {
					if (textBoxStack.length > 2) {
						textBoxStack.pop().clearText();
						timerDelay = 5;
						return;
					}
					doneResults = false;
				}
				
				// Get the next target and apply some actions to it
				targetMonster = targetQueue.shift();
				
				// Ignore the queue and display the target immediately
				textBoxStack.push(targetTextBox);
				targetTextBox.displayText(targetMonster.mData.name);
				
				FlxSpriteUtil.flicker(targetMonster, 0.25, 0.025);
				switch(activeAction.actionType) {
					case ActionType.Attack:
						FlxG.sound.play("assets/sounds/Physical_Hit.ogg");
						currentResult = attackManager.attack(actingMonster, targetMonster);
						handleResult(currentResult, targetMonster, true);
					case ActionType.Spell, ActionType.Skill:
						FlxG.sound.play("assets/sounds/Spell_Hit.ogg");
						var spell:SkillSpell = spellManager.getSkillSpellByName(activeAction.actionName);
						currentResult = spellManager.castSpell(spell, targetMonster);
						handleSkillSpellResult(currentResult, targetMonster);
					default:
						trace("Invalid actionType: " + activeAction.actionType);
						return;
				}
				
				doneResults = true;
			}
		} // end timerDelay
		
	}
}
