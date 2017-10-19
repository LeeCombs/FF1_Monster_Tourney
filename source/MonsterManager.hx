package;
import flixel.FlxG;
import haxe.Json;
import openfl.Assets;

class MonsterManager {
	private static var monsterData = [];
	
	/**
	 * Initializer
	 */
	public static function loadData():Void {
		var monsterDataJSON = Assets.getText("assets/data/monsterData.json");
		monsterData = Json.parse(monsterDataJSON);
		
		for (mData in monsterData) {
			// Unsafe casting, converting strings of arrays to arrays of strings
			mData.name = mData.name; // This is necessary to have getMonsterByName work... it allows mData.name field access 
			mData.types = cast(parseStringToArray(mData.types));
			mData.resistances = cast(parseStringToArray(mData.resistances));
			mData.weaknesses = cast(parseStringToArray(mData.weaknesses));
			mData.spells = cast(parseStringToArray(mData.spells));
			mData.skills = cast(parseStringToArray(mData.skills));
		}
	}
	
	/**
	 * Retrieve a Monster object by given name
	 * 
	 * @param	monsterName	Display name of the monster (e.g. "IMP", "TYRO", "WarMECH")
	 * @return				The Monster object of the given name, null if not found
	 */
	public static function getMonsterByName(monsterName:String):Monster {
		for (mData in monsterData) {
			if (mData.name == monsterName) {
				return new Monster(mData);
			}
		}
		FlxG.log.warn("Error creating monster: " + monsterName);
		return null;
	}
	
	/**
	 * Convert a string of an array ("[A,B,C]"), into it's array counterpart ["A", "B", "C"]
	 * 
	 * @param	inputString	String of format: "[A,B,C]"
	 * @return				Array conversion format: ["A", "B", "C"], null if there's an error
	 */
	private static function parseStringToArray(inputString:String):Array<String> {
		if (inputString == "" || inputString == null) return null;
		
		// Remove the bracket surrounding bracket characters, split the string, and return it
		var trimString = inputString.substring(1, inputString.length - 1);
		return trimString.split(",");
	}
}
