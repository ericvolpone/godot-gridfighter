class_name AbstractLevel extends Node3D

# Packed Scenes
var player_scene: PackedScene = preload("res://scenes/player/player.tscn")

func _ready() -> void:
	set_process(true);

func _process(delta: float) -> void:
	pass;

func handle_player_death(player: Player) -> void:
	push_error("Please implement respawn player in child")
	pass;

func init_player(id: int, name: String, is_player_controlled: bool = false) -> Player:
	var player: Player = player_scene.instantiate();
	player.player_id = id;
	player.player_name = name
	player.is_player_controlled = is_player_controlled
	return player;
