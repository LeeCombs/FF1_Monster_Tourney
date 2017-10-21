package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import Action.ActionType;

enum Status {
	Death; Petrified; Poisoned; Blind; Paralyzed; Asleep; Silenced; Confused;
}

enum Buff {
	FOG; FOG2; INVS; INV2; RUSE; TMPR; SABR; FAST; WALL;
}

enum Debuff {
	LOCK; LOK2; FEAR; SLOW; SLO2; XFER;
}

class Monster extends FlxSprite {
	// Stats
	public var id(default, null):String;
	public var name(default, null):String;
	public var hp(default, null):Int;
	private var hpMax:Int = 0;
	
	public var attack(get, null):Int;
	public var accuracy(get, null):Int;
	public var hits(get, null):Int;
	public var critRate(default, null):Int;
	public var defense(get, null):Int;
	public var evasion(get, null):Int;
	public var magicDefense(default, null):Int;
	public var morale(get, null):Int;
	
	public var statusAttack(default, null):String;
	public var element(default, null):String;
	
	public var types(default, null):Array<String>;
	public var weaknesses(default, null):Array<String>;
	public var resistances(default, null):Array<String>;
	
	private var spells:Array<String>;
	private var spellChance:Int;
	private var skills:Array<String>;
	private var skillChance:Int;
	
	public var gold(default, null):Int;
	public var exp(default, null):Int;
	public var size(default, null):String;
	
	// Trackers for skill and spell use
	private var skillIndex:Int = 0;
	private var spellIndex:Int = 0;
	
	// In-battle effects
	private var statuses:Array<Status> = [];
	private var buffs:Array<Buff> = [];
	private var debuffs:Array<Debuff> = [];
	
	// TEMP - lazy
	private var scene:BattleScene;
	
	/**
	 * Constructor
	 * 
	 * @param	MData	json-formatted data
	 */
	public function new(MData:Dynamic) {
		super();
		
		if (MData == null) throw "Invalid MData supplied to Monster!";
		
		// Make a personal copy of the monster data
		id = MData.id;
		name = MData.name;
		hp = MData.hp;
		hpMax = MData.hp;
		attack = MData.attack;
		accuracy = MData.accuracy;
		hits = MData.hits;
		critRate = MData.critRate;
		defense = MData.defense;
		evasion = MData.evasion;
		magicDefense = MData.magicDefense;
		morale = MData.morale;
		statusAttack = MData.statusAttack;
		element = MData.element;
		types = MData.types;
		weaknesses = MData.weaknesses;
		resistances = MData.resistances;
		spells = MData.spells;
		spellChance = MData.spellChance;
		skills = MData.skills;
		skillChance = MData.skillChance;
		gold = MData.gold;
		exp = MData.exp;
		size = MData.size;
		
		loadGraphic("assets/images/Monsters/" + name.toUpperCase() + ".png");
		setFacingFlip(FlxObject.LEFT, true, false);
	}
	
	/**
	 * Set up scene reference
	 * 
	 * @param	Scene
	 */
	public function setScene(Scene:BattleScene) {
		scene = Scene;
	}
	
	/**
	 * Return the monster's next action
	 * 
	 * @return
	 */
	public function getAction():Action {
		// Check for status effects first, and whether or not they prevent an action from occuring
		var sCheck = statusCheck();
		if (sCheck != null) return sCheck;
		
		// The monster is not under a status that effects it's action, continue regular logic
		var action:Action = { actionType: null, actionName: "SETME" };
		
		/* Monster Action Logic
		* 
		* Priority: Run, Spell, Skill, Attack
		* Run if: Morale - 2*[Leader's Level] + (0...50) < 80
		* Spells? roll 0...128. If equal or less than spell chance, cast spell
		* - Up to 8 Spells
		* - Start from 0, continue sequentially
		* Skills? roll 0...128. If equal or less than skill chance, cast skill
		* - Up to 4 Skills
		* - Start from 0, continue sequentially
		* Regular Attack
		*/
		
		// TODO - run logic?
		
		if (spells != null && spells.length > 0) {
			if (FlxG.random.int(0, 128) <= spellChance) {
				// Check for silence and wasting a turn attempting to cast
				if (checkForStatus(Status.Silenced)) {
					return { actionType: ActionType.StatusEffect, actionName: "Silence" };
				}
				
				action.actionType = Action.ActionType.Spell;
				action.actionName = spells[spellIndex++];
				if (spellIndex >= spells.length) spellIndex = 0;
				return action;
			}
		}
		
		if (skills != null && skills.length > 0) {
			if (FlxG.random.int(0, 128) <= skillChance) {
				// Check for silence and wasting a turn attempting to cast
				if (checkForStatus(Status.Silenced)) {
					return { actionType: ActionType.StatusEffect, actionName: "Silence" };
				}
				
				action.actionType = Action.ActionType.Skill;
				action.actionName = skills[skillIndex++];
				if (skillIndex >= skills.length) skillIndex = 0;
				return action;
			}
		}
		
		// Default attack action
		action.actionType = Action.ActionType.Attack;
		action.actionName = "attack";
		return action;
	}
	
