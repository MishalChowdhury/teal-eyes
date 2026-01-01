@tool
extends EditorScript

## Procedural Animation Generator for PlayerRig
## Generates mathematically-driven run and idle animations with cubic interpolation
## Usage: Select this script in FileSystem, then Script → Run

## ============================================================================
## CONFIGURATION PARAMETERS
## ============================================================================

## Run Cycle Parameters
var run_cycle_duration: float = 0.6  # seconds (from 09_animation_plan.md)
var run_thigh_amplitude: float = 0.3  # radians (±17°)
var run_shin_amplitude: float = 0.25  # radians, slightly less than thigh
var run_shin_lag_offset: float = 0.15  # phase offset for organic leg bend
var run_arm_amplitude: float = 0.3  # radians (±17°)
var run_torso_lean: float = 0.05  # forward lean while running
var run_hip_bob_amplitude: float = 2.0  # pixels up/down

## Idle Cycle Parameters
var idle_cycle_duration: float = 1.0  # seconds (from 09_animation_plan.md)
var idle_torso_rotation: float = 0.02  # radians (~1°, breathing)
var idle_hip_bob: float = 1.0  # pixels (subtle breathing)
var idle_head_counter_rotation: float = 0.01  # radians (opposite to torso)

## Jump Animation Parameters
var jump_duration: float = 0.4  # seconds (one-shot)
var jump_arm_raise: float = -0.5  # radians (arms up)
var jump_leg_tuck: float = -0.3  # radians (legs tucking)
var jump_torso_lean: float = -0.1  # radians (lean back)

## Fall Animation Parameters
var fall_duration: float = 0.3  # seconds (looping)
var fall_arm_position: float = -0.2  # radians (arms slightly up)
var fall_leg_position: float = 0.1  # radians (legs down)
var fall_torso_lean: float = 0.05  # radians (slight forward)

## Wall Slide Parameters
var wall_slide_duration: float = 0.8  # seconds (looping)
var wall_slide_arm_push: float = -0.4  # radians (arm against wall)
var wall_slide_torso_lean: float = 0.1  # radians (lean into wall)
var wall_slide_leg_brace: float = 0.15  # radians (legs bracing)

## ============================================================================
## MAIN EXECUTION
## ============================================================================

func _run() -> void:
	print("=== Animation Generator Starting ===")
	
	# Find PlayerRig scene
	var player_rig_path = "res://entities/player/PlayerRig.tscn"
	var player_rig = load(player_rig_path)
	if not player_rig:
		printerr("ERROR: Could not load PlayerRig.tscn")
		return
	
	var rig_instance = player_rig.instantiate()
	
	# Get AnimationPlayer
	var anim_player: AnimationPlayer = rig_instance.get_node_or_null("AnimationPlayer")
	if not anim_player:
		printerr("ERROR: AnimationPlayer not found in PlayerRig")
		rig_instance.queue_free()
		return
	
	# Get Skeleton for bone paths
	var skeleton: Skeleton2D = rig_instance.get_node_or_null("Visuals/Skeleton")
	if not skeleton:
		printerr("ERROR: Skeleton not found at Visuals/Skeleton")
		rig_instance.queue_free()
		return
	
	print("✓ Loaded PlayerRig successfully")
	print("✓ Found AnimationPlayer and Skeleton")
	
	# Generate animations
	generate_run_animation(anim_player, skeleton)
	generate_idle_animation(anim_player, skeleton)
	generate_jump_animation(anim_player, skeleton)
	generate_fall_animation(anim_player, skeleton)
	generate_wall_slide_animation(anim_player, skeleton)
	
	# Save the modified scene
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(rig_instance)
	if result == OK:
		result = ResourceSaver.save(packed_scene, player_rig_path)
		if result == OK:
			print("✓ Saved PlayerRig.tscn with new animations")
			print("=== Animation Generator Complete ===")
		else:
			printerr("ERROR: Failed to save scene: ", result)
	else:
		printerr("ERROR: Failed to pack scene: ", result)
	
	rig_instance.queue_free()

## ============================================================================
## RUN ANIMATION GENERATION
## ============================================================================

