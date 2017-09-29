package;
import flixel.FlxG;
import haxe.Json;
import openfl.Assets;
import Action;

typedef Spell = {
	var id:String;
	var name:String;
	var effectivity:String;
	var accuracy: Int;
	var element:String;
	var target:String;
	var effect:String;
	var price:Int;
	var successMessage:String;
}

class SpellManager {
	// E = Effectivity. Determined by Spell. (Effectively capped at 255)
	// SA = Spell Accuracy. Determined by Spell.
	// MD = Magic Defense. Determined by Target.
	// BC = Base Chance to Hit = 148
	
	private var spellData = [];
	
	public function new() {
		var spellDataJSON = Assets.getText("assets/data/spellData.json");
		spellData = Json.parse(spellDataJSON);
	}
	
	/**
	 * Retrieve a spell by it's name
	 * 
	 * @param	spellName
	 * @return
	 */
	public function getSpellByName(spellName:String):Spell {
		var returnSpell = null;
		for (s in spellData) {
			if (s.name == spellName) {
				returnSpell = s;
				break;
			}
		}
		return returnSpell;
	}
	
	/**
	 * Cast a spell on a target monster.
	 * 
	 * @param	spell
	 * @param	target
	 * @return	Result of the action { message, value }
	 */
	public function castSpell(spell:Spell, target:Monster):ActionResult {
		var failedResult:ActionResult = { message:"Ineffective", damage:0, hits:0 };
		var successfulResult:ActionResult = { message:spell.successMessage, damage:0, hits:0 };
		if (successfulResult.message == null) successfulResult.message = "";
		
		switch (spell.effect) {
			// Damage Spells
			case "Damage":
				// FIRE, LIT, ICE, FIR2, LIT2, ICE2, FIR3, LIT3, ICE3, FADE, NUKE
				successfulResult.damage = damageSpell(spell, target);
				return successfulResult;
			case "Damage Undead":
				// HARM, HRM2, HRM3, HRM4
				if (target.type == "Undead") {
					successfulResult.damage = damageSpell(spell, target);
					return successfulResult;
				}
				return failedResult;
			
			// Status Effects
			case "Status Ailment":
				// SLEP, MUTE, DARK, HOLD, SLP2, CONF
				// BANE, RUB, QAKE, BRAK, STOP, ZAP!, XXXX
				if (statusSpell(spell, target)) {
					return successfulResult;
				}
				return failedResult;
			case "300HP Status Ail":
				// STUN, BLND
				if (statusSpell(spell, target)) {
					return successfulResult;
				}
				return failedResult;
			
			// Healing - Always hits
			case "HP Recovery":
				// CURE, CUR2, HEAL, CURE3, HEL2, HEL3
				healSpell(spell, target);
				return successfulResult;
			case "Full HP/Status Recovery":
				// CUR4
				fullHeal(target);
				return successfulResult;
			case "Restore Status":
				// LAMP, PURE, AMUT
				restoreStatus(spell, target);
				return successfulResult;
			
			// Buffs and Debuffs - Buffs always hit
			case "Defense Up", "Attack Up", "Hit Multiplier Up", "Attack/Accuracy Up", "Evasion Up":
				// FOG, FOG2 - TMPR (fix) - FAST - SABR - RUSE, INVS, INV2
				buffSpell(spell, target);
				return successfulResult;
			case "Hit Multiplier Down", "Morale Down", "Evasion Down", "Remove Resistance":
				// SLOW, SLO2 - FEAR - LOCK, LOK2 - XFER
				if (debuffSpell(spell, target)) {
					return successfulResult;
				}
				return failedResult;
			// case "Nothing":
			// case "[Unused]":
			default:
				FlxG.log.add("Invalid spell effect: " + spell.effect);
		}
		return failedResult;
	}
	

	/**
	 * Cast a damaging spell against a target
	 * 
	 * @param	spell
	 * @param	target
	 * @return	Damage amount
	 */
	private function damageSpell(spell:Spell, target:Monster):Int {
		trace("Casting attack spell: " + spell.name);
		
		var e:Int = Std.parseInt(spell.effectivity);
		
		// Check for resistances/weaknesses. Half for resist, 1.5x for weak.
		if (target.isResistantTo(spell.element)) e = Std.int(e * 0.5);
		if (target.isWeakTo(spell.element)) e = Std.int(e * 1.5);
		
		// Determine damage, and double it if the monster doesn't 'resist' the spell
		var damage = FlxG.random.int(e, e * 2);
		if (checkForHit(spell, target)) damage *= 2;
		
		target.damage(damage);
		return damage;
	}
	
