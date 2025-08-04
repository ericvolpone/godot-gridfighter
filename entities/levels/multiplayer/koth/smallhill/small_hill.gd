class_name SmallHill extends KothLevel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func get_player_spawn_positions() -> Array:
	return [
		Vector3(0,3,0),
		Vector3(1,3,1),
		Vector3(-1,3,-1)
	];
