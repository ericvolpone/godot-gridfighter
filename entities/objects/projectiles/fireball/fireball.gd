class_name Fireball extends Projectile

func _ready() -> void:
	super._ready();
	contact_monitor = true
	max_contacts_reported = 4

func _apply_collision(body: Node3D) -> void:
	if body is Player:
		var player: Player = body as Player
		if(player.is_blocking):
			# If they are blocking, remove
			clear_self()
		else:
			# TODO Constant?
			player.burn_value += 5
			clear_self()
	else:
		clear_self()