	private function statusCheck():Action {
		var statusAction:Action = { actionType: Action.ActionType.StatusEffect, actionName: "SETME" };
		var curedFlag:Bool = false;
		var statusFlag:Bool = false;
		
		if (checkForStatus(Status.Poisoned)) {
			// If the bug-fix option is selected, damage the monster for 2
			// TODO: This needs testing to see what actually happens when a monster dies at this very moment
			// Maybe just give is death status, ignore it's turn, and hope that gets caught later in the turn?
			if (Globals.BUG_FIXES) {
				hp -= 2;
			}
		}
		
		if (checkForStatus(Status.Paralyzed)) {
			// 9.8% chance to cure
			if (FlxG.random.int(0, 1000) < 98) {
				removeStatus(Status.Paralyzed);
				statusAction.actionName = "Cured!";
				curedFlag = true;
			}
			else {
				statusAction.actionName = "Paralyzed";
				statusFlag = true;
			}
		}
		
		if (checkForStatus(Status.Asleep)) {
			// Unless the bug-fix option is selected, monsters always wake up
			if (Globals.BUG_FIXES) {
				if (FlxG.random.int(0, 80) < hpMax) {
					removeStatus(Status.Asleep);
					statusAction.actionName = "Woke up";
					curedFlag = true;
				}
				else {
					statusAction.actionName = "Sleeping";
					statusFlag = true;
				}
			}
			else {
				removeStatus(Status.Asleep);
				statusAction.actionName = "Woke up";
				curedFlag = true;
			}
		}
		
		// Confusion shouldn't ever occur, but this is here in case that changes
		if (checkForStatus(Status.Confused)) {
			if (FlxG.random.int(0, 100) < 25) {
				removeStatus(Status.Confused);
				statusAction.actionName = "Cured!";
				curedFlag = true;
			}
		}
		
		// If either the cured or status flag were flipped, return the StatusEffect result
		// TODO: This check better
		if (curedFlag || statusFlag) return statusAction;
		return null;
	}
	
	/////////////////
	// HP Handlers //
	/////////////////
	
	/**
	 * Damage monster a given value, killing it if hp drops to or below 0
	 * 
	 * @param	value	Amount to damage
	 */
	public function damage(value:Int):Void {
		if (value < 0) return;
		
		hp -= value;
		if (hp <= 0) removeSelf();
	}
	
	/**
	 * Heal monster a given amount, up to max
	 * 
	 * @param	value	Amount to heal
	 */
	public function heal(value:Int):Void {
		if (value < 0) return;
		hp += value;
	}
	
	/**
	 * Set hp to max and remove bad statuses
	 */
	public function fullHeal():Void {
		hp = hpMax;
		statuses = [];
	}
	
	/////////////////////
	// Buffs & Debuffs //
	/////////////////////
	
	/**
	 * Add a buff to the Monster
	 * 
	 * @param	buff	Name of the buff to add
	 * @return			Whether the buff was successfully applied or not
	 */
	public function addBuff(buff:String):Bool {
		/*
		* WALL - Resist element
		*/
		if (buff == null || buff == "") {
			trace("Invalid buff supplied: " + buff);
			return false;
		}
		
		// Convert the input string to enum value
		var buffEnum:Buff = Type.createEnum(Buff, buff);
		
		// Check for buffs that DO NOT stack
		switch(buffEnum) {
			case FAST, WALL:
				if (checkForBuff(buffEnum)) return false;
			default:
				// Stop the compiler from complaining
		}
		
		// Add the buff
		buffs.push(buffEnum);
		return true;
	}
	
	/**
	 * Add a debuff to the Monster
	 * 
	 * @param	debuff	Name of the debuff to add
	 * @return			Whether the debuff was successfully applied or not
	 */
	public function addDebuff(debuff:String):Bool {
		/*
		* XFER - Remove Resistance
		*/
		if (debuff == null || debuff == "") {
			trace("Invalid debuff supplied: " + debuff);
			return false;
		}
		
		// Convert the string to an enum value
		var debuffEnum:Debuff = Type.createEnum(Debuff, debuff);
		
		// Check for debuffs that DO NOT stack
		switch(debuffEnum) {
			case SLOW, SLO2, XFER:
				if (checkForDebuff(debuffEnum)) return false;
			default:
				// Stop the compiler from complaining
		}
		
		// Add the debuff
		// TEMP: Adding both SLOWs at the same time for the time being, as they do the same thing
		if (debuffEnum == SLOW || debuffEnum == SLO2) {
			debuffs.push(SLOW);
			debuffs.push(SLO2);
		}
		else debuffs.push(debuffEnum);
		return true;
	}
	
