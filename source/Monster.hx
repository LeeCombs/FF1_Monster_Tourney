package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author HellaBored
 */
class Monster extends FlxSprite {
	var hp:Int;
	var atk:Int;
	var acc:Int;
	var hits:Int;
	var crt:Int;
	var def:Int;
	var eva:Int;
	var mdef:Int;
	var mor:Int;
	var satk:String;
	var eatk:String;
	var type:String;
	var weak:String;
	var resi:String;
	var magic:Array<String>;
	var skill:Array<String>;

	public function new(?X:Float=0, ?Y:Float=0, ?Name:String) {
		super(X, Y);
		
		loadGraphic("assets/images/" + Name + "-ff1-nes.png");
		
		switch Name {
			case "Tyro":
				setStats(480, 65, 133, 1, 1, 10, 60, 200, 144);
				type = "Dragon";
			case "Eye":
				setStats(162, 30, 42, 1, 1, 30, 12, 92, 200);
				type = "Mage";
				resi = "Earth";
				magic = ["XXXX", "BRAK", "RUB", "LIT2", "HOLD", "MUTE", "SLOW", "SLEP"];
				skill = ["GLANCE", "SQUINT", "GAZE", "STARE"];
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
	
}