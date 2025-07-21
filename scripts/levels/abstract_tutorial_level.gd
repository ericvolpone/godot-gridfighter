extends Node3D

class_name AbstractTutorialLevel

const SCENE_PREFIX: String = "res://scenes/levels/tutorial_level_"
const SCENE_POSTFIX: String = ".tscn"

var player_scene: PackedScene = preload("res://scenes/player.tscn")
var hud_scene: PackedScene = preload("res://scenes/levels/tutorial_level_hud.tscn")

var hud: TutorialHud;

var player: Player; 
var ai_chars: Array;
var has_won: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = player_scene.instantiate();
	player.is_player_controlled = true;
	add_child(player);
	player.global_position = get_player_spawn_position();
	
	for ai_location: Vector3 in get_ai_spawn_locations():
		var ai: Player = player_scene.instantiate();
		ai_chars.append(ai);
		ai.is_player_controlled = false;
		add_child(ai);
		ai.global_position = ai_location;
	
	hud = hud_scene.instantiate()
	add_child(hud)
	hud.message_label.text = "Tutorial Criteria: " + get_tutorial_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(player.global_position.y <= -5):
		player.global_position = get_player_spawn_position()

	if(!has_won and is_win_condition_met()):
		has_won = true;
		print("You beat level " + str(get_level_number()));
		get_tree().change_scene_to_packed(load(SCENE_PREFIX + str(get_next_level_number()) + SCENE_POSTFIX))

# Generic Methods, override in levels
func get_player_spawn_position() -> Vector3:
	push_error("get_player_spawn_position Not Implemented")
	return Vector3(0,0,0);
func get_ai_spawn_locations() -> Array:
	push_error("Not Implemented")
	return [Vector3(1,0,1)]
	
func get_tutorial_text() -> String:
	push_error("Not Implemented")
	return "Abstract Class Tutorial Text"

func is_win_condition_met() -> bool:
	push_error("Not Implemented")
	return are_all_ais_gone()

func are_all_ais_gone() -> bool:
	for ai: Player in ai_chars:
		if(ai.global_position.y >= -5):
			return false;
	return true

func get_level_number() -> int:
	push_error("Please define level number in child")
	return 1;
func get_next_level_number() -> int:
	push_error("Please define next level number in child")
	return 2
