class_name AbstractMultiplayerLevel extends AbstractLevel

enum MPMatchType {
	KING_OF_THE_HILL, 
	DEATH_MATCH, 
	ELIMINATION,
	UNDEFINED
}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready();
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_match_type() -> MPMatchType:
	push_error("You must define a MP Match Type")
	return MPMatchType.UNDEFINED;
