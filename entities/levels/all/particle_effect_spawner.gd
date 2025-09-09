class_name ParticleEffectSpawner extends MultiplayerSpawner

#region Var:Effects
var punch_effect_scene: PackedScene = preload("res://entities/effects/punch_effect.tscn")
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_configure_particle_effect_spawner")

func _configure_particle_effect_spawner() -> void:
	spawn_function = func(spawn_data: Dictionary) -> ParticleEffect:
		var effect_type: ParticleEffect.Type = spawn_data["effect_type"]
		var effect: ParticleEffect;
		match effect_type:
			ParticleEffect.Type.PUNCH:
				effect = punch_effect_scene.instantiate()
			_:
				effect = null
		
		if effect:
			effect.spawn_data = spawn_data;
		
		return effect

@rpc("any_peer", "call_local", "reliable")
func spawn_effect(spawn_data: Dictionary) -> ParticleEffect:
	if not multiplayer.is_server():
		return null

	return spawn(spawn_data)
