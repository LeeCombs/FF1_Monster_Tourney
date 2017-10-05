package;
import haxe.Json;
import openfl.Assets;

class MonsterManager {
	
	static var monsterData = [];

	public function new() {
		trace("monsterData new()");
	}
	
	public static function loadData() {
		trace("loadData");
		var monsterDataJSON = Assets.getText("assets/data/monsterData.json");
		monsterData = Json.parse(monsterDataJSON);
	}
	
	public static function getMonsterByName(monsterName:String):Monster {
		trace("getMonsterByName: " + monsterName);
		for (mData in monsterData) {
			if (mData.name == monsterName) {
				return new Monster(mData);
			}
		}
		return null;
	}
	
}
