class_name IceBolt extends Projectile

const ORBIT_SPEED_DEG = 120
const COLD_DURATION = 5.0;
@onready var snow_container: MultiMeshInstance3D = $SnowContainer

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	self.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	snow_container.rotate_z(deg_to_rad(ORBIT_SPEED_DEG * delta))

func _on_body_entered(body: Node) -> void:
	if not is_multiplayer_authority(): return

	if body is CharacterBody3D:
		var player := body as Player
		if(player.is_blocking):
			# If they are blocking, remove
			queue_free()
		else:
			player.apply_cold(COLD_DURATION)
			queue_free();
	else:
		# TODO Maybe shatter animation
		queue_free()