func generate_run_animation(anim_player: AnimationPlayer, skeleton: Skeleton2D) -> void:
	print("\n--- Generating RUN animation ---")
	
	# Get the default animation library
	var anim_library = anim_player.get_animation_library("")
	
	# Remove existing animation if present
	if anim_library.has_animation("run"):
		anim_library.remove_animation("run")
	
	# Create new animation
	var anim = Animation.new()
	anim.length = run_cycle_duration
	anim.loop_mode = Animation.LOOP_LINEAR
	
	# Get bone paths (relative to PlayerRig root, where AnimationPlayer lives)
	var bone_paths = {
		"hip": NodePath("Visuals/Skeleton/Bone_Hip"),
		"torso": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso"),
		"thigh_r": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Thigh_R"),
		"thigh_l": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Thigh_L"),
		"shin_r": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Thigh_R/Bone_Shin_R"),
		"shin_l": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Thigh_L/Bone_Shin_L"),
		"upper_arm_r": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso/Bone_Shoulder_R/Bone_UpperArm_R"),
		"upper_arm_l": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso/Bone_Shoulder_L/Bone_UpperArm_L"),
	}
	
	# Number of keyframes (more = smoother with cubic interpolation)
	var num_keyframes = 8
	var time_step = run_cycle_duration / float(num_keyframes)
	
	# Create tracks for each bone
	create_rotation_track(anim, bone_paths["torso"], "rotation")
	create_position_track(anim, bone_paths["hip"], "position")
	create_rotation_track(anim, bone_paths["thigh_r"], "rotation")
	create_rotation_track(anim, bone_paths["thigh_l"], "rotation")
	create_rotation_track(anim, bone_paths["shin_r"], "rotation")
	create_rotation_track(anim, bone_paths["shin_l"], "rotation")
	create_rotation_track(anim, bone_paths["upper_arm_r"], "rotation")
	create_rotation_track(anim, bone_paths["upper_arm_l"], "rotation")
	
	# Generate keyframes using sine waves
	for i in range(num_keyframes + 1):  # +1 to close the loop
		var t = time_step * i
		var cycle_progress = (t / run_cycle_duration) * TAU  # 0 to 2π
		
		# Torso: slight forward lean (constant)
		anim.track_insert_key(0, t, run_torso_lean)
		
		# Hip: bob up and down (vertical position variation)
		var hip_y = -50 + sin(cycle_progress * 2) * run_hip_bob_amplitude  # 2x frequency for bob
		anim.track_insert_key(1, t, Vector2(0, hip_y))
		
		# Right Thigh: sin(t)
		var thigh_r_rot = sin(cycle_progress) * run_thigh_amplitude
		anim.track_insert_key(2, t, thigh_r_rot)
		
		# Left Thigh: sin(t + PI) - opposite phase
		var thigh_l_rot = sin(cycle_progress + PI) * run_thigh_amplitude
		anim.track_insert_key(3, t, thigh_l_rot)
		
		# Right Shin: sin(t - offset) - lags behind thigh
		var shin_r_rot = sin(cycle_progress - run_shin_lag_offset) * run_shin_amplitude
		anim.track_insert_key(4, t, shin_r_rot)
		
		# Left Shin: sin(t + PI - offset) - opposite phase with lag
		var shin_l_rot = sin(cycle_progress + PI - run_shin_lag_offset) * run_shin_amplitude
		anim.track_insert_key(5, t, shin_l_rot)
		
		# Right Arm: opposite to right leg
		var arm_r_rot = sin(cycle_progress + PI) * run_arm_amplitude
		anim.track_insert_key(6, t, arm_r_rot)
		
		# Left Arm: opposite to left leg
		var arm_l_rot = sin(cycle_progress) * run_arm_amplitude
		anim.track_insert_key(7, t, arm_l_rot)
	
	# Add animation to player (reuse anim_library from line 87)
	anim_library.add_animation("run", anim)
	
	print("✓ Generated RUN animation with %d keyframes per track" % num_keyframes)

## ============================================================================
## IDLE ANIMATION GENERATION
## ============================================================================