	/**
	 * Attempt to cast a status spell against a target. Returns true if successful, false for miss
	 * 
	 * @param	spell
	 * @param	target
	 * @return	True: Success, False: Miss
	 */
	private function statusSpell(spell:Spell, target:Monster):Bool {
		// 300HP Exceptions (STUN, BLND, XXXX) always hit if target HP is <= 300
		// and is not resistant to the spell element. Otherwise is always misses
		switch(spell.name.toUpperCase()) {
			case "STUN":
				if (target.hp <= 300 && !target.isResistantTo(spell.element)) {
					target.addStatus(Monster.Status.Paralyzed);
					return true;
				}
				return false;
			case "BLND":
				if (target.hp <= 300 && !target.isResistantTo(spell.element)) {
					target.addStatus(Monster.Status.Blind);
					return true;
				}
				return false;
			case "XXXX":
				if (target.hp <= 300 && !target.isResistantTo(spell.element)) {
					target.addStatus(Monster.Status.Death);
					return true;
				}
				return false;
		}
		
		// Check for a spell hit, and apply the status as necessary
		if (checkForHit(spell, target)) {
			switch(spell.effectivity.toUpperCase()) {
				case "DEATH":
					target.addStatus(Monster.Status.Death);
				case "PARALYZE":
					target.addStatus(Monster.Status.Paralyzed);
				case "PETRIFY":
					target.addStatus(Monster.Status.Petrified);
				case "BLIND":
					target.addStatus(Monster.Status.Blind);
				case "SLEEP":
					target.addStatus(Monster.Status.Asleep);
				case "CONFUSE":
					target.addStatus(Monster.Status.Confused);
				case "SILENCE":
					target.addStatus(Monster.Status.Silenced);
			}
			return true;
		}
		
		// Spell missed
		return false; 
	}
	
	/**
	 * Remove a status from the target monster
	 * 
	 * @param	spell
	 * @param	target
	 */
	private function restoreStatus(spell:Spell, target:Monster):Bool {
		switch(spell.name.toUpperCase()) {
			case "AMUT":
				target.removeStatus(Monster.Status.Silenced);
			case "PURE":
				target.removeStatus(Monster.Status.Poisoned);
			case "LAMP":
				target.removeStatus(Monster.Status.Blind);
		}
		return true;
	}
	
	/**
	 * Recover the target's HP based on the spell's effectiveness, capped at 255
	 * 
	 * @param	spell
	 * @param	target
	 * @return	Heal amount
	 */
	private function healSpell(spell:Spell, target:Monster):Int {
		var e:Int = Std.parseInt(spell.effectivity);
		var healAmount = FlxG.random.int(e, e * 2);
		if (healAmount > 255) healAmount = 255;
		
		target.heal(healAmount); // TODO - Move this out of this class?
		
		return healAmount;
	}
	
	/**
	 * Apply a buff to the target
	 * 
	 * @param	spell
	 * @param	target
	 */
	private function buffSpell(spell:Spell, target:Monster):Bool {
		target.addBuff(spell.name);
		return true;
	}
	
	/**
	 * Attempt to apply a debuff to the target
	 * 
	 * @param	spell
	 * @param	target
	 */
	private function debuffSpell(spell:Spell, target:Monster):Bool {
		if (checkForHit(spell, target)) {
			target.addDebuff(spell.name);
			return true;
		}
		return false;
	}
	
	/**
	 * Fully target's HP and clear negative statuses
	 * 
	 * @param	target
	 */
	private function fullHeal(target:Monster):Bool {
		target.fullHeal();
		return true;
	}
	
	/**
	 * Check for a spell "hit". Determines if Status spells hit, or if Damage spells are resisted
	 * 
	 * @param	spell
	 * @param	target
	 * @return	True: Hit, False: Miss
	 */
	private function checkForHit(spell:Spell, target:Monster):Bool {
		/*
		NOTE: Status spells can hit or miss, which is determined by this calculation.
		Damaging spells always "hit," but may be "resisted," in which case the doubling
		component of the damage calculation does not occur, and the spell does only
		half of its potential damage.
		*/
		
		// Exceptions
		// - Positivity effects always hit
		// -- HP Recovery, Restore Status, Defense Up, Resist Element, Attack Up, Hit Up, Attak/Acc Up, FullHp/StatusRecovery, Evasion Up
		// - 300HP Threshold Spells (STUN, BLND, XXXX) always hit if not resistant and current HP <= 300, always miss otherwise
		
		// Base Chance to Hit
		var BC:Int = 148; // Base Chance
		
		// If the target is both resistant and weak, the BC will be 40
		if (target.isResistantTo(spell.element)) BC = 0;
		if (target.isWeakTo(spell.element)) BC += 40;
		
		// Chance to Hit
		var chanceToHit = BC + spell.accuracy - target.mdef;
		if (chanceToHit < 0) chanceToHit = 0;
		
		// 0 always hits, 200 always misses
		var hitRoll = FlxG.random.int(0, 200);
		if (hitRoll == 200) return false;
		if (hitRoll <= chanceToHit) return true;
		return false;
	}
}
