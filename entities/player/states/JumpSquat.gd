extends BaseState

## Jump Squat State
## Brief anticipation crouch before jumping — GRIS-style wind-up
## Body compresses into a C-curve, then explodes upward into Jump

const SQUAT_DURATION := 0.2  # seconds of anticipation

var _timer := 0.0


func enter() -> void:
	_timer = 0.0


func update(delta: float) -> String:
	if not movement:
		return ""

	# Keep applying ground movement so sideways "long jump" works
	movement.apply_movement(delta, false)

	_timer += delta

	# If we left the ground somehow (walked off edge), skip to fall
	if not movement.is_grounded():
		return "Fall"

	# Squat complete → launch into jump
	if _timer >= SQUAT_DURATION:
		movement.apply_jump()
		return "Jump"

	return ""  # Stay in JumpSquat
