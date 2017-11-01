package;

import flixel.FlxGame;
import flixel.FlxCamera;
import haxe.unit.TestRunner;
import openfl.Lib;
import openfl.display.Sprite;
import tests.*;

class Main extends Sprite {
	public function new() {
		// Run tests
		#if debug
			var r = new TestRunner();
			r.add(new BattleSceneTest());
			r.run();
		#end
		
		// Initializer the managers
		MonsterManager.loadData();
		SkillSpellManager.loadData();
		
		super();
		addChild(new FlxGame(640, 360, SceneBuilder));
		// addChild(new FlxGame(640, 360, PlayState));
	}
}
