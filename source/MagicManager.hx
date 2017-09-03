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
				trace(spell);
				return spell;
			}
		}
		
		return null;
	}
	
	public function castSpell(spell:Spell, target:Monster) {
		switch (spell.effect) {
			case "Nothing":
				//
			case "Damage":
				//
			case "Undead Damage":
				//
			case "Status Ailment":
				//
			case "Hit Multiplier Down":
				//
			case "Morale Down":
				//
			case "[Unused]":
				//
			case "HP Recovery":
				healSpell(spell, target);
			case "Restore Status":
				//
			case "Defense Up":
				//
			case "Attack Up":
				//
			case "Hit Multiplier Up":
				//
			case "Attack/Accuracy Up":
				//
			case "Full HP/Status Recovery":
				fullHeal(target);
			case "Evasion Up":
				//
			case "Remove Resistance":
				//
			case "300 HP Status":
				//
			default:
				FlxG.log.add("Invalid spell effect: " + spell.effect);
		}
	}
	
	private function attackSpell(e:Int):Int {
		/*
		Resisted Attack Spell
		Damage = E...2E
		
		Unresisted Attack Spell
		Damage = 2(E...2E)
		
		--If target is resistant to spell element, divide effectivity by 2
		--If the target is weak to spell element, multiply effectivity by 1.5
		
		To determine whether a spell is resisted, look to whether the hit roll 
		(described in B below) succeeds. If it does, the E...2E value is doubled. If
		it does not, the value remains E...2E.
		*/
		var damage = FlxG.random.int(e, e * 2);
		
		return damage;
	}
	
	private function statusSpell(spell:Spell, target:Monster) {
		//
	}
	
	/**
	 * Recover the target's HP based on the spell's effectiveness
	 * @param	spell
	 * @param	target
	 */
	private function healSpell(spell:Spell, target:Monster) {
		// CURE, CUR2, HEAL, CURE3, HEL2, HEL3
		var e:Int = Std.parseInt(spell.effectivity);
		var healAmount = FlxG.random.int(e, e * 2);
		if (healAmount > 255) healAmount = 255;
		// monster.recover(healAmount);
	}
	
	/**
	 * Fully target's HP and clear negative statuses
	 * @param	target
	 */
	private function fullHeal(target:Monster) {
		// CUR4
		// monster.fullHeal();
	}
	
	private function checkForHit(SA:Int, MD:Int, resistant:Bool, weak:Bool):Bool {
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
		if (resistant) BC = 0;
		if (weak) BC += 40;
		
		// Chance to Hit
		var chanceToHit = BC + SA - MD;
		
		var hitRoll = FlxG.random.int(0, 200);
		
		if (hitRoll <= chanceToHit) return true;
		return false;
		
	}
}