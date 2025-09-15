class_name StatusEffectSpawner extends Node

#region Var:Effects
var shocked_effect_scene: PackedScene = preload("res://entities/effects/statuses/shocked_effect.tscn")
var frozen_effect_scene: PackedScene = preload("res://entities/effects/statuses/frozen_effect.tscn")
var cold_effect_scene: PackedScene = preload("res://entities/effects/statuses/cold_effect.tscn")
var burnt_effect_scene: PackedScene = preload("res://entities/effects/statuses/burnt_effect.tscn")
var rooted_effect_scene: PackedScene = preload("res://entities/effects/statuses/rooted_effect.tscn")
#endregion

func spawn(spawn_data: Dictionary) -> StatusEffect:
	var effect_type: StatusEffect.Type = spawn_data["effect_type"]
	var effect: StatusEffect;
	match effect_type:
		StatusEffect.Type.SHOCKED:
			effect = shocked_effect_scene.instantiate()
		StatusEffect.Type.FROZEN:
			effect = frozen_effect_scene.instantiate()
		StatusEffect.Type.COLD:
			effect = cold_effect_scene.instantiate()
		StatusEffect.Type.BURNT:
			effect = burnt_effect_scene.instantiate()
		StatusEffect.Type.ROOTED:
			effect = rooted_effect_scene.instantiate()
		_:
			effect = null
	
	if effect:
		effect.spawn_data = spawn_data;
		var owner_player_id: String = spawn_data["owner_player_id"]
		var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYER)

		for player: Player in players:
			if player.player_id == owner_player_id:
				effect.tracking_player = player
				player.status_effects[effect] = true
				break
		effect.tracking_player.add_child(effect)
	
	return effect
