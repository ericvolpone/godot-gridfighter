class_name Fireball extends Projectile

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not is_multiplayer_authority(): return

	if body is CharacterBody3D:
		var player := body as Player
		if(player.is_blocking):
			# If they are blocking, remove
			queue_free()
		else:
			# TODO Apply Burn
			#player.apply_cold(COLD_DURATION)
			queue_free();
	else:
		queue_free()
