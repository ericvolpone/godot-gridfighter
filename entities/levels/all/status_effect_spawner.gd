class_name StatusEffectSpawner extends MultiplayerSpawner

#region Var:Effects
var shocked_effect_scene: PackedScene = preload("res://entities/effects/statuses/shocked_effect.tscn")
var frozen_effect_scene: PackedScene = preload("res://entities/effects/statuses/frozen_effect.tscn")
var cold_effect_scene: PackedScene = preload("res://entities/effects/statuses/cold_effect.tscn")
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_configure_status_effect_spawner")

func _configure_status_effect_spawner() -> void:
	spawn_function = func(spawn_data: Dictionary) -> StatusEffect:
		var effect_type: StatusEffect.Type = spawn_data["effect_type"]
		var effect: StatusEffect;
		match effect_type:
			StatusEffect.Type.SHOCKED:
				effect = shocked_effect_scene.instantiate()
			StatusEffect.Type.FROZEN:
				effect = frozen_effect_scene.instantiate()
			StatusEffect.Type.COLD:
				effect = cold_effect_scene.instantiate()
			
			_:
				effect = null
		
		if effect:
			effect.call_deferred("_initialize_from_spawn_data", spawn_data)
		
		return effect

@rpc("any_peer", "call_local", "reliable")
func spawn_effect(spawn_data: Dictionary) -> StatusEffect:
	if not multiplayer.is_server():
		return null

	return spawn(spawn_data)
