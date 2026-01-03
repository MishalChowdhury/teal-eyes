extends Node2D

## Level01 - First act's first level
## Manages initialization for PhantomCamera system

@onready var camera: Camera2D = $Player/Camera2D
@onready var phantom_host: Node = $Player/Camera2D/PhantomCameraHost

func _ready() -> void:
	# PhantomCameraHost now correctly detects Camera2D as parent
	# _is_2d flag will be set to true automatically
	if camera:
		camera.enabled = true
	
	# The first room (Room01_Epic) starts with priority 10
	# This is set in RoomTemplate_Far.tscn
