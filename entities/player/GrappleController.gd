extends Node
class_name GrappleController

## Manages grappling hook targeting, pull physics, and visual feedback
## Phase 1: Pull-to-point mechanic with gamepad-friendly controls

# References (injected by Player.gd)
var movement_component: MovementComponent
var pallu_physics: PalluPhysics # Legacy Verlet system (deprecated)
var pallu_chain: PalluChainPhysics # NEW: RigidBody2D chain system

# Grapple state
var is_grappling: bool = false
var is_aiming: bool = false
var grapple_anchor: Vector2 = Vector2.ZERO
var hooked_object: Node2D = null # Store reference to the object we hooked
var aim_direction: Vector2 = Vector2.ZERO

# Configuration
@export var max_range: float = 450.0 # ~2x player height (player is ~220px tall)
@export var pull_force: float = 150.0 # Force for pulling objects/player (low to prevent oscillation)
@export var min_distance_to_stop: float = 100.0 # Stop pulling when this close (increased to prevent overshoot)
@export var aim_indicator_color: Color = Color(1.0, 0.8, 0.2, 0.6) # Yellow-ish glow

# Child nodes
@onready var raycast: RayCast2D = $GrappleRaycast
@onready var aim_indicator: Line2D = $AimIndicator


func _ready() -> void:
	# Configure raycast
	raycast.collision_mask = (1 << 0) | (1 << 3) # Layers 1 (World) + 4 (Interactables)
	raycast.exclude_parent = true
	raycast.enabled = false
	
	# Configure aim indicator (visual preview)
	aim_indicator.width = 3.0
	aim_indicator.default_color = aim_indicator_color
	aim_indicator.top_level = true # Draw in global space
	aim_indicator.visible = false
	aim_indicator.z_index = 10 # Draw above everything


func init(movement: MovementComponent, pallu: PalluPhysics) -> void:
	"""Initialize with required component references (legacy signature)"""
	movement_component = movement
	pallu_physics = pallu


func set_pallu_chain(chain: PalluChainPhysics) -> void:
	"""Set the new RigidBody2D-based pallu chain"""
	pallu_chain = chain
	print("[GrappleController] Pallu chain connected: ", chain.get_path())


func _process(_delta: float) -> void:
	"""Update visual aim indicator"""
	if is_aiming and not is_grappling:
		_update_aim_indicator()
	else:
		aim_indicator.visible = false
	
	# If grappling without Pallu, draw simple rope line
	if is_grappling and not pallu_physics:
		_draw_simple_rope()


func _draw_simple_rope() -> void:
	"""Fallback: Draw simple Line2D rope when PalluPhysics not available"""
	if not owner:
		return
	
	# Use hooked object's position if available, otherwise use static anchor
	var end_point: Vector2 = hooked_object.global_position if hooked_object else grapple_anchor
	
	# Create a simple straight line from player to target
	var rope_line: Array[Vector2] = [owner.global_position, end_point]
	
	# You could add a simple curve here for a bit more visual interest
	# For now, just a straight line
	aim_indicator.points = rope_line
	aim_indicator.default_color = Color(0.8, 0.6, 0.3, 1.0) # Brown rope color
	aim_indicator.width = 4.0
	aim_indicator.visible = true


func set_aim_direction(direction: Vector2) -> void:
	"""Update aim direction from input (right stick or mouse)"""
	aim_direction = direction.normalized()
	is_aiming = aim_direction.length() > 0.1


func try_cast_hook() -> bool:
	"""Attempt to cast grappling hook in aim direction. Returns true if hit."""
	if is_grappling or not is_aiming:
		print("[GrappleController] Cannot cast - is_grappling:", is_grappling, " is_aiming:", is_aiming)
		return false
	
	# Set raycast origin - use pallu tip if available, otherwise player center
	if pallu_chain and is_instance_valid(pallu_chain):
		raycast.global_position = pallu_chain.get_tip_global_position()
	elif owner:
		raycast.global_position = owner.global_position
	
	# Cast raycast in aim direction
	raycast.target_position = aim_direction * max_range
	raycast.enabled = true
	raycast.force_raycast_update()
	
	# DEBUG: Print raycast info
	print("[GrappleController] Raycast check - colliding:", raycast.is_colliding(), " mask:", raycast.collision_mask)
	print("  → Origin:", raycast.global_position)
	print("  → Direction:", aim_direction)
	print("  → Target pos:", raycast.target_position)
	print("  → Max range:", max_range)
	
	if raycast.is_colliding():
		grapple_anchor = raycast.get_collision_point()
		hooked_object = raycast.get_collider() # Store reference to hooked object
		print("[GrappleController] HIT! Collider:", hooked_object.name, " at ", grapple_anchor)
		_start_grapple()
		return true
	
	# No hit - disable raycast
	raycast.enabled = false
	print("[GrappleController] No valid target in range")
	return false


