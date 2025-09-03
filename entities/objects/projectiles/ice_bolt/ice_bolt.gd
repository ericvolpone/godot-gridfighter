class_name IceBolt extends Projectile

@onready var mesh: MeshInstance3D = $MeshInstance3D

var is_slow_disappearing: bool = true;


func _ready() -> void:
	add_to_group(Groups.PUNCHABLE_RB)
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
			# TODO Apply Freeze
			pass
	else:
		# TODO Maybe shatter animation
		queue_free()
