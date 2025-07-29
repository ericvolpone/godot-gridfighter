extends AbstractKothLevel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_player_spawn_positions() -> Array:
	return [Vector3(0,3,0)];
