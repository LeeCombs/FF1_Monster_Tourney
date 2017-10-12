package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.StrNameLabel;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class SceneBuilder extends FlxState {
	
	// Scene vars
	private var scene:FlxSprite;
	private var sceneSelector:FlxUIDropDownMenu;
	private var generateSceneButton:FlxButton;
	private var sceneAPositions:Map<String,Array<Array<Int>>> = [
		"small" => [for (i in 0...3) for (j in 0...3) [6 + i * 33, 38 + j * 33]], 
		"medium" => [], 
		"large" => []
	];
	private var sceneBPositions:Map<String,Array<Array<Int>>> = [
		"small" => [for (i in 0...2) for (j in 0...3) [55 + i * 33, 88 + j * 33]], 
		"medium" => [[6, 38], [6, 88]], 
		"large" => []
	];
	private var sceneCPositions:Map<String,Array<Array<Int>>> = [
		"small" => [], 
		"medium" => [for (i in 0...2) for (j in 0...2) [9 + i * 59, 38 + j * 50]], 
		"large" => []
	];
	private var sceneDPositions:Map<String,Array<Array<Int>>> = [
		"small" => [], 
		"medium" => [], 
		"large" => [[9, 40]]
	];
	
	// Input vars
	private var textInput:FlxInputText;
	private var textInputArray:Array<FlxInputText> = [];
	private var activeTextInputArray:Array<FlxInputText> = [];
	private var flxTextArray:Array<FlxText> = [];
	private var outputText:FlxInputText;
	
	// temp?
	private var monsterArr:FlxGroup;
	private var sizeArray:Array<String> = []; 
	
	/**
	 * Initializer
	 */
	override public function create():Void {
		super.create();
		
		// Setup scene 
		scene = new FlxSprite(25, 25);
		scene.loadGraphic("assets/images/BattleScreen_A.png");
		add(scene);
		
		generateSceneButton = new FlxButton(285, 25, "Generate", generateOutputScene);
		add(generateSceneButton);
		
		var sNLArr:Array<StrNameLabel> = [];
		for (s in ["A", "B", "C", "D"]) {
			sNLArr.push(new StrNameLabel(s, "Scene " + s));
		}
		
		sceneSelector = new FlxUIDropDownMenu(285, 75, sNLArr, dropDownHandler);
		sceneSelector.broadcastToFlxUI = false;
		add(sceneSelector);
		
		// Setup text inputs and generated output string
		for (i in 0...9) {
			var textInput:FlxInputText = new FlxInputText(175, 25 + i * 15, 100, ".");
			textInput.text = "";
			textInput.backgroundColor = FlxColor.BLUE.getLightened(.6);
			add(textInput);
			textInputArray.push(textInput);
			
			var text:FlxText = new FlxText(160, 25 + i * 15, 0, ["A", "B", "C", "D", "E", "F", "G", "H", "I"][i]);
			add(text);
			flxTextArray.push(text);
		}
		
		activeTextInputArray = textInputArray;
		activeTextInputArray[0].hasFocus = true;
		
		outputText = new FlxInputText(285, 50, 200, "output shows up here", 8);
		add(outputText);
		
		monsterArr = new FlxGroup();
		add(monsterArr);
	}
	
	/**
	 * Handle tear-down and setup of a specific scene
	 * 
	 * @param	sceneSelection
	 */
	private function setupScene(sceneSelection:String) {
		// Clear and hide text input and display
		for (i in 0...9) {
			textInputArray[i].visible = false;
			textInputArray[i].text = "";
			flxTextArray[i].visible = false;
		}
		
		// Clear and update the available text inputs, as well as the displayed scene type
		activeTextInputArray = [];
		sizeArray = [];
		switch(sceneSelection) {
			case "A": // 3x3 Small Grid
				for (i in 0...9) {
					activeTextInputArray.push(textInputArray[i]);
					flxTextArray[i].visible = true;
					textInputArray[i].visible = true;
					textInputArray[i].backgroundColor = FlxColor.BLUE.getLightened(.6);
					sizeArray.push("small");
				}
			case "B": // 2x1 Medium, 2x3 Small
				for (i in 0...8) {
					activeTextInputArray.push(textInputArray[i]);
					flxTextArray[i].visible = true;
					textInputArray[i].visible = true;
					if (i >= 2) {
						textInputArray[i].backgroundColor = FlxColor.BLUE.getLightened(0.4);
						sizeArray.push("small");
					}
					else {
						textInputArray[i].backgroundColor = FlxColor.ORANGE.getLightened(0.4);
						sizeArray.push("medium");
					}
				}
			case "C": // 2x2 Medium Grid
				for (i in 0...4) {
					activeTextInputArray.push(textInputArray[i]);
					flxTextArray[i].visible = true;
					textInputArray[i].visible = true;
					textInputArray[i].backgroundColor = FlxColor.ORANGE.getLightened(0.4);
					sizeArray.push("medium");
				}
			case "D": // 1 Large Slot
				activeTextInputArray.push(textInputArray[0]);
				flxTextArray[0].visible = true;
				textInputArray[0].visible = true;
				textInputArray[0].backgroundColor = FlxColor.RED.getLightened(0.4);
				sizeArray.push("large");
			default:
				throw "Invalid sceneSelection supplied: " + sceneSelection;
		}
		
		// Set the default text input selection
		activeTextInputArray[0].hasFocus = true;
		
		// Update scene image
		scene.loadGraphic("assets/images/BattleScreen_" + sceneSelection + ".png");
		
	}
	
	/**
	 * Handle the input selection from sceneSelector
	 * 
	 * @param	ddInput
	 */
	private function dropDownHandler(ddInput:String) {
		if (ddInput == "" || ddInput == null) {
			trace("Invalid ddInput: " + ddInput);
			return;
		}
		setupScene(ddInput);
	}
	
	/**
	 * Returns the string representation of the current scene
	 * 
	 * @return	String representation of the scene, format: "TYPE;NAME,NAME,NAME..."
	 */
	private function generateOutputScene() {
		// start the output with the scene's type: A, B, C, or D
		// iterate over the monsters, and append their name to the string
		// ensure that empty slots are represented as "null"
		// return the string
		// this string will be parsed by the PlayState to populate the scenes
		
		
		var outputString:String = sceneSelector.selectedId + ";";
		for (i in 0...textInputArray.length) {
			if (textInputArray[i].visible) {
				// Remove outer whitespace and skip invalid input
				var nameString = StringTools.trim(textInputArray[i].text);
				if (nameString == null || nameString == "") outputString += ",";
				else {
					var monster = MonsterManager.getMonsterByName(nameString);
					if (monster == null || monster.mData.size != sizeArray[i]) {
						activeTextInputArray[i].backgroundColor = FlxColor.RED;
					}
					else {
						outputString += nameString;
						var x = 25 + sceneAPositions["small"][i][0];
						var y = 25 + sceneAPositions["small"][i][1];
						var mon = new FlxSprite(x, y);
						mon.loadGraphic("assets/images/Monsters/" + nameString + ".png");
						monsterArr.add(mon);
					}
					if (i < activeTextInputArray.length - 1) outputString += ",";
				}
			}
		}
		
		// Display the string and output it on the console, since that's the
		// only way I can get text copyable currently.
		trace(outputString);
		outputText.text = outputString;
	}

	/**
	 * Game logic
	 * 
	 * @param	elapsed
	 */
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.DOWN) {
			var index:Int = 0;
			for (t in activeTextInputArray) {
				if (t.hasFocus) {
					index = activeTextInputArray.indexOf(t) + 1;
					t.hasFocus = false;
					break;
				}
			}
			if (index >= activeTextInputArray.length) index = 0;
			textInputArray[index].hasFocus = true;
		}
		if (FlxG.keys.justPressed.UP) {
			var index:Int = 0;
			for (t in activeTextInputArray) {
				if (t.hasFocus) {
					index = activeTextInputArray.indexOf(t) - 1;
					t.hasFocus = false;
					break;
				}
			}
			if (index < 0) index = activeTextInputArray.length - 1;
			textInputArray[index].hasFocus = true;
		}
	}
	
}
