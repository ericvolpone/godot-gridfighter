extends TutorialLevel

func get_level_number() -> int:
	return 2;
func get_next_level_number() -> int:
	return 3

func get_ai_count() -> int:
	return 4;
	
func get_tutorial_text() -> String:
	return "Now knock all of the remaining opposing players off of the map"

func is_win_condition_met() -> bool:
	return are_all_ais_gone()
