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
	private var textInputArray:Array<FlxInputText> = [];
	private var activeTextInputArray:Array<FlxInputText> = [];
	private var flxTextArray:Array<FlxText> = [];
	private var outputText:FlxInputText;
	private var monsterInputGroup:FlxTypedGroup<MonsterInput>;
	
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
		monsterInputGroup = new FlxTypedGroup<MonsterInput>();
		for (i in 0...9) {
			var monsterInput:MonsterInput = new MonsterInput(160, 25 + i * 15, ["A", "B", "C", "D", "E", "F", "G", "H", "I"][i]);
			monsterInput.kill();
			monsterInputGroup.add(monsterInput);
		}
		add(monsterInputGroup);
		setupScene("B");
		monsterInputGroup.members[0].textInput.text = "TYRO";
		monsterInputGroup.members[1].textInput.text = "IMP";
		monsterInputGroup.members[2].textInput.text = "IMP";
		monsterInputGroup.members[3].textInput.text = "TYRO";
		
		
		
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
		for (mi in monsterInputGroup.members) mi.kill();
		
		// Clear and update the available text inputs, as well as the displayed scene type
		switch(sceneSelection) {
			case "A": // 3x3 Small Grid
				for (i in 0...9) {
					var mi:MonsterInput = monsterInputGroup.members[i];
					mi.revive();
					mi.setSize("small");
				}
			case "B": // 2x1 Medium, 2x3 Small
				for (i in 0...8) {
					var mi:MonsterInput = monsterInputGroup.members[i];
					mi.revive();
					if (i >= 2) mi.setSize("small");
					else mi.setSize("medium");
				}
			case "C": // 2x2 Medium Grid
				for (i in 0...4) {
					var mi:MonsterInput = monsterInputGroup.members[i];
					mi.revive();
					mi.setSize("medium");
				}
			case "D": // 1 Large Slot
				var mi:MonsterInput = monsterInputGroup.members[0];
				mi.revive();
				mi.setSize("large");
			default:
				throw "Invalid sceneSelection supplied: " + sceneSelection;
		}
		
		// Set the default text input selection
		monsterInputGroup.members[0].textInput.hasFocus = true;
		
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
		for (mi in monsterInputGroup.members) {
			if (mi.alive) {
				// Remove outer whitespace and skip invalid input
				var nameString = StringTools.trim(mi.textInput.text);
				if (nameString == null || nameString == "") outputString += ",";
				else {
					var monster = MonsterManager.getMonsterByName(nameString);
					if (monster == null || monster.mData.size != mi.monsterSize) {
						mi.textInput.backgroundColor = FlxColor.RED;
					}
					else {
						outputString += nameString;
						var x = 25 + sceneAPositions["small"][monsterInputGroup.members.indexOf(mi)][0];
						var y = 25 + sceneAPositions["small"][monsterInputGroup.members.indexOf(mi)][1];
						var mon = new FlxSprite(x, y);
						mon.loadGraphic("assets/images/Monsters/" + nameString + ".png");
						monsterArr.add(mon);
					}
					// TODO: Don't do this if it's the last active member
					outputString += ",";
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
		
		// Note: Key input seems to be busted for my laptop, this must be checked on another pc
		// Handle up/down selection cycling for monster input fields
		if (FlxG.keys.justPressed.DOWN) {
			var index:Int = 0;
			for (mi in monsterInputGroup.members) {
				trace(mi);
				if (mi.textInput.hasFocus) {
					index = monsterInputGroup.members.indexOf(mi);
					mi.textInput.hasFocus = false;
					break;
				}
			}
			index++;
			if (index >= monsterInputGroup.length) index = 0;
			monsterInputGroup.members[index].textInput.hasFocus = true;
		}
		if (FlxG.keys.justPressed.UP) {
			var index:Int = 0;
			for (mi in monsterInputGroup.members) {
				trace(mi);
				if (mi.textInput.hasFocus) {
					index = monsterInputGroup.members.indexOf(mi);
					mi.textInput.hasFocus = false;
					break;
				}
			}
			index--;
			if (index <= 0) index = monsterInputGroup.length - 1;
			monsterInputGroup.members[index].textInput.hasFocus = true;
		}
	}
}
