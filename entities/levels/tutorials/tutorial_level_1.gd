extends TutorialLevel

func get_level_number() -> int:
	return 1;
func get_next_level_number() -> int:
	return 2

func get_ai_count() -> int:
	return 1;
	
func get_tutorial_text() -> String:
	return "Knock the opposing player off the map!  Use 'E' to throw a rock"

func is_win_condition_met() -> bool:
	return are_all_ais_gone()
