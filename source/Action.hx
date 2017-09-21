package;

enum ActionType {
	Attack; Spell; Skill;
}

typedef Action = {
	var actionName:String;
	var actionType:ActionType;
}

typedef ActionResult = {
	var message:String;
	var damage:Int;
	var hits:Int;
}
