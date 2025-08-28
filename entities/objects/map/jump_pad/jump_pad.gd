class_name JumpPad extends Node3D

@export var jump_force: float = 8.0 
var jump_pad_velocity_modifier: Vector3 = Vector3(0, jump_force, 0)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.jump_pad_velocity += jump_pad_velocity_modifier


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		body.jump_pad_velocity -= jump_pad_velocity_modifier
