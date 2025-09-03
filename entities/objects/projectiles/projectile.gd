class_name Projectile extends RigidBody3D

enum Type {
	ROCK,
	ICE_BOLT
}

var direction: Vector3 = Vector3.ZERO
var speed: float = 0;
var force: float = 0
var owner_peer_id: int = -1

func initialize_from_spawn_data(spawn_data: Dictionary) -> void:
	global_position = spawn_data["spawn_location"]
	direction = spawn_data["direction"]
	speed = spawn_data.get("speed", 0)
	force = spawn_data.get("force", 0)
	owner_peer_id = spawn_data["owner_peer_id"]
	look_at(global_position - direction)

	if(speed > 0):
		call_deferred("_apply_initial_velocity")
	elif force > 0:
		call_deferred("_apply_initial_force")
	else:
		push_error("Must provide a positive speed or force to projectile spawner")

func _apply_initial_velocity() -> void:
	linear_velocity = direction.normalized() * speed

func _apply_initial_force() -> void:
	apply_impulse(direction * force)

func get_scene_for_type(type: Type) -> String:
	match type:
		Type.ROCK:
			return "res://entities/objects/projectiles/rock/rock.tscn";
		Type.ICE_BOLT:
			return "";
		_:
			push_error("Cannot get scene for unmapped projectile type: " + str(type))
			return ""
