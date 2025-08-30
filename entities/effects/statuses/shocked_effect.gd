class_name ShockedEffect extends StatusEffect

@onready var particles: GPUParticles3D = $ShockEffects

func _ready() -> void:
	particles.emitting = true
	print("Created Shocked Effect")

func _on_gpu_particles_3d_finished() -> void:
	print("Effect Over")
	queue_free()