func generate_idle_animation(anim_player: AnimationPlayer, skeleton: Skeleton2D) -> void:
	print("\n--- Generating IDLE animation ---")
	
	# Get the default animation library
	var anim_library = anim_player.get_animation_library("")
	
	# Remove existing animation if present
	if anim_library.has_animation("idle"):
		anim_library.remove_animation("idle")
	
	# Create new animation
	var anim = Animation.new()
	anim.length = idle_cycle_duration
	anim.loop_mode = Animation.LOOP_LINEAR
	
	# Get bone paths (relative to PlayerRig root, where AnimationPlayer lives)
	var bone_paths = {
		"hip": NodePath("Visuals/Skeleton/Bone_Hip"),
		"torso": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso"),
		"head": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso/Bone_Head"),
	}
	
	# Create tracks
	create_rotation_track(anim, bone_paths["torso"], "rotation")
	create_position_track(anim, bone_paths["hip"], "position")
	create_rotation_track(anim, bone_paths["head"], "rotation")
	
	# Keyframes: 0.0s, 0.5s (peak), 1.0s (back to start)
	var keyframe_times = [0.0, 0.5, 1.0]
	
	for t in keyframe_times:
		var cycle_progress = (t / idle_cycle_duration) * TAU
		
		# Torso: breathing rotation
		var torso_rot = sin(cycle_progress) * idle_torso_rotation
		anim.track_insert_key(0, t, torso_rot)
		
		# Hip: subtle bob
		var hip_y = -50 + sin(cycle_progress) * idle_hip_bob
		anim.track_insert_key(1, t, Vector2(0, hip_y))
		
		# Head: counter-rotation (subtle)
		var head_rot = -sin(cycle_progress) * idle_head_counter_rotation
		anim.track_insert_key(2, t, head_rot)
	
	# Add animation to player (reuse anim_library from line 174)
	anim_library.add_animation("idle", anim)
	
	print("✓ Generated IDLE animation with 3 keyframes per track")

## ============================================================================
## JUMP ANIMATION GENERATION
## ============================================================================

func generate_jump_animation(anim_player: AnimationPlayer, skeleton: Skeleton2D) -> void:
	print("\n--- Generating JUMP animation ---")
	
	# Get the default animation library
	var anim_library = anim_player.get_animation_library("")
	
	# Remove existing animation if present
	if anim_library.has_animation("jump"):
		anim_library.remove_animation("jump")
	
	# Create new animation
	var anim = Animation.new()
	anim.length = jump_duration
	anim.loop_mode = Animation.LOOP_NONE  # One-shot animation
	
	# Get bone paths
	var bone_paths = {
		"torso": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso"),
		"upper_arm_r": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso/Bone_Shoulder_R/Bone_UpperArm_R"),
		"upper_arm_l": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso/Bone_Shoulder_L/Bone_UpperArm_L"),
		"thigh_r": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Thigh_R"),
		"thigh_l": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Thigh_L"),
	}
	
	# Create tracks
	create_rotation_track(anim, bone_paths["torso"], "rotation")
	create_rotation_track(anim, bone_paths["upper_arm_r"], "rotation")
	create_rotation_track(anim, bone_paths["upper_arm_l"], "rotation")
	create_rotation_track(anim, bone_paths["thigh_r"], "rotation")
	create_rotation_track(anim, bone_paths["thigh_l"], "rotation")
	
	# Keyframes: 0.0s (neutral), 0.2s (peak thrust), 0.4s (hold)
	var keyframe_times = [0.0, 0.2, 0.4]
	var progress = [0.0, 0.5, 1.0]  # For easing
	
	for i in range(keyframe_times.size()):
		var t = keyframe_times[i]
		var p = progress[i]
		
		# Ease out curve (explosive start, then hold)
		var ease_factor = 1.0 - pow(1.0 - p, 2)
		
		# Torso: lean back
		anim.track_insert_key(0, t, jump_torso_lean * ease_factor)
		
		# Arms: raise up
		anim.track_insert_key(1, t, jump_arm_raise * ease_factor)
		anim.track_insert_key(2, t, jump_arm_raise * ease_factor)
		
		# Legs: tuck up
		anim.track_insert_key(3, t, jump_leg_tuck * ease_factor)
		anim.track_insert_key(4, t, jump_leg_tuck * ease_factor)
	
	# Add animation to player
	anim_library.add_animation("jump", anim)
	
	print("✓ Generated JUMP animation with 3 keyframes per track")

## ============================================================================
## FALL ANIMATION GENERATION
## ============================================================================