func _start_grapple() -> void:
	"""Initialize grappling state"""
	is_grappling = true
	is_aiming = false
	
	# Tell Pallu system to enter grapple mode
	if pallu_chain:
		pallu_chain.lock_tip_to_anchor(grapple_anchor)
	elif pallu_physics:
		pallu_physics.set_grapple_mode(true, grapple_anchor)
	
	# Emit event for other systems
	Events.saree_latch_success.emit(grapple_anchor, Vector2.ZERO)
	
	print("[GrappleController] Grapple started at ", grapple_anchor)


func apply_pull_force(delta: float) -> void:
	"""Apply pull force - pulls RigidBody2D objects toward player, or player toward static objects"""
	if not is_grappling or not movement_component or not hooked_object:
		return
	
	# For RigidBody2D: pull object toward player (don't update anchor - let object move freely)
	if hooked_object is RigidBody2D:
		_pull_object_toward_player(hooked_object, delta)
	else:
		# For static objects: pull player toward anchor
		_pull_player_toward_anchor(delta)


func _pull_object_toward_player(object: RigidBody2D, delta: float) -> void:
	"""Pull a RigidBody2D object toward the player"""
	var to_player: Vector2 = owner.global_position - object.global_position
	var distance: float = to_player.length()
	
	# Auto-release if object is close enough
	if distance < min_distance_to_stop:
		print("[GrappleController] Object reached player - auto-releasing")
		release_hook()
		return
	
	# SIMPLE APPROACH: Move the box using velocity (works with physics)
	var pull_speed: float = 200.0 # pixels per second
	var direction: Vector2 = to_player.normalized()
	
	# Set velocity directly - let physics engine handle the movement
	object.linear_velocity = direction * pull_speed
	
	# Only print occasionally to avoid spam
	if Engine.get_physics_frames() % 30 == 0:
		print("[GrappleController] Pulling ", object.name, " toward player (distance: ", distance, ")")


func _pull_player_toward_anchor(delta: float) -> void:
	"""Pull the player toward a static anchor point (wall/floor)"""
	var to_anchor: Vector2 = grapple_anchor - owner.global_position
	var distance: float = to_anchor.length()
	
	# Auto-release if close enough
	if distance < min_distance_to_stop:
		print("[GrappleController] Reached anchor - auto-releasing")
		release_hook()
		return
	
	# Apply constant pull force (no scaling with distance)
	var pull_direction: Vector2 = to_anchor.normalized()
	var current_vel: Vector2 = movement_component.get_velocity()
	current_vel += pull_direction * pull_force * delta
	movement_component.set_velocity(current_vel)


func release_hook() -> void:
	"""Release grappling hook and return to normal movement"""
	if not is_grappling:
		return
	
	is_grappling = false
	raycast.enabled = false
	
	# Tell Pallu to return to trailing mode
	if pallu_chain:
		pallu_chain.unlock_tip_segment()
	elif pallu_physics:
		pallu_physics.set_grapple_mode(false, Vector2.ZERO)
	
	# Emit event
	Events.saree_latch_broken.emit()
	
	print("[GrappleController] Grapple released")


func is_active() -> bool:
	"""Check if currently grappling"""
	return is_grappling


func _update_aim_indicator() -> void:
	"""Update the visual aim indicator line"""
	if not owner:
		return
	
	# Set raycast origin to player position
	raycast.global_position = owner.global_position
	
	# Cast a preview ray to check if target is valid
	raycast.target_position = aim_direction * max_range
	raycast.enabled = true
	raycast.force_raycast_update()
	
	var start_pos: Vector2 = owner.global_position
	var end_pos: Vector2 = start_pos + (aim_direction * max_range)
	
	# Cast raycast to find actual hit point
	# raycast.target_position = aim_direction * max_range # This line is now redundant
	# raycast.enabled = true # This line is now redundant
	# raycast.force_raycast_update() # This line is now redundant
	
	if raycast.is_colliding():
		# Show line to hit point (valid target)
		end_pos = raycast.get_collision_point()
		aim_indicator.default_color = Color(0.2, 1.0, 0.3, 0.8) # Green = valid target
	else:
		# Show line to max range (no target)
		aim_indicator.default_color = Color(1.0, 0.3, 0.2, 0.5) # Red = invalid
	
	# Update line points
	aim_indicator.points = [start_pos, end_pos]
	aim_indicator.visible = true
	
	# Disable raycast after preview (will re-enable on cast)
	raycast.enabled = false
