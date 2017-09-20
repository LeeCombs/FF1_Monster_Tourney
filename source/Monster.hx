package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

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
	public var monsterName:String;
	
	public var hp:Int = 0;
	public var hpMax:Int = 0;
	
	public var atk:Int = 0;	 // Attack
	public var acc:Int = 0;	 // Accuracy
	public var hits:Int = 0; // # of hits
	public var crt:Int = 0;  // Critical Rate
	public var def:Int = 0;  // Defense
	public var eva:Int = 0;  // Evasion
	public var mdef:Int = 0; // Magic Defense
	public var mor:Int = 0;  // Morale
	
	public var satk:String = ""; // Status Attack
	public var elem:String = ""; // Status Attack Element
	
	public var type:String = ""; // Enemy Family
	public var weak:Array<String> = []; // Weaknesses
	public var resi:Array<String> = []; // Resistances
	
	private var spell:Array<String> = new Array<String>();
	private var spellChance:Int = 0;
	private var spellIndex:Int = 0;
	
	private var skill:Array<String> = new Array<String>();
	private var skillChance:Int = 0;
	private var skillIndex:Int = 0;
	
	private var statuses:Array<Status> = [];
	private var buffs:Array<String> = [];
	private var debuffs:Array<String> = [];
	
	// TEMP - lazy
	private var scene:BattleScene;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Name:String, ?Scene:BattleScene) {
		super(X, Y);
		
		scene = Scene;
		
		monsterName = Name.toUpperCase();
		
		loadGraphic("assets/images/" + monsterName + ".png");
		setFacingFlip(FlxObject.LEFT, true, false);
		
		switch monsterName {
			case "TYRO":
				setStats(480, 65, 133, 1, 1, 10, 60, 200, 144);
				type = "Dragon";
			case "EYE":
				setStats(162, 30, 42, 1, 1, 30, 12, 92, 200);
				type = "Mage";
				resi = ["Earth"];
				spell = ["XXXX", "BRAK", "RUB", "LIT2", "HOLD", "MUTE", "SLOW", "SLEP"];
				spellChance = 80;
				skill = ["GLANCE", "SQUINT", "GAZE", "STARE"];
				skillChance = 80;
			case "AGAMA":
				setStats(296, 31, 74, 2, 1, 18, 36, 143, 200);
				type = "Dragon";
				weak = ["Ice"];
				resi = ["Fire"];
				skill = ["HEAT", "HEAT", "HEAT", "HEAT"];
				skillChance = 32;
			case "WARMECH":
				setStats(1000, 128, 200, 2, 1, 80, 96, 200, 200);
				type = "Regenerative";
				resi = ["Status", "Psn/Stn", "Death", "Fire", "Ice", "Lightning", "Earth"];
				// TEMP - below should be skills
				spell = ["NUCLEAR", "NUCLEAR", "NUCLEAR", "NUCLEAR"];
				spellChance = 32;
			default:
				return;
		}
	}
	
	/**
	 * Return the monster's next action
	 * @return
	 */
	public function getAction():Action {
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
		var action:Action = { actionType: null, actionName: "SETME" };
		
		// TODO - run logic?
		
		if (spell.length > 0) {
			if (FlxG.random.int(0, 128) <= spellChance) {
				action.actionType = Action.ActionType.Spell;
				action.actionName = spell[spellIndex++];
				if (spellIndex >= spell.length) spellIndex = 0;
				return action;
			}
		}
		
		if (skill.length > 0) {
			if (FlxG.random.int(0, 128) <= skillChance) {
				action.actionType = Action.ActionType.Skill;
				action.actionName = skill[skillIndex++];
				if (skillIndex >= skill.length) skillIndex = 0;
				return action;
			}
		}
		
		// Default attack action
		action.actionType = Action.ActionType.Attack;
		action.actionName = "attack";
		return action;
	}
	
	/**
	 * Damage monster a given value, killing it if hp drops to or below 0
	 * 
	 * @param	value	Amount to damage
	 */
	public function damage(value:Int) {
		if (value < 0) return;
		
		trace("Damaging monster for: " + value);
		
		hp -= value;
		if (hp <= 0) removeSelf();
	}
	
	/**
	 * Heal monster a given amount, up to max
	 * 
	 * @param	value	Amount to heal
	 */
	public function heal(value:Int) {
		if (value < 0) return;
		
		hp += value;
		if (hp > hpMax) hp = hpMax;
	}
	
	/**
	 * Set hp to max and remove bad statuses
	 */
	public function fullHeal() {
		hp = hpMax;
		statuses = [];
	}
	
	/**
	 * Add a buff to the monster
	 * 
	 * @param	buff
	 */
	public function addBuff(buff:String) {
		/*
		* FOG  - +8 defense
		* FOG2 - +12 defense
		* 
		* INVS - +40 evade
		* INV2 - +40 evade
		* RUSE - +80 evade
		* 
		* TMPR - +14 damage
		* SABR - +16 damage, + <<FIND HIT UP>>
		* FAST - Doubles hits per round
		* 
		* WALL - Resist element
		*/
		
		// Check for buffs that DO NOT stack
		switch(buff.toUpperCase()) {
			case "FAST", "WALL":
				if (buffs.indexOf(buff) != -1) return;
		}
		
		// Add the buff
		buffs.push(buff);
	}
	
	/**
	 * Add a debuff to the monster
	 * 
	 * @param	debuff
	 */
	public function addDebuff(debuff:String) {
		/*
		* LOCK - -20 evade
		* LOK2 - -20 evade
		* FEAR - -40 morale
		* SLOW - Reduce attack # to 1, or counters FAST
		* SLO2 - Reduce attack # to 1, or counters FAST
		* XFER - Remove Resistance
		*/
	}
	
	/**
	 * Add a status to the monster
	 * 
	 * @param	status
	 */
	public function addStatus(status:Status) {
		trace("Adding status: " + status);
		// Statuses do not stack, so only apply if necessary
		if (statuses.indexOf(status) == -1) statuses.push(status);
	}
	
	/**
	 * Remove a status effect from the monster
	 * 
	 * @param	status
	 */
	public function removeStatus(status:Status) {
		statuses.remove(status);
	}
	
	/**
	 * Check if a given status exists on the monster
	 * 
	 * @param	status	The status to check for
	 * @return	True: The status exists, False: The status does not exist
	 */
	public function checkForStatus(status:Status):Bool {
		trace("checking for status: " + status);
		trace(statuses.indexOf(status));
		if (statuses.indexOf(status) != -1) return true;
		return false;
	}
	
	/**
	 * Check if the monster is resistant to a given element
	 * 
	 * @param	element
	 * @return
	 */
	public function isResistantTo(element:String):Bool {
		if (resi.indexOf(element) == -1) return false;
		return true;
	}
	
	/**
	 * Check if the monster is weak to a given element
	 * 
	 * @param	element
	 * @return
	 */
	public function isWeakTo(element:String):Bool {
		if (weak.indexOf(element) == -1) return false;
		return true;
	}
	
	public function removeSelf() {
		scene.removeMonster(this);
	}
	
	private function setStats(HP:Int, ATK:Int, ACC:Int, HITS:Int, CRT:Int, DEF:Int, EVA:Int, MDEF:Int, MOR:Int) {
		hp = HP;
		hpMax = hp;
		atk = ATK;
		acc = ACC;
		hits = HITS;
		crt = CRT;
		def = DEF;
		eva = EVA;
		mdef = MDEF;
		mor = MOR;
	}
}
