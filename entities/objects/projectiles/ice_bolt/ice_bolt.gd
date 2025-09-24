class_name IceBolt extends Projectile

const ORBIT_SPEED_DEG = 120
@onready var snow_container: MultiMeshInstance3D = $SnowContainer

func _process(delta: float) -> void:
	snow_container.rotate_z(deg_to_rad(ORBIT_SPEED_DEG * delta))
