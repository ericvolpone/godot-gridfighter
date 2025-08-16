class_name JumpPad extends Node3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var area_3d: Area3D = $Area3D

@export var jump_force: int = 10.0 # Adjust this value to control jump height

func _ready() -> void:
	
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.velocity.y = jump_force
