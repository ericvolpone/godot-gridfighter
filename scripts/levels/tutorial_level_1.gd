extends AbstractTutorialLevel

func get_player_spawn_position() -> Vector3:
	return Vector3(1.5, 0, -1.5);
func get_ai_spawn_locations() -> Array:
	return [Vector3(-1.5, 0, 1.5)]
	
func get_tutorial_text() -> String:
	return "Abstract Class Tutorial Text"

func is_win_condition_met() -> bool:
	return are_all_ais_gone()
