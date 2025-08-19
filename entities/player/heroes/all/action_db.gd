class_name ActionDB

const action_db: Dictionary[StringName, StringName] = {
	# Generics
	"PunchAction" : "Punch",
	"BlockAction" : "Block",
	
	# Bolty
	"StormAction" : "Storm",
	"GustAction" : "Gust",
	
	# Rocky
	"ThrowRockAction" : "ThrowRock"
}

static func get_name_for_action(action: CombatAction) -> StringName:
	return action_db[action.get_script().get_global_name()]
