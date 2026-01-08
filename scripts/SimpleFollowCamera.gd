extends Camera2D
class_name SimpleFollowCamera

## Simple camera that follows the player with smooth movement
## No PhantomCamera needed - just works!

@export var follow_speed: float = 5.0
@export var camera_offset: Vector2 = Vector2(0, -600) # Look upward to show more sky
@export var zoom_speed: float = 3.0 ## Speed of zoom transitions

var player: Node2D
var target_zoom: float = 1.0
var zoom_tween: Tween


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
	
	# Initialize zoom
	target_zoom = zoom.x


func _process(delta: float) -> void:
	if not player:
		return
	
	# Smoothly follow player
	var target_pos = player.global_position + camera_offset
	global_position = global_position.lerp(target_pos, follow_speed * delta)


## Set target zoom level with smooth transition
func set_target_zoom(new_zoom: float, duration: float = 1.0) -> void:
	target_zoom = new_zoom
	
	# Kill existing tween
	if zoom_tween:
		zoom_tween.kill()
	
	# Create new tween
	zoom_tween = create_tween()
	zoom_tween.set_ease(Tween.EASE_IN_OUT)
	zoom_tween.set_trans(Tween.TRANS_CUBIC)
	zoom_tween.tween_property(self, "zoom", Vector2(new_zoom, new_zoom), duration)
