package;
import flixel.FlxG;
import haxe.xml.Fast;
import openfl.Assets;

class MagicManager {
	// E = Effectivity. Determined by Spell. (Effectively capped at 255)
	// SA = Spell Accuracy. Determined by Spell.
	// MD = Magic Defense. Determined by Target.
	// BC = Base Chance to Hit = 148
	
	private var spells:Fast;
	
	public function new() {
		var sdXML = Assets.getText("assets/data/spellData.xml");
		var spellDataXML = Xml.parse(sdXML);
		var fast:Fast = new Fast(spellDataXML.firstElement());
		spells = fast.node.spells;
	}
	
	public function getSpell(spellName:String):Spell {
		trace("Get Spell: " + spellName.toUpperCase());
		
		var spell:Spell = new Spell();
		
		var sn = spellName.toUpperCase();
		for (s in spells.nodes.spell) {
			if (s.node.name.innerData == sn) {
				spell.name = s.node.name.innerData;
				spell.id = s.node.id.innerData;
				spell.effectivity = s.node.effectivity.innerData;
				spell.accuracy = Std.parseInt(s.node.accuracy.innerData);
				spell.element = s.node.element.innerData;
				spell.target = s.node.target.innerData;
				spell.effect = s.node.effect.innerData;
				return spell;
			}
		}
		
		return null;
	}
	
	public function castSpell(spell:Spell, target:Monster) {
		trace("Casting spell: " + spell.name + ", effect: " + spell.effect);
		switch (spell.effect) {
			case "Nothing":
				//
			case "Damage":
				// FIRE, LIT, ICE, FIR2, LIT2, ICE2, FIR3, LIT3, ICE3, FADE, NUKE
				attackSpell(spell, target);
			case "Undead Damage":
				// HARM, HRM2, HRM3, HRM4
			case "Status Ailment":
				// SLEP, MUTE, DARK, HOLD, SLP2, CONF
				// BANE, RUB, QAKE, BRAK, STOP, ZAP!, XXXX
				statusSpell(spell, target);
			case "Hit Multiplier Down":
				// SLOW, SLO2
			case "Morale Down":
				// FEAR
			case "[Unused]":
				//
			case "HP Recovery":
				// CURE, CUR2, HEAL, CURE3, HEL2, HEL3
				healSpell(spell, target);
			case "Restore Status":
				// LAMP, PURE, AMUT
			case "Defense Up":
				// FOG, FOG2
			case "Attack Up":
				// TMPR (fix)
			case "Hit Multiplier Up":
				// FAST
			case "Attack/Accuracy Up":
				// SABR
			case "Evasion Down":
				// LOCK, LOK2
			case "Full HP/Status Recovery":
				// CUR4
				fullHeal(target);
			case "Evasion Up":
				// RUSE, INVS, INV2
			case "Remove Resistance":
				// XFER
			case "300HP Status":
				// STUN, BLND
			default:
				FlxG.log.add("Invalid spell effect: " + spell.effect);
		}
	}
	
	/**
	 * Cast a damaging spell against a target
	 * 
	 * @param	spell
	 * @param	target
	 */
	private function attackSpell(spell:Spell, target:Monster) {
		trace("Casting attack spell: " + spell.name);
		
		var e:Int = Std.parseInt(spell.effectivity);
		
		// Check for resistances/weaknesses. Half for resist, 1.5x for weak.
		if (target.isResistantTo(spell.element)) e = Std.int(e * 0.5);
		if (target.isWeakTo(spell.element)) e = Std.int(e * 1.5);
		
		// Determine damage, and double it if the monster doesn't 'resist' the spell
		var damage = FlxG.random.int(e, e * 2);
		if (checkForHit(spell, target)) damage *= 2;
		
		target.damage(damage);
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
					// Apply Paralysis status
					target.addStatus(Monster.Status.Paralyzed);
					return true;
				}
				return false;
			case "BLND":
				if (target.hp <= 300 && !target.isResistantTo(spell.element)) {
					// Apply Blind status
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
	 * Recover the target's HP based on the spell's effectiveness
	 * @param	spell
	 * @param	target
	 */
	private function healSpell(spell:Spell, target:Monster) {
		var e:Int = Std.parseInt(spell.effectivity);
		var healAmount = FlxG.random.int(e, e * 2);
		if (healAmount > 255) healAmount = 255;
		// monster.heal(healAmount);
	}
	
	/**
	 * Fully target's HP and clear negative statuses
	 * @param	target
	 */
	private function fullHeal(target:Monster) {
		// monster.fullHeal();
		target.fullHeal();
	}
	
	/**
	 * 
	 * @param	SA			Spell's Accuracy
	 * @param	MD			Target's Magic Defense
	 * @param	resistant
	 * @param	weak
	 * @return
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
		if (target.isResistantTo(spell.element)) BC = 40;
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