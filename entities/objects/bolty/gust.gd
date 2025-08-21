class_name Gust extends AOE

@onready var gust_area: Area3D = $Container/GustArea
const GUST_FORCE: float = 100;
var gust_direction: Vector3 = Vector3.ZERO

func _init() -> void:
	is_tracking = false;

func get_area_3d() -> Area3D:
	return gust_area

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return

	var bodies: Array[Node3D] = gust_area.get_overlapping_bodies()
	for body: Node3D in bodies:
		if body is Player:
			var player: Player = body as Player

			print("Trying to push player: " + player.player_name)
			print("Gust Direction: " + str(gust_direction))

			var snapshot_velocity: Vector3 = player.velocity
			player.velocity = Vector3(
				gust_direction.x * delta * GUST_FORCE,
				gust_direction.y * delta * GUST_FORCE,
				gust_direction.z * delta * GUST_FORCE
			)
			player.move_and_slide_physics_factor()
			player.velocity = snapshot_velocity
