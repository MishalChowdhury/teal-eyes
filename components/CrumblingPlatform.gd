extends StaticBody2D
class_name CrumblingPlatform

## Platform that crumbles and falls shortly after the player stands on it.
## Respawns after respawn_time seconds.

@export var shake_duration: float = 0.4 ## Seconds of warning shake before falling
@export var fall_speed: float = 600.0 ## Pixels per second while falling
@export var respawn_time: float = 3.0 ## Seconds before platform reappears

var _origin: Vector2
var _state: int = 0 # 0=idle, 1=shaking, 2=falling, 3=respawning
var _timer: float = 0.0
var _shake_timer: float = 0.0
var _collision: CollisionShape2D


func _ready() -> void:
	_origin = position
	_collision = get_node_or_null("CollisionShape2D") as CollisionShape2D
	# Use body_entered area detection via an Area2D child if present,
	# otherwise we detect in _physics_process via player overlap.


func trigger_crumble() -> void:
	if _state != 0:
		return
	_state = 1
	_timer = shake_duration


func _physics_process(delta: float) -> void:
	# Check if player is standing on us (simple y-check)
	if _state == 0:
		var players := get_tree().get_nodes_in_group("player")
		for p: Node in players:
			if p is CharacterBody2D:
				var player := p as CharacterBody2D
				if player.is_on_floor():
					# Check if player is roughly above us
					var diff := player.global_position - global_position
					if abs(diff.x) < 120.0 and diff.y < -5.0 and diff.y > -60.0:
						trigger_crumble()

	match _state:
		1: # Shaking
			_timer -= delta
			_shake_timer += delta * 40.0
			position.x = _origin.x + sin(_shake_timer) * 3.0
			if _timer <= 0.0:
				_state = 2
				if _collision:
					_collision.disabled = true
				modulate.a = 0.5

		2: # Falling
			position.y += fall_speed * delta
			modulate.a -= delta * 0.8
			if modulate.a <= 0.0:
				_state = 3
				_timer = respawn_time
				visible = false

		3: # Waiting to respawn
			_timer -= delta
			if _timer <= 0.0:
				_respawn()


func _respawn() -> void:
	_state = 0
	position = _origin
	visible = true
	modulate.a = 1.0
	_shake_timer = 0.0
	if _collision:
		_collision.disabled = false
