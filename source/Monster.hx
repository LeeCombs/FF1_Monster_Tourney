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

typedef MonsterData = {
	var id:String;
	var name:String;
	var hp:Int;
	var attack:Int;
	var accuracy:Int;
	var hits:Int;
	var critRate:Int;
	var defense:Int;
	var evasion:Int;
	var magicDefense:Int;
	var morale:Int;
	var statusAttack:String;
	var element:String;
	var types:Array<String>;
	var weaknesses:Array<String>;
	var resistances:Array<String>;
	var spells:Array<String>;
	var spellChance:Int;
	var skills:Array<String>;
	var skillChance:Int;
	var gold:Int;
	var exp:Int;
}

class Monster extends FlxSprite {
	// Stats
	public var mData:MonsterData;
	private var hpMax:Int = 0;
	
	// Trackers for skill and spell use
	private var skillIndex:Int = 0;
	private var spellIndex:Int = 0;
	
	// In-battle effects
	private var statuses:Array<Status> = [];
	private var buffs:Array<String> = [];
	private var debuffs:Array<String> = [];
	
	// TEMP - lazy
	private var scene:BattleScene;
	
	public function new(MData:Dynamic) {
		super();
		
		mData = MData;
		
		loadGraphic("assets/images/Monsters/" + mData.name.toUpperCase() + ".png");
		setFacingFlip(FlxObject.LEFT, true, false);
	}
	
	/**
	 * Set up scene reference
	 * @param	Scene
	 */
	public function setScene(Scene:BattleScene) {
		scene = Scene;
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
		
		if (mData.spells != null && mData.spells.length > 0) {
			if (FlxG.random.int(0, 128) <= mData.spellChance) {
				action.actionType = Action.ActionType.Spell;
				action.actionName = mData.spells[spellIndex++];
				if (spellIndex >= mData.spells.length) spellIndex = 0;
				return action;
			}
		}
		
		if (mData.skills != null && mData.skills.length > 0) {
			if (FlxG.random.int(0, 128) <= mData.skillChance) {
				action.actionType = Action.ActionType.Skill;
				action.actionName = mData.skills[skillIndex++];
				if (skillIndex >= mData.skills.length) skillIndex = 0;
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
		
		mData.hp -= value;
		if (mData.hp <= 0) removeSelf();
	}
	
	/**
	 * Heal monster a given amount, up to max
	 * 
	 * @param	value	Amount to heal
	 */
	public function heal(value:Int) {
		if (value < 0) return;
		
		mData.hp += value;
		if (mData.hp > hpMax) mData.hp = hpMax;
	}
	
	/**
	 * Set hp to max and remove bad statuses
	 */
	public function fullHeal() {
		mData.hp = hpMax;
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
		
		// Check for debuffs that DO NOT stack
		switch(debuff.toUpperCase()) {
			case "SLOW", "SLO2", "XFER":
				if (debuff.indexOf(debuff) != -1) return;
		}
		
		// Add the debuff
		debuffs.push(debuff);
	}
	
	/**
	 * Add a status to the monster
	 * 
	 * @param	status
	 */
	public function addStatus(status:Status) {
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
		if (mData.resistances == null || mData.resistances.length == 0) return false;
		if (mData.resistances.indexOf(element) == -1) return false;
		return true;
	}
	
	/**
	 * Check if the monster is weak to a given element
	 * 
	 * @param	element
	 * @return
	 */
	public function isWeakTo(element:String):Bool {
		if (mData.weaknesses == null || mData.weaknesses.length == 0) return false;
		if (mData.weaknesses.indexOf(element) == -1) return false;
		return true;
	}
	
	/**
	 * Make the scene remove this monster
	 */
	public function removeSelf() {
		scene.removeMonster(this);
	}
}
