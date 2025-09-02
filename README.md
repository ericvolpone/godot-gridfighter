# Project Description
This project is a Godot game for a 3d hero fighter.

# How Tos
This section will describe, mostly for the author of the github repository, steps to take to complete specific actions

## How to create a level
1. Build a 7/7 Grid vertically
2. Build the UV Mesh for the grid
3. Apply materials you're interested in
4. Build any orthogonal items specific for the map in this grid
5. Import as a GLB into Godot
6. Inherit the level.tscn and add your GLB, rotate accordingly as adjust camera accordingly.
7. Add any additional objects you've modeled into the scene, you can hold CTRL-W to snap to a mesh.

## Hot to create a new player
1. We have, in our repository, a rigged hero that just needs new materials applied to the color component.
2. Adjust materials, export as GLB and pull into Godot
3. Add the mixamo bone map, this should work out of the box based on our rig
4. Create an inherited scene and add the Animation player
