extends Label

## Simple FPS counter that displays current framerate

func _process(_delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	text = "FPS: %d" % fps
	
	# Color code based on performance
	if fps >= 60:
		modulate = Color.GREEN
	elif fps >= 30:
		modulate = Color.YELLOW
	else:
		modulate = Color.RED