	/**
	 * Check for the presence of a buff
	 * 
	 * @param	buff	The Buff to check
	 * @return			Whether the Buff is present or not
	 */
	public function checkForBuff(buff:Buff):Bool {
		if (buffs.indexOf(buff) != -1) return true;
		return false;
	}
	
	/**
	 * Check for the presence of a debuff
	 * 
	 * @param	debuff	The Debuff to check
	 * @return			Whether the Debuff is present or not
	 */
	public function checkForDebuff(debuff:Debuff):Bool {
		if (debuffs.indexOf(debuff) != -1) return true;
		return false;
	}
	
	//////////////
	// Statuses //
	//////////////
	
	/**
	 * Add a status to the monster
	 * 
	 * @param	status
	 */
	public function addStatus(status:Status):Void {
		// Statuses do not stack, so only apply if necessary
		if (statuses.indexOf(status) == -1) statuses.push(status);
	}
	
	/**
	 * Remove a status effect from the monster
	 * 
	 * @param	status
	 */
	public function removeStatus(status:Status):Void {
		statuses.remove(status);
	}
	
	/**
	 * Check if a given status exists on the monster
	 * 
	 * @param	status	The status to check for
	 * @return	True: The status exists, False: The status does not exist
	 */
	public function checkForStatus(status:Status):Bool {
		if (statuses.indexOf(status) != -1) return true;
		return false;
	}
	
	///////////////////////
	// Getters & Setters //
	///////////////////////
	
	public function get_attack() {
		var totalAttack = attack;
		for (buff in buffs) {
			if (buff == TMPR) totalAttack += 14;
			if (buff == SABR) totalAttack += 16;
		}
		return totalAttack;
	}
	
	// TODO: Ensure SABR inscreases accuracy by 16
	public function get_accuracy() {
		var totalAccuracy = accuracy;
		for (buff in buffs) {
			if (buff == SABR) totalAccuracy += 16;
			// TMPR is normally bugged and increases accuracy as well as attack
			if (buff == TMPR && !Globals.BUG_FIXES) totalAccuracy += 14;
		}
		return totalAccuracy;
	}
	
	public function get_hits() {
		var totalHits = hits;
		var hitMult = 1;
		
		// Check for FAST/SLOW and update hit multiplier
		if (checkForBuff(FAST)) hitMult++;
		if (checkForDebuff(SLOW) || checkForDebuff(SLO2)) hitMult--;
		
		// Minimum number of hits is 1
		totalHits *= hitMult;
		return totalHits > 0 ? totalHits : 1;
	}
	
	public function get_defense() {
		var totalDefense = defense;
		for (buff in buffs) {
			if (buff == FOG) totalDefense += 8;
			if (buff == FOG2) totalDefense += 12;
		}
		return totalDefense;
	}
	
	public function get_evasion() {
		var totalEvasion = evasion;
		for (buff in buffs) {
			if (buff == INVS || buff == INV2) totalEvasion += 40;
			if (buff == RUSE) totalEvasion += 80;
		}
		for (debuff in debuffs) {
			if (debuff == LOCK) totalEvasion -= 20;
			
			// LOK2 is normally bugged, and actually increases evasion
			if (debuff == LOK2) {
				if (Globals.BUG_FIXES) totalEvasion -= 20;
				else totalEvasion += 20;
			}
		}
		if (totalEvasion < 0) totalEvasion = 0;
		return totalEvasion;
	}
	
	public function get_morale() {
		var totalMorale = morale;
		for (debuff in debuffs) {
			if (debuff == FEAR) totalMorale -= 40;
		}
		if (totalMorale < 0) totalMorale = 0;
		return totalMorale;
	}
	
	///////////////////
	// Miscellaneous //
	///////////////////
	
	/**
	 * Check if the monster is resistant to a given element
	 * 
	 * @param	element
	 * @return
	 */
	public function isResistantTo(element:String):Bool {
		if (resistances == null || resistances.length == 0) return false;
		if (resistances.indexOf(element) == -1) return false;
		return true;
	}
	
	/**
	 * Check if the monster is weak to a given element
	 * 
	 * @param	element
	 * @return
	 */
	public function isWeakTo(element:String):Bool {
		if (weaknesses == null || weaknesses.length == 0) return false;
		if (weaknesses.indexOf(element) == -1) return false;
		return true;
	}
	
	/**
	 * Make the scene remove this monster
	 */
	public function removeSelf() {
		scene.removeMonster(this);
	}
	
	/**
	 * Object clean up
	 */
	override public function destroy() {
		super.destroy();
	}
}
