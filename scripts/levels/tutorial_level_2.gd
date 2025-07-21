extends AbstractTutorialLevel

func get_level_number() -> int:
	return 2;
func get_next_level_number() -> int:
	return 3
	
func get_player_spawn_position() -> Vector3:
	return Vector3(1.5, 0, -1.5);
func get_ai_spawn_locations() -> Array:
	return [
		Vector3(-1.5, 0, 2.5), 
		Vector3(-3.5, 0, 2.5), 
		Vector3(1.5, 0, 2.5), 
		Vector3(3.5, 0, 2.5)
		]
	
func get_tutorial_text() -> String:
	return "Now knock all of the remaining opposing players off of the map"

func is_win_condition_met() -> bool:
	return are_all_ais_gone()
