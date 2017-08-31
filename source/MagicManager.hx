package;
import flixel.FlxG;
import haxe.xml.Fast;
import openfl.Assets;

/**
 * ...
 * @author HellaBored
 */
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
	
	public function castSpell(spellName:String):Spell {
		var sn = spellName.toUpperCase();
		
		var spell:Spell = new Spell();
		
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
	
	public function heal(e:Int) {
		/*
		HP Recovered = E...2E (max 255)
		
		CUR4 does not use this formula, but rather, sets HP to max and clears 
		negative status.
		
		Note that out-of-battle, healing magic does not use these formulas. Rather,
		each spell is programmed to restore a set amount of HP, plus a variable
		range. These values are listing in F(1) below.
		*/
		var recovered = FlxG.random.int(e, e * 2);
		if (recovered > 255) recovered = 255;
		return recovered;
	}
	
	public function attack():Int {
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
		return 0;
	}
	
	public function getChanceToHit(SA:Int, MD:Int, resistant:Bool, weak:Bool):Int {
		/*
		NOTE: Status spells can hit or miss, which is determined by this calculation.
		Damaging spells always "hit," but may be "resisted," in which case the doubling
		component of the damage calculation does not occur, and the spell does only
		half of its potential damage.
		*/
		
		// Base Chance to Hit
		var BC:Int = 148; // Base Chance
		if (resistant) BC = 0;
		if (weak) BC += 40;
		
		// Chance to Hit
		var chanceToHit = BC + SA - MD;
		
		// Exceptions
		// - Positivity effects always hit
		// -- HP Recovery, Restore Status, Defense Up, Resist Element, Attack Up, Hit Up, Attak/Acc Up, FullHp/StatusRecovery, Evasion Up
		// - 300HP Threshold Spells (STUN, BLND, XXXX) always hit if not resistant and current HP <= 300, always miss otherwise
		
		return 0;
	}
}