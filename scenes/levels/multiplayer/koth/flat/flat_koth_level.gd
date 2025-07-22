extends AbstractKothLevel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_hill_ring_locations() -> Array:
	return [
		Vector3(0,0,0),
		Vector3(2,0,-2),
		Vector3(2,0,2),
		Vector3(4,0,4),
		Vector3(-4,0,3),
		Vector3(-1,0,-2)
		];

func get_player_spawn_positions() -> Array:
	return [Vector3(0,0,0)];
