Steps to create a character:
	
	1. Create mesh in Blender
	2. Upload mesh to Mixamo
	3. Download T-Pose in Mixamo
		This Rigs our character
	4. Import FBX from Mixamo to Blender
	5. Update bone weight if you want rigid bodies
		This can be done by going to that mesh and applying weights appropriate by vertex
	
	6. Import GLB into Godot
	7. In the GLB, make sure we are setting Root Type to Node3D and name to Model
	8. In the skeleton, choose the Mixamo BoneMap as bonemap and make sure bones are correct
	9. Inherit player.tscn and drag your GLB in
		Make sure to update the animations library to a unique master anims
	10. Punch frame currently needs to be set, this is a call method signal in the players emit_punch_frame
	11. Character should just load!
