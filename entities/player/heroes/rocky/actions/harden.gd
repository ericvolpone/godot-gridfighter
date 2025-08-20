class_name Harden extends AOE

@onready var rocks_container: MultiMeshInstance3D = $RocksContainer

const ORBIT_SPEED_DEG = 60

func _init() -> void:
	is_tracking = true;

func _process(delta: float) -> void:
	rocks_container.rotate_y(deg_to_rad(ORBIT_SPEED_DEG * delta))

func get_area_3d() -> Area3D:
	return null;
