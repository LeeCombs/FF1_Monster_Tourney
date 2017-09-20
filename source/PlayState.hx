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
import flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	// Battle Scenes
	private var sceneArray:Array<BattleScene>;
	private var playerOneScene:BattleScene;
	private var playerTwoScene:BattleScene;
	
	// Managers
	private var spellManager:SpellManager;
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
	
	override public function create():Void {
		super.create();
		
		spellManager = new SpellManager();
		attackManager = new AttackManager();
		// skillManager
		
		FlxG.sound.playMusic("assets/music/Battle_Scene.ogg", 0.1);
		
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
		playerOneScene.addMonster(new Monster(0, 0, "Tyro", playerOneScene), 0);
		playerOneScene.addMonster(new Monster(0, 0, "Tyro", playerOneScene), 1);
		playerOneScene.addMonster(new Monster(0, 0, "Tyro", playerOneScene), 2);
		playerOneScene.addMonster(new Monster(0, 0, "Tyro", playerOneScene), 3);
		
		playerTwoScene.addMonster(new Monster(0, 0, "WarMECH", playerOneScene), 1, true);
	}
	
	/**
	 * Display/Deal with action results
	 * 
	 * @param	result
	 */
	private function handleResult(result:ActionResult, monster:Monster) {
		// TODO - Here is where damage values/effects from actions would be applied to the
		// target of that action, then displayed in a text manager of sorts.
		if (result.success) {
			// Display value/effect
			if (result.value > 0) valueTextBox.displayText(Std.string(result.value));
			if (result.message != null) resultTextBox.displayText(result.message);
			if (monster.checkForStatus(Status.Death) || monster.checkForStatus(Status.Petrified)) {
				trace("status found, remove self");
				monster.removeSelf();
			}
		}
		else {
			// Display "Ineffective"
			resultTextBox.displayText("Ineffective");
		}
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
		trace("getCurrentAction: " + monster.monsterName);
		
		// Get the monster's action, display it, and build targetQueue
		var action:Action = monster.getAction();
		actionTextBox.displayText(action.actionName);
		trace("action: " + action.actionName);
		switch(action.actionType) {
			case ActionType.Attack:
				// TEMP
				// Grab a single, random target from the target scene
				targetQueue.push(getMonsterTarget(targetScene.getMonsters()));
			case ActionType.Spell:
				var spell:Spell = spellManager.getSpellByName(action.actionName);
				switch(spell.target) {
					case "Caster":
						targetQueue.push(monster);
					case "Single Enemy":
						// Grab a single, random target from the target scene
						targetQueue.push(getMonsterTarget(targetScene.getMonsters()));
					case "Single Ally":
						// Grab a single, random target from the active scene
						targetQueue.push(getMonsterTarget(activeScene.getMonsters()));
					case "All Enemies":
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
						trace("Invalid spell target: " + spell.target);
				}
			case ActionType.Skill:
				// TEMP
				// Grab a single, random target from the target scene
				targetQueue.push(getMonsterTarget(targetScene.getMonsters()));
			default:
				trace("Invalid actionType: " + action.actionType);
		}
		
		trace("targetQueue: " + targetQueue.length);
		return action;
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
			timerDelay = 30;
			trace("");
			trace("Execute turn");
			
			// TEMP - Don't progress turns if either scene has no monsters left
			if (!playerOneScene.checkForMonsters() || !playerTwoScene.checkForMonsters()) {
				trace("Done");
				FlxG.sound.playMusic("assets/music/Victory_Fanfare.ogg", 0.1, false);
				timerDelay = 120000;
				return;
			}
			
			// Grab the current actor if necessary, then display it
			if (currentActor == null) {
				// CAREFUL
				do (currentActor = getCurrentActor()) while (currentActor == null);
				actorTextBox.displayText(currentActor.monsterName);
				return;
			}
			
			// Grab a new current action if necessary, then display it
			if (currentAction == null) {
				currentAction = getCurrentAction(currentActor);
				actionTextBox.displayText(currentAction.actionName);
				return;
			}
			
			// Iterate over the targets, and apply the current action to each
			if (targetQueue.length > 0) {
				// Grab the first target of the queue and display it
				if (currentTarget == null) {
					currentTarget = targetQueue[0];
					trace("targeting: " + currentTarget.monsterName);
					targetTextBox.displayText(currentTarget.monsterName);
					return;
				}
				
				if (currentResult == null) {
					trace("getting result");
					// Now remove the first target from the queue
					targetQueue.shift();
					
					trace("applying action: " + currentAction.actionName);
					FlxSpriteUtil.flicker(currentTarget, 0.25, 0.025);
					switch(currentAction.actionType) {
						case ActionType.Attack:
							// TEMP
							FlxG.sound.play("assets/sounds/Physical_Hit.ogg");
							currentResult = attackManager.attack(currentActor, currentTarget);
						case ActionType.Spell:
							FlxG.sound.play("assets/sounds/Spell_Hit.ogg");
							var spell:Spell = spellManager.getSpellByName(currentAction.actionName);
							currentResult = spellManager.castSpell(spell, currentTarget);
						case ActionType.Skill:
							// TEMP - Using spells temporarily
							var spell:Spell = spellManager.getSpellByName(currentAction.actionName);
							currentResult = spellManager.castSpell(spell, currentTarget);
							// currentResult = { success: false, message:"", value: 0 };
						default:
							trace("Invalid actionType: " + currentAction.actionType);
							return;
					}
					
					handleResult(currentResult, currentTarget);
					return;
				}
				else {
					// Clear target/results for the next target
					trace("done target");
					currentResult = null;
					currentTarget = null;
					targetTextBox.clearText();
					valueTextBox.clearText();
					resultTextBox.clearText();
				}
			}
			else {
				// No targets left, the action is complete. Clear everything and move on
				trace("done turn");
				currentActor = null;
				currentAction = null;
				currentTarget = null;
				currentResult = null;
				targetQueue = [];
				
				actorTextBox.clearText();
				actionTextBox.clearText();
				targetTextBox.clearText();
				valueTextBox.clearText();
				resultTextBox.clearText();
			}
		} // end timerDelay
		
	}
}
