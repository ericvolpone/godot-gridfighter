Steps to create a new Hero
	
	1. Create mesh in Blender
	2. Upload mesh to Mixamo
	3. Download T-Pose in Mixamo
		This Rigs our character
	4. Import FBX from Mixamo to Blender
	5. Update bone weight if you want rigid bodies
		This can be done by going to that mesh and applying weights appropriate by vertex
	
	6. Import GLB into Godot
	7. In the GLB, make sure we are setting Root Type to Hero and name to Hero Name
	8. In the skeleton, choose the Mixamo BoneMap as bonemap and make sure bones are correct
	9. Inherit player.tscn and drag your GLB in
		Make sure to update the animations library to a unique master anims
	10. Punch frame currently needs to be set, this is a call method signal in the players emit_punch_frame
	11. Character should just load!

Steps to add Animation:
	1. Go to Mixamo
	2. Click Y-Bot
	3. Find your animation, download it to FBX
	4. Open up YBotPacked
	5. Import into a new collection the FBX
	6. Go to the Animation tab, create the new animation on YBot and name it and push to NLA Strip
	7. Export to GLB
	8. Import it into your file browser (can delete after I think), set master bone map and load it into a temp scene
	9. Manage the animations on it, and load our master anim lib and copy it into that.
	10. Save the master lib
	11. Depending on the animation or bone map, you may have to go into the animation and delete some problem bones
