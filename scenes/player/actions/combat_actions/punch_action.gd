class_name PunchAction extends AbstractCombatAction

const BLOCK_ANIMATION: String = "rockguy_anim_lib/RockGuy_Block";

func _ready() -> void:
	# connect(get_player().mesh.punch_frame, _on_punch_frame);
	pass
	#TODO Get this wired up correctly

func get_cd_time() -> float:
	return 3.0;

func execute_child() -> void:
	# Spawn a rock
	var player: Player = get_player();
	var lobby: Node3D = get_lobby();

func is_usable_child() -> bool:
	return true;

func _on_punch_frame() -> void:
	print("Punch Frame")

func _on_punch_animation_finished(anim_name: String) -> void:
	if(BLOCK_ANIMATION == anim_name):
		get_player().is_blocking = false;
