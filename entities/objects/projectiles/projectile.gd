class_name Projectile extends RigidBody3D

enum Type {
	ROCK,
	ICE_BOLT,
	FIREBALL
}

var spawn_data: Dictionary

var direction: Vector3 = Vector3.ZERO
var speed: float = 0;
var force: float = 0
var owner_peer_id: int = -1
var projectile_ttl: float = 5 #Default, overridable via spawn data
var alive_time: float = 0;


func _ready() -> void:
	_initialize_from_spawn_data()
	NetworkTime.on_tick.connect(_tick);
	NetworkRollback.on_process_tick.connect(_rollback_tick)

func _tick(delta: float, _tick_id: int) -> void:
	if is_queued_for_deletion(): return
	alive_time += delta

	if alive_time >= projectile_ttl:
		clear_self()

func _rollback_tick(_tick_id: int) -> void:
	for body: Node3D in get_colliding_bodies():
		print(multiplayer.get_unique_id(), " - Applying FB Collision on tick: ", str(_tick_id))
		_apply_collision(body)

func _initialize_from_spawn_data() -> void:
	global_position = spawn_data["spawn_location"]
	direction = spawn_data["direction"]
	speed = spawn_data.get("speed", 0)
	force = spawn_data.get("force", 0)
	owner_peer_id = spawn_data["owner_peer_id"]
	if spawn_data.has("projectile_ttl"):
		projectile_ttl = spawn_data["projectile_ttl"]
	look_at(global_position - direction)

	if(speed > 0):
		_apply_initial_velocity()
	elif force > 0:
		_apply_initial_force()
	else:
		push_error("Must provide a positive speed or force to projectile spawner")

func clear_self() -> void:
	NetworkTime.on_tick.disconnect(_tick)
	NetworkRollback.on_process_tick.disconnect(_rollback_tick)
	queue_free();

func _apply_initial_velocity() -> void:
	linear_velocity = direction.normalized() * speed

func _apply_initial_force() -> void:
	apply_impulse(direction * force)

# Fix this collision stuff to be less work for each child
func _apply_collision(_body: Node3D) -> void:
	push_error("Must implement _apply_collision for projectile")
