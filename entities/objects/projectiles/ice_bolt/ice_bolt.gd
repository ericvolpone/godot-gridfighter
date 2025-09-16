class_name IceBolt extends Projectile

const ORBIT_SPEED_DEG = 120
const COLD_DURATION = 5.0;
@onready var snow_container: MultiMeshInstance3D = $SnowContainer

func _ready() -> void:
	super._ready();
	contact_monitor = true
	max_contacts_reported = 4

func _process(delta: float) -> void:
	snow_container.rotate_z(deg_to_rad(ORBIT_SPEED_DEG * delta))

func _apply_collision(body: Node3D) -> void:
	if body is Player:
		var player: Player = body as Player
		if(player.is_blocking):
			# If they are blocking, remove
			clear_self()
		else:
			player.apply_cold(COLD_DURATION)
			clear_self()
	else:
		# TODO Maybe shatter animation
		clear_self()
