class_name AbstractLevel extends Node3D

func _ready() -> void:
	pass;

func handle_player_death(player: Player) -> void:
	push_error("Please implement respawn player in child")
	pass;
