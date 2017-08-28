package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author HellaBored
 */
class Monster extends FlxSprite {
	var hp:Int = 0;
	var atk:Int = 0;
	var acc:Int = 0;
	var hits:Int = 0;
	var crt:Int = 0;
	var def:Int = 0;
	var eva:Int = 0;
	var mdef:Int = 0;
	var mor:Int = 0;
	var satk:String = "";
	var eatk:String = "";
	var type:String = "";
	var weak:String = "";
	var resi:String = "";
	
	var spell:Array<String> = new Array<String>();
	var spellChance:Int = 0;
	var spellIndex:Int = 0;
	
	var skill:Array<String> = new Array<String>();
	var skillChance:Int = 0;
	var skillIndex:Int = 0;

	public function new(?X:Float=0, ?Y:Float=0, ?Name:String) {
		super(X, Y);
		
		var monsterName:String = Name.toUpperCase();
		
		loadGraphic("assets/images/" + monsterName + ".png");
		setFacingFlip(FlxObject.LEFT, true, false);
		
		switch monsterName {
			case "TYRO":
				setStats(480, 65, 133, 1, 1, 10, 60, 200, 144);
				type = "Dragon";
			case "EYE":
				setStats(162, 30, 42, 1, 1, 30, 12, 92, 200);
				type = "Mage";
				resi = "Earth";
				spell = ["XXXX", "BRAK", "RUB", "LIT2", "HOLD", "MUTE", "SLOW", "SLEP"];
				spellChance = 80;
				skill = ["GLANCE", "SQUINT", "GAZE", "STARE"];
				skillChance = 80;
			default:
				return;
		}
	}
	
	private function setStats(HP:Int, ATK:Int, ACC:Int, HITS:Int, CRT:Int, DEF:Int, EVA:Int, MDEF:Int, MOR:Int) {
		hp = HP;
		atk = ATK;
		acc = ACC;
		hits = HITS;
		crt = CRT;
		def = DEF;
		eva = EVA;
		mdef = MDEF;
		mor = MOR;
	}
	
	public function getAction():String {
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
		var outputString:String = "";
		if (spell.length > 0) {
			if (FlxG.random.int(0, 128) <= spellChance) {
				outputString += "spell : " + spell[spellIndex];
				spellIndex++;
				if (spellIndex >= spell.length) spellIndex = 0;
				return outputString;
			}
		}
		
		if (skill.length > 0) {
			if (FlxG.random.int(0, 128) <= skillChance) {
				outputString += "skill : " + skill[skillIndex];
				skillIndex++;
				if (skillIndex >= skill.length) skillIndex = 0;
				return outputString;
			}
		}
		
		return "attack : attack";
	}
	
}