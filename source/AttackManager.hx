package;

import flixel.FlxG;
import Action;
import Monster.Buff;
import Monster.Debuff;
import Monster.Status;

class AttackManager {
	public static var useOriginalFormula:Bool = true;
	
	/**
	 * Apply an attack attempt from a monster to it's target
	 * 
	 * @param	attacker	The Monster attacking
	 * @param	target		The target Monster of the attack
	 * @return				The result of the attempted attack
	 */
	public static function attack(attacker:Monster, target:Monster):ActionResult {
		var hits = attacker.hits;
		
		// Calculate damage seperately for each hit
		// Minimum damage value for each hit is 1
		// Total damage from an attack is the sum of all hits
		var damageSum:Int = 0;
		var totalHits:Int = 0;
		var critFlag:Bool = false;
		for (i in 0...hits) {
			// Get damage for successful hits
			var crit = checkForCritical(attacker);
			if (crit) critFlag = true;
			
			if (checkForHit(attacker, target)) {
				totalHits++;
				damageSum += getDamage(attacker, target, crit);
			}
		}
		target.damage(damageSum);
		
		if (totalHits == 0) return { message:"", damage:0, hits:0 };
		var result = { message:"", damage:damageSum, hits:totalHits };
		if (critFlag) result.message = "Critical hit!!";
		return result;
	}
	
	/**
	 * Get the amount of damage dealt by an attack by a monster to it's target
	 * 
	 * @param	attacker	Monster dealing the attack
	 * @param	target		Monster targeted by the attack
	 * @param	crit		Whether the attack was a critcal hit or not
	 * @return				The amount of damage applied to the target
	 */
	private static function getDamage(attacker:Monster, target:Monster, crit:Bool):Int {
		var atk = attacker.attack;
		
		// If target is weak to an Elemental or Enemy-Type attribute of weap, add +4 to A
		// NES Bug ignores this addition
		if (!useOriginalFormula && target.isWeakTo(attacker.element)) atk += 4;
		
		// If target is asleep or paralyzed, A = A*5/4
		if (target.checkForStatus(Status.Asleep) || target.checkForStatus(Status.Paralyzed)) {
			atk = Std.int(atk * 5 / 4);
		}
		
		// Damage = A...2A - D
		// Critical Damage = (A...2A) + (A...2A - D)
		// Both (A...2A) is same value
		var damageRoll:Int = FlxG.random.int(atk, atk * 2);
		var damage:Int = damageRoll - target.defense;
		if (crit) damage += damageRoll;
		
		// Minimum damage is 1
		if (damage < 1) damage = 1;
		return damage;
	}
	
	/**
	 * Check if an attacker lands a hit on it's target
	 * 
	 * @param	attacker	Monster who is attacking
	 * @param	target		Monster being targeted by attack
	 * @return				Whether the attack hit or not
	 */
	public static function checkForHit(attacker:Monster, target:Monster):Bool {
		// Base Chance to Hit
		var BC:Int = 168;
		if (attacker.checkForStatus(Status.Blind)) BC -= 40;
		if (target.checkForStatus(Status.Blind)) BC += 40;
		
		// If target is weak to the attack, BC += 40
		// NES bug ignores this addition
		if (!useOriginalFormula && target.isWeakTo(attacker.element)) {
			BC += 40;
		}
		
		// Calculating chance to hit...
		// NES formula
		// - Chance = (BC + H) - E
		// -- (BC + H) is capped at 255
		// - If target is asleep/paralyzed, Chance = BC
		// Fixed formula
		// - Chance = BC + H - E
		// - If target asleep/paralyzed: Chance = BC + H
		var chanceToHit:Int;
		if (useOriginalFormula) {
			// Use NES formula
			if (target.checkForStatus(Status.Asleep) || target.checkForStatus(Status.Paralyzed)) {
				chanceToHit = BC;
			}
			else {
				var totalHit = BC + attacker.accuracy;
				if (totalHit > 255) totalHit = 255;
				chanceToHit = totalHit - target.evasion;
			}
		}
		else {
			// Use fixed formula
			chanceToHit = BC + attacker.accuracy;
			// Subtract evasion if the target is neither asleep nor paralyzed
			if (!target.checkForStatus(Status.Asleep) && !target.checkForStatus(Status.Paralyzed)) {
				chanceToHit =- target.evasion;
			}
		}
		
		// 0 always hits, 200 always misses
		if (chanceToHit < 0) chanceToHit = 0;
		var hitRoll = FlxG.random.int(0, 200);
		if (hitRoll == 200) return false;
		if (hitRoll <= chanceToHit) return true;
		
		return false;
	}
	
	/**
	 * Check if an attack lands a critical hit
	 * 
	 * @param	attacker
	 * @return	Whether the attack was a critical hit or not
	 */
	private static function checkForCritical(attacker:Monster):Bool {
		// Critical Rate = Weapon Index Number
		// For monsters: Critical Rate = Monster's Critial Rate
		var critRate = attacker.critRate;
		
		// 0 always hits, 200 always misses
		var hitRoll = FlxG.random.int(0, 200);
		if (hitRoll == 200) return false;
		if (hitRoll <= critRate) return true;
		
		return false;
	}
	
	/**
	 * Check if an attack applies a status effect
	 * 
	 * @param	attacker
	 * @param	target
	 * @return	Whether the attack applied a status effect or not
	 */
	public static function statusAttack(attacker:Monster, target:Monster):Bool {
		/*
		* Making this note here for now...
		* 
		* NES BUG
		* Most misses following a successful hit get a chance to inflict the status
		* as well. Misses because of rolling a 200 do not get another chance.
		* 
		* H = Hit
		* M = Normal Miss
		* X = Miss from rolling 200
		* * = Chance to inflict status
		* 
		* NES: M M H* M* M* X M* H* X
		* Fix: M M H* M  M  X M  H* X
		*/
		var BC = 100;
		
		// NES BUG: Target checks attacker's weaknesses instead of attacking element
		if (!Globals.BUG_FIXES) {
			// Iterate attacker's weaknesses and compare against target's resistances
			for (weakness in attacker.weaknesses) {
				if (target.isResistantTo(weakness)) {
					BC = 0;
					break;
				}
			}
		}
		else {
			if (target.isResistantTo(attacker.element)) BC = 0;
		}
		
		// Chance to inflict
		var chanceToHit = BC - target.magicDefense;
		var hitRoll = FlxG.random.int(0, 200);
		if (hitRoll <= chanceToHit) return true;
		return false;
	}
}
