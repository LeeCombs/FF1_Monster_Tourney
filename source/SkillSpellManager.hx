package;

import flixel.FlxG;
import haxe.Json;
import openfl.Assets;
import Action;

typedef SkillSpell = {
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

class SkillSpellManager {
	private static var skillSpellData = [];
	
	/**
	 * Initializer
	 */
	public static function loadData():Void {
		var skillSpellDataJSON = Assets.getText("assets/data/skillSpellData.json");
		skillSpellData = Json.parse(skillSpellDataJSON);
	}
	
	/**
	 * Retrieve a skill or spell by it's name
	 * 
	 * @param	skillSpellName
	 * @return
	 */
	public static function getSkillSpellByName(skillSpellName:String):SkillSpell {
		trace("getSkillSpellByName: " + skillSpellName);
		var returnSkillSpell = null;
		for (s in skillSpellData) {
			if (s.name == skillSpellName) {
				return s;
			}
		}
		return null;
	}
	
	/**
	 * Cast a skill or spell on a target monster.
	 * 
	 * @param	skillSpell
	 * @param	target
	 * @return	Result of the action { message, value }
	 */
	public static function castSpell(skillSpell:SkillSpell, target:Monster):ActionResult {
		var failedResult:ActionResult = { message:"Ineffective", damage:0, hits:0 };
		var successfulResult:ActionResult = { message:skillSpell.successMessage, damage:0, hits:0 };
		if (successfulResult.message == null) successfulResult.message = "";
		
		switch (skillSpell.effect) {
			// Damage Spells
			case "Damage":
				// FIRE, LIT, ICE, FIR2, LIT2, ICE2, FIR3, LIT3, ICE3, FADE, NUKE
				successfulResult.damage = damageSkillSpell(skillSpell, target);
				return successfulResult;
			case "Damage Undead":
				// HARM, HRM2, HRM3, HRM4
				if (target.types.indexOf("Undead") != -1) {
					successfulResult.damage = damageSkillSpell(skillSpell, target);
					return successfulResult;
				}
				return failedResult;
			
			// Status Effects
			case "Status Ailment":
				// SLEP, MUTE, DARK, HOLD, SLP2, CONF
				// BANE, RUB, QAKE, BRAK, STOP, ZAP!, XXXX
				if (statusSkillSpell(skillSpell, target)) {
					return successfulResult;
				}
				return failedResult;
			case "300HP Status Ail":
				// STUN, BLND
				if (statusSkillSpell(skillSpell, target)) {
					return successfulResult;
				}
				return failedResult;
			
			// Healing - Always hits
			case "HP Recovery":
				// CURE, CUR2, HEAL, CURE3, HEL2, HEL3
				healSkillSpell(skillSpell, target);
				return successfulResult;
			case "Full HP/Status Recovery":
				// CUR4
				fullHeal(target);
				return successfulResult;
			case "Restore Status":
				// LAMP, PURE, AMUT
				restoreStatus(skillSpell, target);
				return successfulResult;
			
			// Buffs and Debuffs - Buffs always hit
			case "Defense Up", "Attack Up", "Hit Multiplier Up", "Attack/Accuracy Up", "Evasion Up", "Resist Element":
				// FOG, FOG2 - TMPR (fix) - FAST - SABR - RUSE, INVS, INV2
				buffSkillSpell(skillSpell, target);
				return successfulResult;
			case "Hit Multiplier Down", "Morale Down", "Evasion Down", "Remove Resistance":
				// SLOW, SLO2 - FEAR - LOCK, LOK2 - XFER
				if (debuffSkillSpell(skillSpell, target)) {
					return successfulResult;
				}
				return failedResult;
			// case "Nothing":
			// case "[Unused]":
			default:
				FlxG.log.warn("Invalid skillSpell effect: " + skillSpell.effect);
		}
		return failedResult;
	}
	
	/**
	 * Cast a damaging skillSpell against a target
	 * 
	 * @param	skillSpell
	 * @param	target
	 * @return	Damage amount
	 */
	private static function damageSkillSpell(skillSpell:SkillSpell, target:Monster):Int {
		var e:Int = Std.parseInt(skillSpell.effectivity);
		
		// Check for resistances/weaknesses. Half for resist, 1.5x for weak.
		if (target.isResistantTo(skillSpell.element)) e = Std.int(e * 0.5);
		if (target.isWeakTo(skillSpell.element)) e = Std.int(e * 1.5);
		
		// Determine damage, and double it if the monster doesn't 'resist' the spell
		var damage = FlxG.random.int(e, e * 2);
		if (checkForHit(skillSpell, target)) damage *= 2;
		
		target.damage(damage);
		return damage;
	}
	
	/**
	 * Attempt to cast a status skillSpell against a target. Returns true if successful, false for miss
	 * 
	 * @param	skillSpell
	 * @param	target
	 * @return	True: Success, False: Miss
	 */
	private static function statusSkillSpell(skillSpell:SkillSpell, target:Monster):Bool {
		// 300HP Exceptions (STUN, BLND, XXXX) always hit if target HP is <= 300
		// and is not resistant to the element, otherwise is always misses
		switch(skillSpell.name.toUpperCase()) {
			case "STUN":
				if (target.hp <= 300 && !target.isResistantTo(skillSpell.element)) {
					target.addStatus(Monster.Status.PARALYZED);
					return true;
				}
				return false;
			case "BLND":
				if (target.hp <= 300 && !target.isResistantTo(skillSpell.element)) {
					target.addStatus(Monster.Status.BLIND);
					return true;
				}
				return false;
			case "XXXX":
				if (target.hp <= 300 && !target.isResistantTo(skillSpell.element)) {
					target.addStatus(Monster.Status.DEATH);
					return true;
				}
				return false;
		}
		
		// Check for a hit, then apply the status as necessary
		if (checkForHit(skillSpell, target)) {
			switch(skillSpell.effectivity.toUpperCase()) {
				case "DEATH":
					target.addStatus(Monster.Status.DEATH);
				case "PARALYZE":
					target.addStatus(Monster.Status.PARALYZED);
				case "PETRIFY":
					target.addStatus(Monster.Status.PETRIFIED);
				case "BLIND":
					target.addStatus(Monster.Status.BLIND);
				case "SLEEP":
					target.addStatus(Monster.Status.ASLEEP);
				case "CONFUSE":
					target.addStatus(Monster.Status.CONFUSED);
				case "SILENCE":
					target.addStatus(Monster.Status.SILENCED);
			}
			return true;
		}
		
		// Missed
		return false; 
	}
	
	/**
	 * Remove a status from the target monster
	 * TODO: Check what happens when attempting to cure a status that isn't applied
	 * 
	 * @param	skillSpell
	 * @param	target
	 */
	private static function restoreStatus(skillSpell:SkillSpell, target:Monster):Void {
		switch(skillSpell.name.toUpperCase()) {
			case "AMUT":
				target.removeStatus(Monster.Status.SILENCED);
			case "PURE":
				target.removeStatus(Monster.Status.POISONED);
			case "LAMP":
				target.removeStatus(Monster.Status.BLIND);
		}
	}
	
	/**
	 * Recover the target's HP based on the skillSpell's effectiveness, capped at 255
	 * 
	 * @param	skillSpell
	 * @param	target
	 * @return	Heal amount
	 */
	private static function healSkillSpell(skillSpell:SkillSpell, target:Monster):Int {
		var e:Int = Std.parseInt(skillSpell.effectivity);
		
		// NES BUG: HEL2's effectivity is normally double (48) what it should be (24)
		if (Globals.BUG_FIXES && skillSpell.name == "HEL2") e = 24;
		
		var healAmount = FlxG.random.int(e, e * 2);
		if (healAmount > 255) healAmount = 255;
		target.heal(healAmount); 
		return healAmount;
	}
	
	/**
	 * Apply a buff to the target
	 * 
	 * @param	skillSpell
	 * @param	target
	 */
	private static function buffSkillSpell(skillSpell:SkillSpell, target:Monster):Bool {
		return target.addBuff(skillSpell.name);
	}
	
	/**
	 * Attempt to apply a debuff to the target
	 * 
	 * @param	skillSpell
	 * @param	target
	 */
	private static function debuffSkillSpell(skillSpell:SkillSpell, target:Monster):Bool {
		if (checkForHit(skillSpell, target)) {
			return target.addDebuff(skillSpell.name);
		}
		return false;
	}
	
	/**
	 * Fully target's HP and clear negative statuses
	 * 
	 * @param	target
	 */
	private static function fullHeal(target:Monster):Void {
		target.fullHeal();
	}
	
	/**
	 * Check for a skillSpell "hit". Determines if status effects hit, or if damage is resisted
	 * 
	 * @param	skillSpell
	 * @param	target
	 * @return	True: Hit, False: Miss
	 */
	private static function checkForHit(skillSpell:SkillSpell, target:Monster):Bool {
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
		if (target.isResistantTo(skillSpell.element)) BC = 0;
		if (target.isWeakTo(skillSpell.element)) BC += 40;
		
		// Chance to Hit
		var chanceToHit = BC + skillSpell.accuracy - target.magicDefense;
		if (chanceToHit < 0) chanceToHit = 0;
		
		// 0 always hits, 200 always misses
		var hitRoll = FlxG.random.int(0, 200);
		if (hitRoll == 200) return false;
		if (hitRoll <= chanceToHit) return true;
		return false;
	}
}
