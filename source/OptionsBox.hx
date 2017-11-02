package;

import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.group.FlxGroup;
import flixel.ui.FlxButton;

class OptionsBox extends FlxGroup {

	private var x:Int;
	private var y:Int;
	
	public var startStopButton:FlxButton;
	public var resetButton:FlxButton;
	public var loadButton:FlxButton;
	
	public var teamOneInput:FlxInputText;
	public var teamTwoInput:FlxInputText;
	
	
	public var speedCheckBox:FlxUICheckBox;
	
	public function new(X:Int = 0, Y:Int = 0) {
		super();
		x = X;
		y = Y;
		
		startStopButton = new FlxButton(x, y, "Start");
		add(startStopButton);
		
		resetButton = new FlxButton(x + 100, y, "Reset");
		add(resetButton);
		
		loadButton = new FlxButton(x + 200, y, "Load");
		add(loadButton);
		
		speedCheckBox = new FlxUICheckBox(x, y - 20, null, null, "Speed");
		speedCheckBox.broadcastToFlxUI = false;
		add(speedCheckBox);
		
		teamOneInput = new FlxInputText(x, y - 60, 350, "B;FrGIANT,FrGIANT,FrWOLF,FrWOLF,FrWOLF,FrWOLF,FrWOLF,FrWOLF", 8);
		add(teamOneInput);
		
		teamTwoInput = new FlxInputText(x, y - 40, 350, "A;WIZARD,SENTRY,ASTOS,FIGHTER,IMP,MAGE,WzSAHAG,VAMPIRE,GHOST", 8);
		add(teamTwoInput);
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
	
	/**
	 * Set the Load button's on-click callback
	 * 
	 * @param	OnClick	The function the button should call on click
	 */
	public function setLoadCallback(OnClick:Void -> Void) {
		loadButton.onUp.callback = OnClick;
	}
	
}
