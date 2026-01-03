extends Label

## Real-time camera debug overlay
## Shows player, camera, and viewport info

var player: CharacterBody2D
var camera: Camera2D

func _ready() -> void:
	# Find player and camera
	player = get_tree().get_first_node_in_group("player")
	if player:
		camera = player.get_node_or_null("Camera2D")
	
	# Position in top-left corner
	position = Vector2(10, 10)
	add_theme_font_size_override("font_size", 16)

func _process(_delta: float) -> void:
	if not player or not camera:
		text = "❌ Player or Camera not found"
		return
	
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_zoom = camera.zoom
	var effective_viewport = viewport_size / camera_zoom
	
	# Calculate what Y range is visible
	var camera_center_y = camera.get_screen_center_position().y
	var visible_top = camera_center_y - (effective_viewport.y / 2.0)
	var visible_bottom = camera_center_y + (effective_viewport.y / 2.0)
	
	# Floor is at y=0, calculate its position on screen
	var floor_y_world = 0.0
	var floor_screen_percent = ((floor_y_world - visible_top) / effective_viewport.y) * 100.0
	
	text = """🎮 CAMERA DEBUG
━━━━━━━━━━━━━━━━━━━━━━━
📍 Player Position: (%.0f, %.0f)
🎥 Camera Center: (%.0f, %.0f)
🔍 Camera Zoom: %.2fx
📏 Viewport: %.0f × %.0f
📐 Effective Viewport: %.0f × %.0f

🌍 VISIBLE WORLD SPACE:
   Top: y = %.0f
   Bottom: y = %.0f
   
🟧 FLOOR (y=0):
   Screen Position: %.1f%% from top
   %s
━━━━━━━━━━━━━━━━━━━━━━━
Target: Floor at 66%% (lower third)
""" % [
		player.global_position.x, player.global_position.y,
		camera.get_screen_center_position().x, camera.get_screen_center_position().y,
		camera_zoom.x,
		viewport_size.x, viewport_size.y,
		effective_viewport.x, effective_viewport.y,
		visible_top,
		visible_bottom,
		floor_screen_percent,
		"✅ CORRECT" if floor_screen_percent > 60 and floor_screen_percent < 75 else "❌ WRONG"
	]
