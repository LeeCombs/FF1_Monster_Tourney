package;

import flixel.FlxState;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.StrNameLabel;

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
	
	var dd:FlxUIDropDownMenu;
	
	private function dropDownHandler(ddInput:String) {
		trace(ddInput);
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
	}

	override public function create():Void {
		super.create();
		
		trace(sceneAPositions);
		trace(sceneBPositions);
		trace(sceneCPositions);
		trace(sceneDPositions);
		
		var sNLA:StrNameLabel = new StrNameLabel("A", "Scene A");
		var sNLB:StrNameLabel = new StrNameLabel("B", "Scene B");
		var sNLC:StrNameLabel = new StrNameLabel("C", "Scene C");
		var sNLD:StrNameLabel = new StrNameLabel("D", "Scene D");
		
		dd = new FlxUIDropDownMenu(25, 25, [sNLA, sNLB, sNLC, sNLD], dropDownHandler);
		add(dd);
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
	
}
