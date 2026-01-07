extends Camera2D
class_name SimpleFollowCamera

## Simple camera that follows the player with smooth movement
## No PhantomCamera needed - just works!

@export var follow_speed: float = 5.0
@export var camera_offset: Vector2 = Vector2(0, -600)  # Look upward to show more sky

var player: Node2D

func _ready() -> void:
	# Find player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		print("✅ SimpleFollowCamera: Found player, camera will follow")
		# Position camera at player immediately
		global_position = player.global_position + camera_offset
	else:
		push_warning("⚠️ SimpleFollowCamera: Player not found!")

func _process(delta: float) -> void:
	if not player:
		return
	
	# Smoothly follow player
	var target_pos = player.global_position + camera_offset
	global_position = global_position.lerp(target_pos, follow_speed * delta)
