class_name AbstractCombatAction extends Node3D

const DEFAULT_CD: float = 5.0;
const GLOBAL_CD: float = 0.5;

var cd_available_time: float = Time.get_unix_time_from_system()

@onready var player: Player = get_parent();

func is_usable() -> bool:
	var time: float = Time.get_unix_time_from_system();
	
	return 	player.has_control() and \
		time >= cd_available_time and \
		time >= player.global_combat_cooldown_next_use and \
		is_usable_child();

# Called when the node enters the scene tree for the first time.
func execute() -> void:
	if !is_usable():
		pass
	
	var execution_time: float = Time.get_unix_time_from_system();
	cd_available_time = execution_time + get_cd_time();
	player.global_combat_cooldown_next_use = execution_time + GLOBAL_CD;
	execute_child();

func get_lobby() -> Node3D:
	return player.get_parent_node_3d();

# Interface Methods
func get_cd_time() -> float:
	return DEFAULT_CD

func execute_child() -> void:
	push_error("Implement Interface execute_child");
	pass

func is_usable_child() -> bool:
	return true;

func handle_animation_signal() -> void:
	pass
