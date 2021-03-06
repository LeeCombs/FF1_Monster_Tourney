package;

enum ActionType {
	ATTACK;
	SPELL;
	SKILL;
	STATUS_EFFECT;
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
