extends AbstractTutorialLevel

@onready var rock_scene: PackedScene = load("res://scenes/rock.tscn")
var time_to_stay_alive: float = 6.0;

func get_level_number() -> int:
	return 3;

func get_next_level_number() -> int:
	return 1
	
func _ready() -> void:
	super._ready();
	time_to_stay_alive = Time.get_unix_time_from_system() + time_to_stay_alive
	var rock: Rock = rock_scene.instantiate()
	rock.is_slow_disappearing = false;
	add_child(rock);
	rock.global_position = Vector3(1.5, 1, -1.5)
	var rock_timer: SceneTreeTimer = get_tree().create_timer(3)
	rock_timer.timeout.connect(func() -> void:
		rock.apply_central_force(Vector3(-10000, 0 , 10000))
	)

func get_player_spawn_position() -> Vector3:
	return Vector3(-1.5, 0, 1.5);
	
# No AI, we are tossing a ball
func get_ai_spawn_locations() -> Array:
	return []
	
func get_tutorial_text() -> String:
	return "Dodge the rock!  Use F to block in place or move"

func is_win_condition_met() -> bool:
	return time_to_stay_alive < Time.get_unix_time_from_system()
