extends Node2D

## Debug script to visualize skeleton bone positions
## Attach to PlayerRig to see where bones actually are

@onready var skeleton: Skeleton2D = $Visuals/Skeleton

func _draw() -> void:
	if not skeleton:
		return
	
	# Draw debug shapes at each bone position
	var bones = [
		skeleton.get_node_or_null("Bone_Hip"),
		skeleton.get_node_or_null("Bone_Hip/Bone_Torso"),
		skeleton.get_node_or_null("Bone_Hip/Bone_Torso/Bone_Head"),
		skeleton.get_node_or_null("Bone_Hip/Bone_Torso/Bone_Shoulder_R"),
		skeleton.get_node_or_null("Bone_Hip/Bone_Thigh_R"),
		skeleton.get_node_or_null("Bone_Hip/Bone_Thigh_L"),
	]
	
	for bone in bones:
		if bone:
			# Draw cross at bone position
			var pos = bone.global_position - global_position
			draw_line(pos + Vector2(-20, 0), pos + Vector2(20, 0), Color.RED, 2.0)
			draw_line(pos + Vector2(0, -20), pos + Vector2(0, 20), Color.RED, 2.0)
			# Draw circle
			draw_circle(pos, 5, Color.YELLOW)

func _process(_delta: float) -> void:
	queue_redraw()  # Redraw every frame
