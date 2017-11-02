package;

import flixel.FlxGame;
import flixel.FlxCamera;
import haxe.unit.TestRunner;
import openfl.Lib;
import openfl.display.Sprite;
import tests.*;

class Main extends Sprite {
	public function new() {
		// Initializer the managers
		MonsterManager.loadData();
		SkillSpellManager.loadData();
		
		super();
		// addChild(new FlxGame(640, 360, SceneBuilder));
		addChild(new FlxGame(640, 360, PlayState));
	}
}
