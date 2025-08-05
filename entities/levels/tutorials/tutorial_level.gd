class_name TutorialLevel extends Level

const SCENE_PREFIX: String = "res://entities/levels/tutorials/tutorial_level_"
const SCENE_POSTFIX: String = ".tscn"

var hud_scene: PackedScene = preload("res://entities/levels/tutorials/tutorial_level_hud.tscn")

var hud: TutorialHud;

var has_won: bool = false;

var current_ai_spawn_index: int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready();

	hud = hud_scene.instantiate()
	add_child(hud)
	hud.message_label.text = "Tutorial Criteria: " + get_tutorial_text()

	call_deferred("_spawn_ai_tutorial")

func _spawn_ai_tutorial() -> void:
	var index: int = 1;
	for ai_location: Vector3 in get_ai_spawn_locations():
		var ai: Player = mp_spawner.spawn(multiplayer.get_unique_id() + index)
		index += 1
		ai.add_brain(ZeroBrain.new())
		ai_chars[ai] = ai;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if(!has_won and is_win_condition_met()):
		has_won = true;
		get_tree().change_scene_to_packed(load(SCENE_PREFIX + str(get_next_level_number()) + SCENE_POSTFIX))

func handle_player_death(player: Player) -> void:
	if(player.is_player_controlled):
		player.global_position = get_player_spawn_positions()[0]
	else:
		ai_chars.erase(player)
		player.queue_free()

# TODO Bro just put these guys in the scene themselves lol
func get_ai_spawn_locations() -> Array[Vector3]:
	push_error("get_ai_spawn_locations not implemented")
	return [];

func get_tutorial_text() -> String:
	push_error("Not Implemented")
	return "Abstract Class Tutorial Text"

func respawn_player(player: Player) -> void:
	if player.is_player_controlled:
		player.global_position = get_player_spawn_positions()[0]
	else:
		player.global_position = get_ai_spawn_locations()[current_ai_spawn_index]
		current_ai_spawn_index += 1

func is_win_condition_met() -> bool:
	push_error("Not Implemented")
	return are_all_ais_gone()

func are_all_ais_gone() -> bool:
	return ai_chars.size() == 0

func get_level_number() -> int:
	push_error("Please define level number in child")
	return 1;
func get_next_level_number() -> int:
	push_error("Please define next level number in child")
	return 2

func add_player_to_score(player: Player) -> void:
	pass;
