package;

enum ActionType {
	Attack; Spell; Skill;
}

typedef Action = {
	var actionName:String;
	var actionType:ActionType;
}
