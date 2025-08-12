class_name Bolty extends Player

# Interface Methods
func _init_combat_actions() -> void:
	combat_action_3 = ThrowRockAction.new()
	combat_action_3.projectile_spawner = level.projectile_spawner
