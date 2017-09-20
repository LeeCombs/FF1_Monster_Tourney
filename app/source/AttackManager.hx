package;

import Monster.Status;
import flixel.FlxG;
import Action;

class AttackManager {
	// A = Attack  	(Listed in game as "Damage")
	// D = Defense (Listed in-game as "Absorb")
	// H = Hit % (Accuracy)
	// E = Evasion
	// BC = Base Chance to Hit
	
	private var useOriginalFormula:Bool = true;

	public function new() {
		//
	}
	
	public function attack(attacker:Monster, target:Monster):ActionResult {
		
		var hits = attacker.hits;
		// Check for FAST buff and SLOW debuff
		// if (attacker.hasBuff("FAST")) hits++;
		// if (attacker.hasDebuff("SLOW")) hits--;
		
		// Minimum # of hits is 1
		if (hits < 1) hits = 1;
		
		// Calculate damage seperately for each hit
		// Minimum damage value for each hit is 1
		// Total damage from an attack is the sum of all hits
		var damageSum:Int = 0;
		var totalHits:Int = 0;
		var critFlag:Bool = false;
		for (i in 0...attacker.hits) {
			// Get damage for successful hits
			var crit = checkForCritical(attacker);
			if (crit) critFlag = true;
			
			if (checkForHit(attacker, target)) {
				totalHits++;
				damageSum += getDamage(attacker, target, crit);
			}
		}
		target.damage(damageSum);
		
		if (totalHits == 0) return { success:false, message:"miss", value:0 };
		if (critFlag) return { success:true, message:"Critical Hit!", value:damageSum };
		return { success:true, message:"Hits: " + Std.string(hits), value:damageSum };
	}
	
	private function getDamage(attacker:Monster, target:Monster, crit:Bool):Int {
		var atk = attacker.atk;
		
		// If target is weak to an Elemental or Enemy-Type attribute of weap, add +4 to A
		// NES Bug ignores this addition
		if (!useOriginalFormula && target.isWeakTo(attacker.elem)) atk += 4;
		
		// If target is asleep or paralyzed, A = A*5/4
		if (target.checkForStatus(Status.Asleep) || target.checkForStatus(Status.Paralyzed)) {
			atk = Std.int(atk * 5 / 4);
		}
		
		// Damage = A...2A - D
		// Critical Damage = (A...2A) + (A...2A - D)
		// Both (A...2A) is same value
		var damageRoll:Int = FlxG.random.int(atk, atk * 2);
		var damage:Int = damageRoll - target.def;
		if (crit) damage += damageRoll;
		// if (checkForCritical(attacker)) damage += damageRoll;
		
		// Minimum damage is 1
		if (damage < 1) damage = 1;
		return damage;
	}
	
	public function checkForHit(attacker:Monster, target:Monster):Bool {
		// Base Chance to Hit
		var BC:Int = 168;
		if (attacker.checkForStatus(Status.Blind)) BC -= 40;
		if (target.checkForStatus(Status.Blind)) BC += 40;
		
		// If target is weak to the attack, BC += 40
		// NES bug ignores this addition
		if (!useOriginalFormula && target.isWeakTo(attacker.elem)) {
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
				var totalHit = BC + attacker.acc;
				if (totalHit > 255) totalHit = 255;
				chanceToHit = totalHit - target.eva;
			}
		}
		else {
			// Use fixed formula
			chanceToHit = BC + attacker.acc;
			// Subtract evasion if the target is neither asleep nor paralyzed
			if (!target.checkForStatus(Status.Asleep) && !target.checkForStatus(Status.Paralyzed)) {
				chanceToHit =- target.eva;
			}
		}
		
		// 0 always hits, 200 always misses
		if (chanceToHit < 0) chanceToHit = 0;
		var hitRoll = FlxG.random.int(0, 200);
		if (hitRoll == 200) return false;
		if (hitRoll <= chanceToHit) return true;
		
		return false;
	}
	
	private function checkForCritical(attacker:Monster):Bool {
		// Critical Rate = Weapon Index Number
		// For monsters: Critical Rate = Monster's Critial Rate
		var critRate = attacker.crt;
		
		var hitRoll = FlxG.random.int(0, 200);
		if (hitRoll == 200) return false;
		if (hitRoll <= critRate) return true;
		
		return false;
	}
	
	public function statusAttack(attacker:Monster, target:Monster):Bool {
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
		
		// NES formula
		// - If target is resistant to an enemy's weakness, BC = 0
		// Fixed formula
		// - If target is resistant to an enemy's attack element, BC = 0
		if (useOriginalFormula) {
			// TODO - iterate attacker's weaknesses and compare against target's resistances
		}
		else {
			if (target.isResistantTo(attacker.elem)) BC = 0;
		}
		
		// Chance to inflict
		var chanceToHit = BC - target.mdef;
		var hitRoll = FlxG.random.int(0, 200);
		if (hitRoll <= chanceToHit) return true;
		return false;
	}
}
