package;

import flixel.addons.ui.FlxUICheckBox;
import flixel.group.FlxGroup;
import flixel.ui.FlxButton;

class OptionsBox extends FlxGroup {

	private var x:Int;
	private var y:Int;
	
	public var startStopButton:FlxButton;
	public var resetButton:FlxButton;
	
	public var speedCheckBox:FlxUICheckBox;
	
	public function new(X:Int = 0, Y:Int = 0) {
		super();
		x = X;
		y = Y;
		
		startStopButton = new FlxButton(x, y, "Start");
		add(startStopButton);
		
		resetButton = new FlxButton(x + 100, y, "Reset");
		resetButton.width = 50;
		add(resetButton);
		
		speedCheckBox = new FlxUICheckBox(x, y - 20, null, null, "Speed");
		speedCheckBox.broadcastToFlxUI = false;
		add(speedCheckBox);
	}
	
	/**
	 * Set the Start/Stop button's on-click callback
	 * 
	 * @param	OnClick	The function the button should call on click
	 */
	public function setStartStopCallback(OnClick:Void -> Void) {
		startStopButton.onUp.callback = OnClick;
	}
	
	/**
	 * Set the Reset button's on-click callback
	 * 
	 * @param	OnClick	The function the button should call on click
	 */
	public function setResetCallback(OnClick:Void -> Void) {
		resetButton.onUp.callback = OnClick;
	}
	
}
