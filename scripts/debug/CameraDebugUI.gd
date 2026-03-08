extends Label
class_name CameraDebugUI

## Dynamic debug UI showing camera zoom, visible area, and character height
## Updates in real-time as camera zooms during room transitions

const BASE_WINDOW_WIDTH: float = 1920.0
const BASE_WINDOW_HEIGHT: float = 1080.0
const BASE_CHARACTER_HEIGHT: float = 288.0  # 720px * 0.4 scale

var _player: CharacterBody2D
var _active_camera: Camera2D
var _last_zoom: Vector2 = Vector2.ONE

func _ready() -> void:
	# Position in top-left corner, below FPS counter
	position = Vector2(10, 40)
	add_theme_font_size_override("font_size", 14)
	
	# Find player
	await get_tree().process_frame
	_player = get_tree().get_first_node_in_group("player")
	
	if not _player:
		push_warning("[CameraDebugUI] Player not found!")
		return
	
	# Find the Camera2D attached to player
	_active_camera = _find_player_camera()
	
	if not _active_camera:
		push_warning("[CameraDebugUI] Camera2D not found!")

func _process(_delta: float) -> void:
	if not _active_camera:
		text = "Camera: None"
		return
	
	# Get current zoom from active camera
	var current_zoom: Vector2 = _active_camera.zoom
	
	# Update display
	_update_debug_text(current_zoom)
	
	_last_zoom = current_zoom

func _find_player_camera() -> Camera2D:
	"""Find the Camera2D node attached to the player"""
	if not _player:
		return null
	
	# Look for Camera2D in player's children
	for child in _player.get_children():
		if child is Camera2D:
			return child
	
	# Fallback: search in viewport
	var viewport = get_viewport()
	if viewport:
		return viewport.get_camera_2d()
	
	return null

func _update_debug_text(zoom: Vector2) -> void:
	"""Update the debug display with current camera metrics"""
	var visible_width: float = BASE_WINDOW_WIDTH / zoom.x
	var visible_height: float = BASE_WINDOW_HEIGHT / zoom.y
	var char_height: float = BASE_CHARACTER_HEIGHT * zoom.x
	var screen_percent: float = (char_height / BASE_WINDOW_HEIGHT) * 100.0
	
	# Determine room type based on zoom level
	var room_type: String = _get_room_type(zoom.x)
	
	# Format display
	text = "CAMERA DEBUG\n"
	text += "Room Type: %s\n" % room_type
	text += "Zoom: %.2fx\n" % zoom.x
	text += "Visible: %.0f × %.0f px\n" % [visible_width, visible_height]
	text += "Character: %.0f px (%.1f%%)" % [char_height, screen_percent]
	
	# Color code by zoom level
	if zoom.x <= 0.35:
		modulate = Color(0.7, 0.7, 1.0)  # Blue for Far
	elif zoom.x <= 0.9:
		modulate = Color(0.7, 1.0, 0.7)  # Green for Mid
	elif zoom.x <= 1.3:
		modulate = Color(1.0, 1.0, 0.7)  # Yellow for Close
	else:
		modulate = Color(1.0, 0.7, 0.7)  # Red for Intimate

func _get_room_type(zoom_level: float) -> String:
	"""Determine room type based on zoom level"""
	if zoom_level <= 0.35:
		return "Far"
	elif zoom_level <= 0.9:
		return "Mid"
	elif zoom_level <= 1.3:
		return "Close"
	else:
		return "Intimate"

