package;

import haxe.Json;
import haxe.Resource;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxSpriteUtil;
import Action;
import Monster.Status;
import SkillSpellManager.SkillSpell;
import LogManager.MessageType;

class PlayState extends FlxState {
	private var x:Int = 0;
	private var y:Int = 25;
	
	// Battle Scenes
	private var sceneArray:Array<BattleScene>;
	private var playerOneScene:BattleScene;
	private var playerTwoScene:BattleScene;
	
	// Text displays
	private var actorTextBox:TextBox;	// Top left
	private var targetTextBox:TextBox;	// Mid left
	private var actionTextBox:TextBox;	// Top right
	private var valueTextBox:TextBox;	// Mid right
	private var resultTextBox:TextBox;	// Bottom box
	private var messageQueue:Array<Array<Dynamic>> = [];
	private var textBoxStack:Array<Dynamic> = [];
	
	// Turn logic
	private var timerDelay:Int = 60;
	private var turnSpeed:Int = 15;
	private var turnSchedule:Array<Int> = [];
	private var activeScene:BattleScene;
	private var targetScene:BattleScene;
	private var actingMonster:Monster;
	private var targetMonster:Monster;
	private var activeAction:Action;
	private var currentResult:ActionResult;
	private var targetQueue:Array<Monster> = [];
	private var resultQueue:Array<ActionResult> = [];
	private var doneTurn:Bool = false;
	private var doneSetup:Bool = false;
	private var doneApplyAction:Bool = false;
	private var doneResults:Bool = false;
	
	// Info
	private var infoBox:InfoBox;
	private var optionsBox:OptionsBox;
	private var logManager:LogManager;
	
	// temp
	private var runBattle:Bool = false;
	
	override public function create():Void {
		super.create();
		
		FlxG.sound.playMusic("assets/music/Battle_Scene.ogg", 0.1);
		
		// Battle Scenes
		playerOneScene = new BattleScene(x, y);
		add(playerOneScene);
		playerTwoScene = new BattleScene(x + 130, y, true);
		add(playerTwoScene);
		sceneArray = [playerOneScene, playerTwoScene];
		
		// Text display
		actorTextBox = new TextBox(x, y + 145);
		add(actorTextBox);
		targetTextBox = new TextBox(x, y + 175);
		add(targetTextBox);
		actionTextBox = new TextBox(x + 95, y + 145);
		add(actionTextBox);
		valueTextBox = new TextBox(x + 95, y + 175);
		add(valueTextBox);
		resultTextBox = new TextBox(x, y + 205, true);
		add(resultTextBox);
		
		// Info Box
		infoBox = new InfoBox(x + 275, y);
		add(infoBox);
		
		// Otions box
		optionsBox = new OptionsBox(x + 275, y + 130);
		add(optionsBox);
		optionsBox.setStartStopCallback(toggleBattle);
		optionsBox.setResetCallback(resetBattle);
		optionsBox.speedCheckBox.callback = toggleSpeed;
		
		// Log
		logManager = new LogManager(x + 275, 185, 7);
		add(logManager);
		
		// Add monsters
		playerOneScene.loadMonsters("A;COCTRICE,COCTRICE,COCTRICE,COCTRICE,COCTRICE,COCTRICE,COCTRICE,COCTRICE,COCTRICE");
		playerTwoScene.loadMonsters("A;COCTRICE,COCTRICE,COCTRICE,COCTRICE,COCTRICE,COCTRICE,COCTRICE,COCTRICE,COCTRICE");
		
		// Testing
		var sceneOneGold = 0;
		var sceneOneEXP = 0;
		for (m in playerOneScene.getMonsters()) {
			sceneOneGold += m.gold;
			sceneOneEXP += m.exp;
		}
		infoBox.setTeamStats(1, sceneOneGold, sceneOneEXP);
		var sceneTwoGold = 0;
		var sceneTwoEXP = 0;
		for (m in playerTwoScene.getMonsters()) {
			sceneTwoGold += m.gold;
			sceneTwoEXP += m.exp;
		}
		infoBox.setTeamStats(2, sceneTwoGold, sceneTwoEXP);
		
	}
	
	/**
	 * Toggle speed between 1 and 15
	 */
	private function toggleSpeed():Void {
		if (turnSpeed == 15) turnSpeed = 1;
		else turnSpeed = 15;
	}
	
	/**
	 * Start/Stop the battle
	 */
	private function toggleBattle():Void {
		runBattle = !runBattle;
		if (runBattle) {
			logManager.addEntry("Start Battle", MessageType.SYSTEM);
			optionsBox.startStopButton.text = "Pause";
		}
		else {
			logManager.addEntry("Pause Battle", MessageType.SYSTEM);
			optionsBox.startStopButton.text = "Start";
		}
	}
	
