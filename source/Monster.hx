package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Monster extends FlxSprite {
	public var monsterName:String;
	
	public var hp:Int = 0;
	public var hpMax:Int = 0;
	public var atk:Int = 0;
	public var acc:Int = 0;
	public var hits:Int = 0;
	public var crt:Int = 0;
	public var def:Int = 0;
	public var eva:Int = 0;
	public var mdef:Int = 0;
	public var mor:Int = 0;
	public var satk:String = "";
	public var eatk:String = "";
	public var type:String = "";
	public var weak:Array<String> = [];
	public var resi:Array<String> = [];
	
	var spell:Array<String> = new Array<String>();
	var spellChance:Int = 0;
	var spellIndex:Int = 0;
	
	var skill:Array<String> = new Array<String>();
	var skillChance:Int = 0;
	var skillIndex:Int = 0;
	
	private var statuses:Array<String> = [];
	private var buffs:Array<String> = [];

	public function new(?X:Float=0, ?Y:Float=0, ?Name:String) {
		super(X, Y);
		
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
		var action:Action = { actionType: "SETME", actionName: "SETME" };
		
		if (spell.length > 0) {
			if (FlxG.random.int(0, 128) <= spellChance) {
				action.actionType = "spell";
				action.actionName = spell[spellIndex++];
				if (spellIndex >= spell.length) spellIndex = 0;
				return action;
			}
		}
		
		if (skill.length > 0) {
			if (FlxG.random.int(0, 128) <= skillChance) {
				action.actionType = "skill";
				action.actionName = skill[skillIndex++];
				if (skillIndex >= skill.length) skillIndex = 0;
				return action;
			}
		}
		
		// Default attack action
		action.actionType = "attack";
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
		
		hp -= value;
		if (hp <= 0) kill();
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
