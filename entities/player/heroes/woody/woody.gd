class_name Woody extends Hero

# Interface Methods
func _init_combat_actions() -> void:
	combat_action_3 = ThornTrapAction.new()
	combat_action_3.name = "ThornTrapAction"
	combat_action_4 = BushAction.new()
	combat_action_4.name = "BushAction"
