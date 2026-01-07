extends CPUParticles2D

## Dash Visual Effect
## Creates a speed blur/afterimage trail during dash

func _ready() -> void:
	# Configure particle system for speed blur effect
	emitting = false
	amount = 8
	lifetime = 0.3
	one_shot = false
	explosiveness = 0.0
	randomness = 0.2
	
	# Emission shape - emit from player position
	emission_shape = EMISSION_SHAPE_POINT
	
	# Movement - particles stay in place (afterimage effect)
	direction = Vector2.ZERO
	spread = 0.0
	gravity = Vector2.ZERO
	initial_velocity_min = 0.0
	initial_velocity_max = 0.0
	
	# Visual properties
	scale_amount_min = 0.8
	scale_amount_max = 1.0
	
	# Fade out over lifetime
	color = Color(1, 1, 1, 0.6)  # White with transparency
	color_ramp = _create_fade_gradient()
	
	# Size
	emission_rect_extents = Vector2(20, 40)


func _create_fade_gradient() -> Gradient:
	"""Create gradient that fades particles out"""
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 0.6))
	gradient.set_color(1, Color(1, 1, 1, 0.0))
	return gradient


func start_dash_effect() -> void:
	"""Start emitting dash particles"""
	emitting = true


func stop_dash_effect() -> void:
	"""Stop emitting dash particles"""
	emitting = false
