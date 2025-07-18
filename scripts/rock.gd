extends Node3D

@onready var rigid_body: RigidBody3D = $RigidBody3D;

func _physics_process(delta: float) -> void:
	if(rigid_body.global_position.y < -5.0):
		print("Fell off map, deleting rock");
		queue_free();
