extends Node3D

@onready var explosion_particles: GPUParticles3D = $GPUParticles3D

func _on_gpu_particles_3d_finished() -> void:
	print("Completed")
	queue_free()
