package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

class PlayState extends FlxState {
	var text1:FlxText;
	var text2:FlxText;
	var monster1:Monster;
	var monster2:Monster;
	
	override public function create():Void {
		super.create();
		
		text1 = new FlxText(0, 150);
		add(text1);
		text2 = new FlxText(250, 150);
		add(text2);
		
		var btn:FlxButton = new FlxButton(125, 50, "Get Moves", getMonsterActions);
		add(btn);
		
		monster1 = new Monster(0, 0, "Tyro");
		monster2 = new Monster(250, 0, "Eye");
		monster2.facing = FlxObject.LEFT;
		
		add(monster1);
		add(monster2);
		
		getMonsterActions();
	}
	
	private function getMonsterActions():Void {
		text1.text = monster1.getAction();
		text2.text = monster2.getAction();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
