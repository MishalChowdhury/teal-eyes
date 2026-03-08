@tool
extends Node2D
class_name PalluChainPhysics

## Physics-based saree pallu using RigidBody2D chain connected by PinJoint2D
## Provides realistic chiffon-like cloth simulation with grappling mechanics

# Signals
signal tip_locked(position: Vector2)
signal tip_unlocked()
signal anchor_connected(anchor_path: NodePath)

# Configuration
@export_group("Chain Configuration")
@export_range(2, 20, 1) var segment_count: int = 10
@export_range(10.0, 100.0, 1.0) var segment_length: float = 40.0
@export_range(5.0, 50.0, 1.0) var segment_radius: float = 10.0

@export_group("Physics Properties")
@export_range(0.1, 10.0, 0.1) var segment_mass: float = 1.5
@export_range(0.0, 2.0, 0.1) var gravity_scale: float = 0.4
@export_range(0.0, 10.0, 0.1) var linear_damp: float = 3.0
@export_range(0.0, 10.0, 0.1) var angular_damp: float = 5.0

@export_group("Joint Properties")
@export_range(0.0, 1.0, 0.01) var joint_softness: float = 0.5
@export_range(0.0, 1.0, 0.01) var joint_bias: float = 0.3

@export_group("Debug")
@export var debug_draw: bool = false

# Internal state
var segments: Array[RigidBody2D] = []
var joints: Array[PinJoint2D] = []
var anchor_transform: RemoteTransform2D = null
var is_tip_locked: bool = false
var tip_lock_position: Vector2 = Vector2.ZERO
var grapple_mode: bool = false


func _ready() -> void:
	if not Engine.is_editor_hint():
		add_to_group("pallu_physics")
	
	# Create chain if it doesn't exist
	if segments.size() == 0:
		_create_chain()


func _recreate_chain() -> void:
	"""Recreate chain when parameters change in editor"""
	if not Engine.is_editor_hint():
		return
	
	# Clear existing segments and joints
	for segment in segments:
		if is_instance_valid(segment):
			segment.queue_free()
	for joint in joints:
		if is_instance_valid(joint):
			joint.queue_free()
	
	segments.clear()
	joints.clear()
	
	# Recreate with new parameters
	call_deferred("_create_chain")


func _create_chain() -> void:
	"""Create the RigidBody2D chain with PinJoint2D connectors"""
	
	# Clear any existing segments first
	for segment in segments:
		if is_instance_valid(segment):
			segment.queue_free()
	for joint in joints:
		if is_instance_valid(joint):
			joint.queue_free()
	segments.clear()
	joints.clear()
	
	# Create segments
	for i in range(segment_count):
		var segment: RigidBody2D = RigidBody2D.new()
		segment.name = "Segment_%d" % i
		segment.mass = segment_mass
		segment.gravity_scale = gravity_scale
		segment.linear_damp = linear_damp
		segment.angular_damp = angular_damp
		
		# Enable continuous collision detection only for tip (prevents tunneling)
		if i == segment_count - 1:
			segment.continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
		
		# Collision shape
		var collision: CollisionShape2D = CollisionShape2D.new()
		collision.shape = CircleShape2D.new()
		collision.shape.radius = segment_radius
		segment.add_child(collision)
		collision.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self
		
		# Collision layers: Layer 3 (Saree), Mask 1 (World only)
		segment.collision_layer = 1 << 2 # Bit 2 = Layer 3
		segment.collision_mask = 1 << 0 # Bit 0 = Layer 1
		
		# Position segment
		segment.position = Vector2(i * segment_length, 0)
		
		add_child(segment)
		segment.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self
		segments.append(segment)
	
	# Create joints between segments
	for i in range(segment_count - 1):
		var joint: PinJoint2D = PinJoint2D.new()
		joint.name = "Joint_%d_%d" % [i, i + 1]
		joint.node_a = segments[i].get_path()
		joint.node_b = segments[i + 1].get_path()
		joint.softness = joint_softness
		joint.bias = joint_bias
		joint.disable_collision = true
		
		add_child(joint)
		joint.owner = self
		joints.append(joint)
	
	print("[PalluChainPhysics] Created chain with %d segments and %d joints" % [segments.size(), joints.size()])


func set_anchor_transform(transform_node: RemoteTransform2D) -> void:
	"""Connect the first segment to a RemoteTransform2D anchor"""
	anchor_transform = transform_node
	
	# Wait for ready if not ready yet
	if not is_node_ready():
		await ready
	
	if anchor_transform and segments.size() > 0:
		anchor_transform.remote_path = segments[0].get_path()
		print("[PalluChainPhysics] Anchored to: ", anchor_transform.get_path())
		anchor_connected.emit(anchor_transform.get_path())
	else:
		push_warning("[PalluChainPhysics] Cannot anchor - no segments created yet")


func get_tip_global_position() -> Vector2:
	"""Get the global position of the tip segment"""
	if not is_node_ready() or segments.size() == 0:
		return global_position
	return segments[-1].global_position


func lock_tip_to_anchor(anchor_pos: Vector2) -> void:
	"""Lock the tip segment to a grapple anchor point"""
	if segments.size() == 0:
		push_warning("[PalluChainPhysics] Cannot lock tip - no segments")
		return
	
	# Unlock if already locked
	if is_tip_locked:
		push_warning("[PalluChainPhysics] Tip already locked, unlocking first")
		unlock_tip_segment()
	
	is_tip_locked = true
	tip_lock_position = anchor_pos
	grapple_mode = true
	
	var tip: RigidBody2D = segments[-1]
	tip.freeze = true
	tip.global_position = anchor_pos
	
	print("[PalluChainPhysics] Tip locked to: ", anchor_pos)
	tip_locked.emit(anchor_pos)


func unlock_tip_segment() -> void:
	"""Release the tip segment from grapple anchor"""
	if segments.size() == 0:
		return
	
	is_tip_locked = false
	grapple_mode = false
	
	var tip: RigidBody2D = segments[-1]
	tip.freeze = false
	
	print("[PalluChainPhysics] Tip unlocked")
	tip_unlocked.emit()


func apply_wind_force(direction: Vector2, strength: float) -> void:
	"""Apply wind force to all segments"""
	var force: Vector2 = direction.normalized() * strength
	for segment in segments:
		segment.apply_central_force(force)


func _exit_tree() -> void:
	"""Clean up physics objects on scene exit"""
	for segment in segments:
		if is_instance_valid(segment):
			segment.queue_free()
	
	for joint in joints:
		if is_instance_valid(joint):
			joint.queue_free()
	
	segments.clear()
	joints.clear()
	
	print("[PalluChainPhysics] Cleaned up physics objects")


func _draw() -> void:
	"""Debug visualization"""
	if not debug_draw or not is_node_ready():
		return
	
	# Draw collision circles
	for segment in segments:
		if is_instance_valid(segment):
			draw_circle(to_local(segment.global_position), segment_radius, Color.GREEN, false, 2.0)
	
	# Draw joints
	for i in range(segments.size() - 1):
		if is_instance_valid(segments[i]) and is_instance_valid(segments[i + 1]):
			draw_line(
				to_local(segments[i].global_position),
				to_local(segments[i + 1].global_position),
				Color.YELLOW, 1.0
			)
	
	# Draw tip lock position
	if is_tip_locked:
		draw_circle(to_local(tip_lock_position), 15.0, Color.RED, false, 3.0)
