package;

import flixel.FlxGame;
import flixel.FlxCamera;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(640, 360, PlayState));
		
	}
}
