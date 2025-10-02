class_name Bolty extends Hero

# Interface Methods
func _init_combat_actions() -> void:
	combat_action_3 = StormAction.new()
	combat_action_3.name = "StormAction"
	combat_action_4 = GustAction.new()
	combat_action_4.name = "GustAction"