	/**
	 * Reset the battle scenes
	 */
	private function resetBattle():Void {
		runBattle = false;
		logManager.addEntry("Reset Battle", MessageType.SYSTEM);
		optionsBox.startStopButton.text = "Start";
		
		// Clear and re-set the scenes
		playerOneScene.clearScene();
		playerTwoScene.clearScene();
		playerOneScene.loadMonsters("B;PHANTOM,GrNAGA,ASTOS,FIGHTER,MAGE,SORCERER,SORCERER,FIGHTER");
		playerTwoScene.loadMonsters("B;WarMECH,FrGIANT,FrWOLF,FrWOLF,FrWOLF,FrWOLF,FrWOLF,FrWOLF");
		
		// Clear up the text displays
		textBoxStack = [];
		messageQueue = [];
		actorTextBox.clearText();
		actionTextBox.clearText();
		targetTextBox.clearText();
		valueTextBox.clearText();
		resultTextBox.clearText();
		
		// Set turn logic defaults
		doneTurn = false;
		doneSetup = false;
		doneApplyAction = false;
		doneResults = false;
		turnSchedule = [];
		targetQueue = [];
		resultQueue = [];
		infoBox.resetRoundCounter();
		infoBox.resetTurnCounter();
	}
	
	/**
	 * Returns the turn order of the monsters for both sides
	 * 
	 * @return
	 */
	private function getTurnSchedule():Array<Int> {
		/**
		 *  NES Turn Order Logic
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
		
		var turnOrder:Array<Int> = [];
		if (playerOneScene.sceneType == "D") turnOrder.push(10);
		else for (i in 0...playerOneScene.length - 1) turnOrder.push(10 + i);
		
		if (playerTwoScene.sceneType == "D") turnOrder.push(20);
		else for (i in 0...playerTwoScene.length - 1) turnOrder.push(20 + i);
		trace("Turn order: " + turnOrder);
		
		// TODO: Should this be adjusted for up to 18 enemies?
		for (i in 0...17) {
			// Get the two indexs to swap, then swap them
			var posOne = FlxG.random.int(0, turnOrder.length - 1);
			var posTwo = FlxG.random.int(0, turnOrder.length - 1);
			
			var tempVal:Int = turnOrder[posOne];
			turnOrder[posOne] = turnOrder[posTwo];
			turnOrder[posTwo] = tempVal;
		}
		
		return turnOrder;
	}
	
	/**
	 * Determine which slot the monster will target
	 * 
	 * @param	teamSlots	A Monster array from the target BattleScene
	 * @return				The Monster that will be targeted 
	 */
	private function getMonsterTarget(teamSlots:Array<Monster>, sceneType:String):Monster {
		/** 
		 * What's going on here?
		 * 
		 * Each scene can have different types, which have different slots
		 * Slots have different odds on being selected based on their position
		 * 
		 * i.e. type "A": Slots ABC are 2x more likely to be targeted than DEF
		 * Slots DEF are also 2x more likely to be targeted than GHI 
		 * 
		 * If an invalid slot it selected, roll again until a valid one is chosen
		 */
		
		// Error checkin'
		if (teamSlots.length <= 0 || teamSlots == [] || teamSlots == null) {
			FlxG.log.warn("Invalid TeamSlots: " + teamSlots);
			return null;
		}
		if (["A", "B", "C", "D"].indexOf(sceneType.toUpperCase()) == -1) {
			FlxG.log.warn("Invalid SceneType. Must be A, B, C, or D. Found: " + sceneType);
			return null;
		}
		
		var targetSlot:Int;
		var loopPanic = 10000; // This check is here just in case I missed something below
		
		switch(sceneType) {
			case "A": // 9 slots: 678, 345, 012 = 4, 2, 1 (21)
				while (true) {
					loopPanic--;
					if (loopPanic <= 0) {
						FlxG.log.warn("LoopPanic count reached, backing out");
						return null;
					}
					
					var targetRoll:Int = FlxG.random.int(1, 21);
					
					if (targetRoll == 21) targetSlot = 0;
					else if (targetRoll == 20) targetSlot = 1;
					else if (targetRoll == 19) targetSlot = 2;
					else if (targetRoll >= 17) targetSlot = 3;
					else if (targetRoll >= 15) targetSlot = 4;
					else if (targetRoll >= 13) targetSlot = 5;
					else if (targetRoll >= 9) targetSlot = 6;
					else if (targetRoll >= 5) targetSlot = 7;
					else targetSlot = 8;
					
					if (teamSlots[targetSlot] != null) return teamSlots[targetSlot];
				}
			case "B": // 8 slots: 567, 234, 01 = 4, 2, 1 (17)
				while (true) {
					loopPanic--;
					if (loopPanic <= 0) {
						FlxG.log.warn("LoopPanic count reached, backing out");
						return null;
					}
					
					var targetRoll:Int = FlxG.random.int(1, 17);
					
					if (targetRoll == 17) targetSlot = 0;
					else if (targetRoll == 16) targetSlot = 1;
					else if (targetRoll == 15) targetSlot = 2;
					else if (targetRoll >= 13) targetSlot = 3;
					else if (targetRoll >= 11) targetSlot = 4;
					else if (targetRoll >= 9) targetSlot = 5;
					else if (targetRoll >= 5) targetSlot = 6;
					else targetSlot = 7;
					
					if (teamSlots[targetSlot] != null) return teamSlots[targetSlot];
				}
			case "C": // 4 slots: 3, 2, 01 = 4, 2, 1 (8)
				while (true) {
					loopPanic--;
					if (loopPanic <= 0) {
						FlxG.log.warn("LoopPanic count reached, backing out");
						return null;
					}
					
					var targetRoll:Int = FlxG.random.int(1, 8);
					
					if (targetRoll == 8) targetSlot = 0;
					else if (targetRoll == 7) targetSlot = 1;
					else if (targetRoll >= 5) targetSlot = 2;
					else targetSlot = 3;
					
					if (teamSlots[targetSlot] != null) return teamSlots[targetSlot];
				}
			case "D": // Only one possible target
				targetSlot = 0;
				return teamSlots[targetSlot];
			default:
				// Necessary?
		}
		
		return null;
	}
	
	/**
	 * Retrieve the acting Monster for the current turn
	 * 
	 * @return	The Monster to act for this turn
	 */
	private function getCurrentActor():Monster {
		// Ensure there's a turn schedule to execute
		if (turnSchedule.length <= 0) {
			turnSchedule = getTurnSchedule();
			
			// Update the round and turn count displays
			infoBox.incrementRoundCounter();
			infoBox.resetTurnCounter();
		}
		
		// Grab the first turn value
		var turn = turnSchedule.shift();
		
		// NOTE: This turn/scene setup logic breaks if turn is not within range. While the scenes
		// should not allow more than 9 slots, this is something to be aware of if changes are made
		if (turn < 10 || turn >= 30) {
			FlxG.log.warn("Invalid turn number found, must be between 10 and 29, found: " + turn);
			return null;
		}
		
		// Set up the active/target scene, and which monster slot is taking action
		activeScene = sceneArray[Std.int(turn / 10) - 1];
		targetScene = sceneArray[(Std.int(turn / 10)) % 2];
		var slotNum = turn % 10;
		
		// Grab the active monster
		var monstersArray:Array<Monster> = activeScene.getMonsters();
		if (monstersArray[slotNum] == null) return null; //?
		
		return(monstersArray[slotNum]);
	}
	
	/**
	 * Retrieve the next action and build the targetQueue
	 * 
	 * @return	The Action to execute
	 */
	private function getCurrentAction(monster:Monster):Action {
		if (monster == null) {
			FlxG.log.warn("Invalid monster supplied!");
			return null;
		}
		// Get the monster's action and build targetQueue
		
		// This case isn't really able to occur, since enemies do not have access to abilities that cause confusion, but alas
		if (monster.checkForStatus(Status.CONFUSED)) {
			// In this case, the monster will target itself or an ally with "FIRE"
			targetQueue.push(getMonsterTarget(activeScene.getMonsters(), activeScene.sceneType));
			return { actionType: ActionType.SPELL, actionName: "FIRE" };
		}
		
		var action:Action = monster.getAction();
		switch(action.actionType) {
			case ActionType.ATTACK:
				// Grab a single, random target from the target scene
				targetQueue.push(getMonsterTarget(targetScene.getMonsters(), targetScene.sceneType));
				logManager.addEntry(monster.name + " attacks " + targetQueue[0].name, MessageType.COMBAT);
			case ActionType.SPELL, ActionType.SKILL:
				var skillSpell:SkillSpell = SkillSpellManager.getSkillSpellByName(action.actionName);
				if (skillSpell == null) {
					FlxG.log.warn("Invalid spell retrieved: " + skillSpell);
					return null;
				}
				logManager.addEntry(monster.name + " casts " + skillSpell.name, MessageType.COMBAT);
				
				// Build the target queue as dictated by the skillSpell's targetting
				switch(skillSpell.target) {
					case "Caster":
						targetQueue.push(monster);
					case "Single Enemy", "Single Target":
						// Grab a single, random target from the target scene
						targetQueue.push(getMonsterTarget(targetScene.getMonsters(), targetScene.sceneType));
					case "Single Ally":
						// Grab a single, random target from the active scene
						targetQueue.push(getMonsterTarget(activeScene.getMonsters(), activeScene.sceneType));
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
						FlxG.log.warn("Invalid spell target: " + skillSpell.target);
				}
			case ActionType.STATUS_EFFECT:
				// What am I doing...
				messageQueue.push([resultTextBox, action.actionName]);
			default:
				FlxG.log.warn("Invalid actionType: " + action.actionType);
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
	 * Handle the text output for a given result, and monster termination
	 * 
	 * @param	result
	 * @param	monster
	 */
	private function handleResult(result:ActionResult, monster:Monster, ?Physical:Bool = false) {
		if (Physical) {
			if (result.hits > 1) {
				messageQueue.push([actionTextBox, Std.string(result.hits) + " Hits!"]);
			}
		}
		
		// Damage output, or missed!
		if (result.damage > 0) {
			messageQueue.push([valueTextBox, Std.string(result.damage) + " DMG"]);
		}
		else {
			if (Physical) messageQueue.push([valueTextBox, "Missed!"]);
		}
		
		// Display the result message if it exists
		if (result.message != "") {
			messageQueue.push([resultTextBox, result.message]);
		}
		
		// Check for monster termination
		if (monster.checkForStatus(Status.PETRIFIED) || monster.checkForStatus(Status.DEATH) || monster.hp < 0) {
			messageQueue.push([resultTextBox, "Terminated"]);
			logManager.addEntry(monster.name + " is Terminated", MessageType.NONE);
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
		
		if (!runBattle) return;
		
		// Execute the turn logic
		if (timerDelay > 0) timerDelay--;
		if (timerDelay <= 0) {
			timerDelay = turnSpeed;
			
			if (doneTurn) {
				// If there's a text box stack, remove top-down, completing the turn once all messages are gone
				if (textBoxStack.length > 0) {
					textBoxStack.pop().clearText();
					timerDelay = 5;
					
					if (textBoxStack.length == 0) {
						// Don't progress turns if either scene has no monsters left
						if (!playerOneScene.checkForMonsters() || !playerTwoScene.checkForMonsters()) {
							// If a team was fighting CHAOS, play the defeated music. Otherwise fanfare.
							if (activeScene.sceneType == "D") FlxG.sound.playMusic("assets/music/Dead_Music.ogg", 0.1);
							else FlxG.sound.playMusic("assets/music/Victory_Fanfare.ogg", 0.1, false);
							
							resultTextBox.displayText("Monsters perished");
							runBattle = false;
						}
					}
					return;
				}
				else {
					doneTurn = false;
					doneSetup = false;
					doneApplyAction = false;
					doneResults = false;
				}
			}
			
			// Setup the turn by getting the actor and it's action
			if (!doneSetup) {
				// Increment the turn counter display
				infoBox.incrementTurnCounter();
				
				do (actingMonster = getCurrentActor()) while (actingMonster == null);
				messageQueue.push([actorTextBox, actingMonster.name]);
				
				// Spells and Skills show their name on setup, physical attacks dont
				activeAction = getCurrentAction(actingMonster);
				
				// Skip invalid actions
				if (activeAction == null) {
					doneSetup = true;
					return;
				}
				
				// Display skill/spell's action name
				if (activeAction.actionType == ActionType.SPELL || activeAction.actionType == ActionType.SKILL) {
					messageQueue.push([actionTextBox, activeAction.actionName]);
				}
				
				doneSetup = true;
			}
			
			// Apply the actions to the target(s)
			if (!doneApplyAction) {
				// Ensure the messages are displayed
				if (handleMessageQueue()) return;
				
				// No targets? The turn is done
				if (targetQueue.length <= 0 || activeAction == null) {
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
				targetTextBox.displayText(targetMonster.name);
				
				// Deal the action to the target, and handle the results
				FlxSpriteUtil.flicker(targetMonster, 0.25, 0.025);
				switch(activeAction.actionType) {
					case ActionType.ATTACK:
						FlxG.sound.play("assets/sounds/Physical_Hit.ogg");
						currentResult = AttackManager.attack(actingMonster, targetMonster);
						handleResult(currentResult, targetMonster, true);
					case ActionType.SPELL, ActionType.SKILL:
						FlxG.sound.play("assets/sounds/Spell_Hit.ogg");
						var spell:SkillSpell = SkillSpellManager.getSkillSpellByName(activeAction.actionName);
						currentResult = SkillSpellManager.castSpell(spell, targetMonster);
						handleResult(currentResult, targetMonster);
					case ActionType.STATUS_EFFECT:
						// Do nothing?
					default:
						trace("Invalid actionType: " + activeAction.actionType);
						return;
				}
				
				doneResults = true;
			}
		} // end timerDelay
	}
}
