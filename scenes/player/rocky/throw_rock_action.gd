class_name ThrowRockAction extends AbstractCombatAction

const rock_scene: PackedScene = preload("res://scenes/objects/combat/rock.tscn");

func get_cd_time() -> float:
	return 3.0;

func execute_child() -> void:
	# Spawn a rock
	var rock: RigidBody3D = rock_scene.instantiate();
	var player: Player = get_player();
	var lobby: Node3D = get_lobby();
	
	lobby.add_child(rock);
	rock.global_position = global_position + (player.mesh.get_global_transform().basis.z.normalized());
	rock.global_position.y += 1;
	rock.apply_impulse(player.mesh.get_global_transform().basis.z * 50)

func is_usable_child() -> bool:
	return true;
