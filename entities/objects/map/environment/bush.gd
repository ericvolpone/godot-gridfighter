class_name Bush extends AOE

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

const GROW_SPEED = 1;

var is_growing: bool = false;

func _init() -> void:
	is_tracking = false;

func get_area_3d() -> Area3D:
	return null;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if is_growing:
		scale =  Vector3(.05, .05, .05);

func _process(delta: float) -> void:
	if is_growing:
		var scale_increase: Vector3 = Vector3(delta*GROW_SPEED, delta*GROW_SPEED, delta*GROW_SPEED)
		var next_scale: Vector3 = scale + scale_increase
		if next_scale > Vector3(1, 1, 1):
			scale = Vector3(1, 1, 1)
			is_growing = false
		else:
			scale = next_scale
