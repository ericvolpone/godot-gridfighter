class_name Projectile extends RigidBody3D

enum Type {
	ROCK,
	ICE_BOLT,
	FIREBALL
}

const PROJECTILE_TTL: float = 5;

var spawn_data: Dictionary

var direction: Vector3 = Vector3.ZERO
var speed: float = 0;
var force: float = 0
var owner_peer_id: int = -1
var alive_time: float = 0;


func _ready() -> void:
	_initialize_from_spawn_data()
	NetworkTime.on_tick.connect(_tick);

func _tick(delta: float, tick: int) -> void:
	if is_queued_for_deletion(): return
	alive_time += delta
	if is_multiplayer_authority() and alive_time >= PROJECTILE_TTL:
		queue_free();

func _initialize_from_spawn_data() -> void:
	global_position = spawn_data["spawn_location"]
	direction = spawn_data["direction"]
	speed = spawn_data.get("speed", 0)
	force = spawn_data.get("force", 0)
	owner_peer_id = spawn_data["owner_peer_id"]
	look_at(global_position - direction)

	if(speed > 0):
		_apply_initial_velocity()
	elif force > 0:
		_apply_initial_force()
	else:
		push_error("Must provide a positive speed or force to projectile spawner")

func _apply_initial_velocity() -> void:
	linear_velocity = direction.normalized() * speed

func _apply_initial_force() -> void:
	apply_impulse(direction * force)