func generate_fall_animation(anim_player: AnimationPlayer, skeleton: Skeleton2D) -> void:
	print("\n--- Generating FALL animation ---")
	
	# Get the default animation library
	var anim_library = anim_player.get_animation_library("")
	
	# Remove existing animation if present
	if anim_library.has_animation("fall"):
		anim_library.remove_animation("fall")
	
	# Create new animation
	var anim = Animation.new()
	anim.length = fall_duration
	anim.loop_mode = Animation.LOOP_LINEAR
	
	# Get bone paths
	var bone_paths = {
		"torso": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso"),
		"upper_arm_r": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso/Bone_Shoulder_R/Bone_UpperArm_R"),
		"upper_arm_l": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso/Bone_Shoulder_L/Bone_UpperArm_L"),
		"thigh_r": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Thigh_R"),
		"thigh_l": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Thigh_L"),
	}
	
	# Create tracks
	create_rotation_track(anim, bone_paths["torso"], "rotation")
	create_rotation_track(anim, bone_paths["upper_arm_r"], "rotation")
	create_rotation_track(anim, bone_paths["upper_arm_l"], "rotation")
	create_rotation_track(anim, bone_paths["thigh_r"], "rotation")
	create_rotation_track(anim, bone_paths["thigh_l"], "rotation")
	
	# Keyframes: gentle floating motion with subtle arm sway
	var num_keyframes = 3
	var time_step = fall_duration / float(num_keyframes)
	
	for i in range(num_keyframes + 1):
		var t = time_step * i
		var cycle_progress = (t / fall_duration) * TAU
		
		# Torso: slight forward lean
		anim.track_insert_key(0, t, fall_torso_lean)
		
		# Arms: gentle sway (subtle floating motion)
		var arm_sway = sin(cycle_progress) * 0.05
		anim.track_insert_key(1, t, fall_arm_position + arm_sway)
		anim.track_insert_key(2, t, fall_arm_position - arm_sway)
		
		# Legs: hanging down
		anim.track_insert_key(3, t, fall_leg_position)
		anim.track_insert_key(4, t, fall_leg_position)
	
	# Add animation to player
	anim_library.add_animation("fall", anim)
	
	print("✓ Generated FALL animation with %d keyframes per track" % num_keyframes)

## ============================================================================
## WALL SLIDE ANIMATION GENERATION
## ============================================================================

func generate_wall_slide_animation(anim_player: AnimationPlayer, skeleton: Skeleton2D) -> void:
	print("\n--- Generating WALL_SLIDE animation ---")
	
	# Get the default animation library
	var anim_library = anim_player.get_animation_library("")
	
	# Remove existing animation if present
	if anim_library.has_animation("wall_slide"):
		anim_library.remove_animation("wall_slide")
	
	# Create new animation
	var anim = Animation.new()
	anim.length = wall_slide_duration
	anim.loop_mode = Animation.LOOP_LINEAR
	
	# Get bone paths
	var bone_paths = {
		"torso": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso"),
		"upper_arm_r": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Torso/Bone_Shoulder_R/Bone_UpperArm_R"),
		"thigh_r": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Thigh_R"),
		"thigh_l": NodePath("Visuals/Skeleton/Bone_Hip/Bone_Thigh_L"),
	}
	
	# Create tracks
	create_rotation_track(anim, bone_paths["torso"], "rotation")
	create_rotation_track(anim, bone_paths["upper_arm_r"], "rotation")
	create_rotation_track(anim, bone_paths["thigh_r"], "rotation")
	create_rotation_track(anim, bone_paths["thigh_l"], "rotation")
	
	# Keyframes: slow tension variation (strain against wall)
	var keyframe_times = [0.0, 0.4, 0.8]
	
	for t in keyframe_times:
		var cycle_progress = (t / wall_slide_duration) * TAU
		
		# Torso: lean into wall
		anim.track_insert_key(0, t, wall_slide_torso_lean)
		
		# Right arm: pushing against wall with subtle variation
		var arm_push_var = sin(cycle_progress) * 0.05
		anim.track_insert_key(1, t, wall_slide_arm_push + arm_push_var)
		
		# Legs: bracing position
		anim.track_insert_key(2, t, wall_slide_leg_brace)
		anim.track_insert_key(3, t, wall_slide_leg_brace)
	
	# Add animation to player
	anim_library.add_animation("wall_slide", anim)
	
	print("✓ Generated WALL_SLIDE animation with 3 keyframes per track")

## ============================================================================
## HELPER FUNCTIONS
## ============================================================================

func create_rotation_track(anim: Animation, bone_path: NodePath, property: String) -> int:
	var track_idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, String(bone_path) + ":" + property)
	anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_CUBIC)
	anim.track_set_interpolation_loop_wrap(track_idx, true)
	return track_idx

func create_position_track(anim: Animation, bone_path: NodePath, property: String) -> int:
	var track_idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, String(bone_path) + ":" + property)
	anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_CUBIC)
	anim.track_set_interpolation_loop_wrap(track_idx, true)
	return track_idx
