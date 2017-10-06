package;

import flixel.FlxState;


class SceneBuilder extends FlxState {

	override public function create():Void {
		super.create();
		
		/* Offsets
		 * A:
		 * x - 6, 39, 72
		 * y - 38, 71, 104
		 * 
		 * B:
		 * M - (6,38)    (6,88)
		 * L - (55, 38)  (88, 38)
		 * 	   (55, 71)  (88, 71)
		 * 	   (55, 104) (88, 104)
		 * 
		 * C:
		 * x - 9, 68
		 * y - 38, 88
		 * 
		 * D: 9, 40
		 */
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
	
}
