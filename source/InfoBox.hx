package;

import flixel.group.FlxGroup;
import flixel.text.FlxText;

/**
 * TODO: Determine if I like this or not, and whether it's worth keeping around
 */
class InfoBox extends FlxGroup {
	
	private var x:Int;
	private var y:Int;
	
	private var roundCounter = 0;
	private var turnCounter = 0;
	public var roundTextBox:TextBox;
	public var turnTextBox:TextBox;
	
	public var teamOneText:FlxText;
	public var teamTwoText:FlxText;
	
	public function new(x:Int = 0, y:Int = 0) {
		super();
		
		this.x = x;
		this.y = y;
		
		roundTextBox = new TextBox(x, y);
		roundTextBox.displayText("Round: 0");
		add(roundTextBox);
		
		turnTextBox = new TextBox(x + 100, y);
		turnTextBox.displayText("Turn: 0");
		add(turnTextBox);
		
		teamOneText = new FlxText(x, y + 50, 0, "Team 1\nTotal EXP:  0\nTotal Gold: 0");
		add(teamOneText);
		
		teamTwoText = new FlxText(x + 100, y + 50, 0, "Team 2\nTotal EXP:  0\nTotal Gold: 0");
		add(teamTwoText);
	}
	
	/**
	 * Increment and update the displayed Round count
	 */
	public function incrementRoundCounter():Void {
		roundTextBox.displayText("Round: " + Std.string(++roundCounter));
	}
	
	/**
	 * Increment and update the displayed Turn count
	 */
	public function incrementTurnCounter():Void {
		turnTextBox.displayText("Turn: " + Std.string(++turnCounter));
	}
	
	/**
	 * Reset and update the displayed Round count
	 */
	public function resetRoundCounter():Void {
		roundCounter = 1;
		roundTextBox.displayText("Round: 1");
	}
	
	/**
	 * Reset and update the displayed Turn count
	 */
	public function resetTurnCounter():Void {
		turnCounter = 1;
		turnTextBox.displayText("Turn: 1");
	}
	
	/**
	 * Set a team's Gold and EXP stats to be displayed
	 * 
	 * @param	TeamNumber
	 * @param	Gold
	 * @param	EXP
	 */
	public function setTeamStats(TeamNumber:Int, Gold:Int, EXP:Int) {
		if (TeamNumber == 1) {
			teamOneText.text = "Team 1\nTotal EXP:  " + Std.string(EXP) + "\nTotal Gold: " + Std.string(Gold);
		}
		if (TeamNumber == 2) {
			teamTwoText.text = "Team 2\nTotal EXP:  " + Std.string(EXP) + "\nTotal Gold: " + Std.string(Gold);
		}
	}
}