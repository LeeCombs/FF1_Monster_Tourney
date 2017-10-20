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
	
	// TODO: This is the same as Battle Scenes's positions.
	// Look into pulling from there
	private var sceneAPositions:Array<Array<Int>> = [for (i in 0...3) for (j in 0...3) [6 + i * 33, 38 + j * 33]];
	private var sceneBPositions:Array<Array<Int>> = [[6, 38], [6, 88], [55, 38], [55, 71], [55, 104], [88, 38], [88, 71], [88, 104]];
	private var sceneCPositions:Array<Array<Int>> = [for (i in 0...2) for (j in 0...2) [9 + i * 59, 38 + j * 50]];
	private var sceneDPositions:Array<Array<Int>> = [[9, 40]];
	
	// Input vars
	private var textInputArray:Array<FlxInputText> = [];
	private var activeTextInputArray:Array<FlxInputText> = [];
	private var flxTextArray:Array<FlxText> = [];
	private var outputText:FlxInputText;
	private var monsterInputGroup:FlxTypedGroup<MonsterInput>;
	
	// temp?
	private var monsterArr:FlxGroup;
	private var sizeArray:Array<String> = []; 
	private var infoBox:FlxText;
	
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
		
		infoBox = new FlxText(25, 25 + 144);
		add(infoBox);
		
		outputText = new FlxInputText(285, 50, 200, "output shows up here", 8);
		add(outputText);
		
		monsterArr = new FlxGroup();
		add(monsterArr);
		
		setupScene("A");
	}
	
	/**
	 * Handle tear-down and setup of a specific scene
	 * 
	 * @param	sceneSelection
	 */
	private function setupScene(sceneSelection:String):Bool {
		// Clear and hide text input and display
		for (mi in monsterInputGroup.members) mi.kill();
		for (m in monsterArr) m.destroy();
		infoBox.text = "";
		
		// Clear and update the available text inputs, as well as the displayed scene type
		switch(sceneSelection) {
			case "A": // 3x3 Small Grid
				infoBox.text = "Targeting Percentages\nABC = ~4.8%\nDEF = ~9.5%\nGHI = ~19%";
				for (i in 0...9) {
					var mi:MonsterInput = monsterInputGroup.members[i];
					mi.revive();
					mi.setSize("small");
				}
			case "B": // 2x1 Medium, 2x3 Small
				infoBox.text = "Targeting Percentages\nAB = ~5.9%\nCDE = ~11.7%\nFGH = ~23.5%";
				for (i in 0...8) {
					var mi:MonsterInput = monsterInputGroup.members[i];
					mi.revive();
					if (i >= 2) mi.setSize("small");
					else mi.setSize("medium");
				}
			case "C": // 2x2 Medium Grid
				infoBox.text = "Targeting Percentages\nAB = ~12.5%\nC = ~25%\nD = ~50%";
				for (i in 0...4) {
					var mi:MonsterInput = monsterInputGroup.members[i];
					mi.revive();
					mi.setSize("medium");
				}
			case "D": // 1 Large Slot
				infoBox.text = "Targeting Percentages\nA = 100%";
				var mi:MonsterInput = monsterInputGroup.members[0];
				mi.revive();
				mi.setSize("large");
			default:
				FlxG.log.warn("Invalid sceneSelection supplied: " + sceneSelection);
				return false;
		}
		
		// Set the default text input selection
		monsterInputGroup.members[0].textInput.hasFocus = true;
		
		// Update scene image
		scene.loadGraphic("assets/images/BattleScreen_" + sceneSelection + ".png");
		
		return true;
	}
	
	/**
	 * Handle the input selection from sceneSelector
	 * 
	 * @param	ddInput
	 */
	private function dropDownHandler(ddInput:String):Void {
		if (ddInput == "" || ddInput == null) {
			FlxG.log.warn("Invalid ddInput: " + ddInput);
			return;
		}
		setupScene(ddInput);
	}
	
	/**
	 * Generates and displays the current scene type and monster layout
	 * Formatted as "TYPE;NAME,NAME,NAME..."
	 * 
	 * TODO: Would be nice to copy this to the clipboard, or some selectable text
	 * Currently just displays and outputs the text to console...
	 */
	private function generateOutputScene():Void {
		// start the output with the scene's type: A, B, C, or D
		// iterate over the monsters, and append their name to the string
		// ensure that empty slots are represented as "null"
		// return the string
		// this string will be parsed by the PlayState to populate the scenes
		var selectedScene:String = sceneSelector.selectedId;
		
		var outputString:String = selectedScene + ";";
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
						var index = monsterInputGroup.members.indexOf(mi);
						var x:Int = 0;
						var y:Int = 0;
						switch(selectedScene) {
							case "A":
								x = 25 + sceneAPositions[index][0];
								y = 25 + sceneAPositions[index][1];
							case "B":
								x = 25 + sceneBPositions[index][0];
								y = 25 + sceneBPositions[index][1];
							case "C":
								x = 25 + sceneCPositions[index][0];
								y = 25 + sceneCPositions[index][1];
							case "D":
								x = 25 + sceneDPositions[index][0];
								y = 25 + sceneDPositions[index][1];
							default:
								trace("Invalid scene selected: " + selectedScene);
								break;
						}
						var mon = new FlxSprite(x, y);
						mon.loadGraphic("assets/images/Monsters/" + nameString.toUpperCase() + ".png");
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
			var activeGroup = [];
			for (mi in monsterInputGroup.members) {
				if (mi.alive) activeGroup.push(mi);
			}
			for (mi in activeGroup) {
				trace(mi);
				if (mi.textInput.hasFocus) {
					index = activeGroup.indexOf(mi);
					mi.textInput.hasFocus = false;
					break;
				}
			}
			index++;
			if (index >= activeGroup.length) index = 0;
			activeGroup[index].textInput.hasFocus = true;
		}
		if (FlxG.keys.justPressed.UP) {
			var index:Int = 0;
			var activeGroup = [];
			for (mi in monsterInputGroup.members) {
				if (mi.alive) activeGroup.push(mi);
			}
			for (mi in activeGroup) {
				trace(mi);
				if (mi.textInput.hasFocus) {
					index = activeGroup.indexOf(mi);
					mi.textInput.hasFocus = false;
					break;
				}
			}
			index--;
			if (index < 0) index = activeGroup.length - 1;
			activeGroup[index].textInput.hasFocus = true;
		}
	}
}
