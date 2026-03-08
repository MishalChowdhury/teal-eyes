extends Node
class_name AudioComponent

## Bridges StateMachine state changes to audio feedback
## Handles footsteps (timer-based cadence), jump whoosh, and landing impact
## Follows same signal pattern as AnimationComponent

const WALK_INTERVAL := 0.45
const RUN_INTERVAL := 0.28
const PITCH_MIN := 0.9
const PITCH_MAX := 1.1

# Sound pools — loaded in _ready()
var _footstep_sounds: Array[AudioStream] = []
var _jump_sounds: Array[AudioStream] = []
var _land_sounds: Array[AudioStream] = []

# Audio players — created in _ready()
var _footstep_player: AudioStreamPlayer
var _jump_player: AudioStreamPlayer
var _land_player: AudioStreamPlayer

var _current_state: String = ""
var _footstep_timer: float = 0.0
var _is_grounded_state: bool = false


func _ready() -> void:
	_load_sound_pools()
	_create_audio_players()


func _physics_process(delta: float) -> void:
	if _current_state not in ["Walk", "Run"]:
		return

	_footstep_timer -= delta
	if _footstep_timer <= 0.0:
		_play_random(_footstep_player, _footstep_sounds)
		var interval := RUN_INTERVAL if _current_state == "Run" else WALK_INTERVAL
		_footstep_timer = interval


func _on_state_changed(old_state: String, new_state: String) -> void:
	_current_state = new_state

	# Footstep cadence — reset timer on entering Walk/Run
	if new_state in ["Walk", "Run"]:
		if old_state not in ["Walk", "Run"]:
			# Fresh ground movement — play first footstep soon
			_footstep_timer = 0.05
		else:
			# Switching between Walk ↔ Run — adjust interval, don't restart
			var interval := RUN_INTERVAL if new_state == "Run" else WALK_INTERVAL
			_footstep_timer = minf(_footstep_timer, interval)

	# Jump whoosh
	if new_state == "Jump":
		_play_random(_jump_player, _jump_sounds)

	# Landing impact — transitioning from airborne to grounded
	var airborne_states := ["Jump", "Fall", "WallSlide"]
	var grounded_states := ["Idle", "Walk", "Run"]
	if old_state in airborne_states and new_state in grounded_states:
		_play_random(_land_player, _land_sounds)


func _load_sound_pools() -> void:
	# Footsteps — concrete (5 variants)
	for i in range(5):
		var path := "res://assets/audio/kenney_impact-sounds/Audio/footstep_concrete_%03d.ogg" % i
		var stream := load(path) as AudioStream
		if stream:
			_footstep_sounds.append(stream)

	# Jump — air whoosh (3 variants)
	for i in range(1, 4):
		var path := "res://assets/audio/sfx_100_v2/sfx100v2_air_%02d.ogg" % i
		var stream := load(path) as AudioStream
		if stream:
			_jump_sounds.append(stream)

	# Landing — generic light impact (5 variants)
	for i in range(5):
		var path := "res://assets/audio/kenney_impact-sounds/Audio/impactGeneric_light_%03d.ogg" % i
		var stream := load(path) as AudioStream
		if stream:
			_land_sounds.append(stream)

	if _footstep_sounds.is_empty():
		push_warning("AudioComponent: No footstep sounds found")
	if _jump_sounds.is_empty():
		push_warning("AudioComponent: No jump sounds found")
	if _land_sounds.is_empty():
		push_warning("AudioComponent: No landing sounds found")


func _create_audio_players() -> void:
	_footstep_player = AudioStreamPlayer.new()
	_footstep_player.name = "FootstepPlayer"
	_footstep_player.volume_db = -6.0
	_footstep_player.bus = &"SFX" if AudioServer.get_bus_index("SFX") >= 0 else &"Master"
	add_child(_footstep_player)

	_jump_player = AudioStreamPlayer.new()
	_jump_player.name = "JumpPlayer"
	_jump_player.volume_db = -8.0
	_jump_player.bus = _footstep_player.bus
	add_child(_jump_player)

	_land_player = AudioStreamPlayer.new()
	_land_player.name = "LandPlayer"
	_land_player.volume_db = -4.0
	_land_player.bus = _footstep_player.bus
	add_child(_land_player)


func _play_random(player: AudioStreamPlayer, pool: Array[AudioStream]) -> void:
	if pool.is_empty() or not player:
		return
	player.stream = pool[randi() % pool.size()]
	player.pitch_scale = randf_range(PITCH_MIN, PITCH_MAX)
	player.play()
