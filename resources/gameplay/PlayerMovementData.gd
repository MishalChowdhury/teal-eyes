extends Resource
class_name PlayerMovementData

## Movement Parameters Resource
## All configurable values for player movement feel

# Ground Movement
@export var speed: float = 300.0  ## Maximum horizontal speed (pixels/sec)
@export var acceleration: float = 1500.0  ## Ground acceleration rate
@export var friction: float = 1500.0  ## Ground deceleration rate

# Jumping
@export var jump_velocity: float = -600.0  ## Jump force (negative is up)
@export var gravity_scale: float = 1.0  ## Gravity multiplier

# Air Control
@export var air_acceleration: float = 800.0  ## Acceleration while airborne

# Game Feel Timers
@export var coyote_time: float = 0.1  ## Grace period after leaving ledge (seconds)
@export var jump_buffer_time: float = 0.1  ## Input buffering window (seconds)

# Wall Movement
@export var wall_slide_friction: float = 0.8  ## Velocity multiplier when sliding
@export var wall_slide_max_speed: float = 100.0  ## Maximum descent speed (pixels/sec)
@export var wall_jump_push_back: float = 400.0  ## Horizontal force away from wall
