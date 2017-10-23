package;

import flixel.group.FlxGroup;
import flixel.ui.FlxButton;

class OptionsBox extends FlxGroup {

	private var x:Int;
	private var y:Int;
	
	private var startButton:FlxButton;
	public function new(X:Int = 0, Y:Int = 0) {
		super();
		x = X;
		y = Y;
		
		startButton = new FlxButton(x, y, "Start");
		add(startButton);
		
	}
	
	public function setStartCallback(OnClick:Void -> Void) {
		startButton.onUp.callback = OnClick;
	}
	
}