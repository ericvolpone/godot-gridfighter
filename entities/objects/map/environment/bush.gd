class_name Bush extends AOE

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

const GROW_SPEED = 1;

var is_growing: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_growing:
		print("Ready: ", str(is_growing))
		scale.y =  .05;

func _process(delta: float) -> void:
	if is_growing:
		var next_y: float = scale.y + (delta*GROW_SPEED)
		scale.y = clampf(next_y, 0, 1);
		if scale.y == 1:
			is_growing = false;
