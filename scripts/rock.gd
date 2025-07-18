extends RigidBody3D

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		var player := body as CharacterBody3D
		var impact_force: float = linear_velocity.length()
		if impact_force > 1:
			var direction: Vector3 = (player.global_transform.origin - global_transform.origin).normalized()
			player.knock_back(direction, impact_force, 1.0)

func _physics_process(delta: float) -> void:
	if(global_position.y < -5.0):
		print("Fell off map, deleting rock");
		queue_free();
