package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.StrNameLabel;
import flixel.ui.FlxButton;

class SceneBuilder extends FlxState {
	
	// 3x3 small grid
	private var sceneAPositions:Map<String,Array<Array<Int>>> = [
		"small" => [for (i in 0...3) for (j in 0...3) [6 + i * 33, 38 + j * 33]], 
		"medium" => [], 
		"large" => []
	];
	
	// 2x1 medium, 2x3 small
	private var sceneBPositions:Map<String,Array<Array<Int>>> = [
		"small" => [for (i in 0...2) for (j in 0...3) [55 + i * 33, 88 + j * 33]], 
		"medium" => [[6, 38], [6, 88]], 
		"large" => []
	];
	
	// 2x2 medium grid
	private var sceneCPositions:Map<String,Array<Array<Int>>> = [
		"small" => [], 
		"medium" => [for (i in 0...2) for (j in 0...2) [9 + i * 59, 38 + j * 50]], 
		"large" => []
	];
	
	// Single large; for CHAOS and Fiends basically
	private var sceneDPositions:Map<String,Array<Array<Int>>> = [
		"small" => [], 
		"medium" => [], 
		"large" => [[9, 40]]
	];
	
	private var sceneSelector:FlxUIDropDownMenu;
	private var scene:FlxSprite;
	private var textInput:FlxInputText;
	private var generateSceneButton:FlxButton;
	
	/**
	 * 
	 */
	override public function create():Void {
		super.create();
		
		scene = new FlxSprite(25, 25);
		scene.loadGraphic("assets/images/BattleScreen_A.png");
		add(scene);
		
		generateSceneButton = new FlxButton(175, 25, "Generate");
		add(generateSceneButton);
		
		var sNLA:StrNameLabel = new StrNameLabel("A", "Scene A");
		var sNLB:StrNameLabel = new StrNameLabel("B", "Scene B");
		var sNLC:StrNameLabel = new StrNameLabel("C", "Scene C");
		var sNLD:StrNameLabel = new StrNameLabel("D", "Scene D");
		sceneSelector = new FlxUIDropDownMenu(175, 50, [sNLA, sNLB, sNLC, sNLD], dropDownHandler);
		add(sceneSelector);
		
		// TODO: Have unique text inputs for each slot determined by the selected scene
		for (i in 0...9) {
			add(new FlxInputText(325, 50 + i * 15, 100, "TYRO"));
		}
		// textInput = new FlxInputText(325, 50, 100, "IMP");
		// add(textInput);
		
		// TESTING: Example output text and parsing
		var outputText:String = "A;IMP,IMP,GrIMP,GrIMP,IMP,WOLF,CRALWER,IMP,WzVAMP";
		var trimText = outputText.split(";");
		trace("Scene: " + trimText[0]);
		for (m in trimText[1].split(",")) {
			trace("monster: " + m);
		}
	}
	
	/**
	 * Returns the string representation of the current scene
	 * @return	String representation of the scene, format: "TYPE;NAME,NAME,NAME..."
	 */
	private function generateOutputScene() {
		// start the output with the scene's type: A, B, C, or D
		// iterate over the monsters, and append their name to the string
		// ensure that empty slots are represented as "null"
		// return the string
		// this string will be parsed by the PlayState to populate the scenes
	}
	
	/**
	 * Handle the input selection from sceneSelector
	 * 
	 * @param	ddInput
	 */
	private function dropDownHandler(ddInput:String) {
		trace(ddInput);
		
		// Clear and update the available text inputs, as well as the displayed scene type
		switch(ddInput) {
			case "A":
				//
			case "B":
				//
			case "C":
				//
			case "D":
				//
			default:
				throw "Invalid DropDown input supplied: " + ddInput;
		}
		
		scene.loadGraphic("assets/images/BattleScreen_" + ddInput + ".png");
	}

	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
	
}
