extends Area2D
class_name CameraZoomTrigger

## Triggers camera zoom change when player enters the area
## Attach to an Area2D with a CollisionShape2D

@export var target_zoom: float = 0.7 ## Target zoom level (< 1.0 = zoom out, > 1.0 = zoom in)
@export var zoom_duration: float = 1.0 ## Duration of zoom transition in seconds
@export var reset_on_exit: bool = true ## Reset to original zoom when player exits

var original_zoom: float = 1.0
var camera: SimpleFollowCamera


func _ready() -> void:
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Find camera
	await get_tree().process_frame
	camera = get_viewport().get_camera_2d() as SimpleFollowCamera
	
	if camera:
		original_zoom = camera.zoom.x
	else:
		push_warning("CameraZoomTrigger: SimpleFollowCamera not found!")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and camera:
		camera.set_target_zoom(target_zoom, zoom_duration)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and camera and reset_on_exit:
		camera.set_target_zoom(original_zoom, zoom_duration)
