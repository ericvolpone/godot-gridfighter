class_name JumpPad extends Node3D

@export var jump_force: float = 10.0 

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.velocity.y = jump_force
