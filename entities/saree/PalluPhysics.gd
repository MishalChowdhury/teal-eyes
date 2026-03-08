extends Skeleton2D
class_name PalluPhysics

## Verlet-based physics for Pallu cloth simulation
## Provides floaty, chiffon-like movement with bone control

# Physics parameters
@export var gravity: float = 200.0  # Pixels/sec² (light fabric)
@export var damping: float = 0.98  # Air resistance (0.0-1.0)
@export var stiffness: float = 0.5  # How rigid the cloth is (0.0-1.0)
@export var wind_force: Vector2 = Vector2.ZERO  # Wind direction/strength

# Bone chain
var bones: Array[Bone2D] = []
var bone_positions: Array[Vector2] = []
var bone_prev_positions: Array[Vector2] = []
var bone_rest_lengths: Array[float] = []

# Anchor (pinned to player shoulder)
var anchor_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Add to group for WindManager detection
	add_to_group("pallu_physics")
	
	# Collect all bones in order
	_collect_bones_recursive(self)
	
	# Initialize Verlet positions
	for bone in bones:
		bone_positions.append(bone.global_position)
		bone_prev_positions.append(bone.global_position)
		# Get rest length from bone's transform (xx component)
		var rest_transform = bone.get_rest()
		bone_rest_lengths.append(rest_transform.x.x)  # xx value = bone length


func _collect_bones_recursive(parent: Node) -> void:
	"""Recursively collect bones in chain order"""
	for child in parent.get_children():
		if child is Bone2D:
			bones.append(child)
			_collect_bones_recursive(child)


func _physics_process(delta: float) -> void:
	if bones.is_empty():
		return
	
	# Step 1: Update anchor position (follow player shoulder)
	anchor_position = global_position
	
	# Step 2: Verlet integration for each bone
	for i in range(bones.size()):
		if i == 0:
			# First bone (ShoulderBone) is pinned to anchor
			bone_positions[i] = anchor_position
			bone_prev_positions[i] = anchor_position
		else:
			# Calculate velocity (current - previous)
			var velocity = bone_positions[i] - bone_prev_positions[i]
			
			# Store current position
			bone_prev_positions[i] = bone_positions[i]
			
			# Apply forces
			var force = Vector2.ZERO
			force.y += gravity * delta  # Gravity pulls down
			force += wind_force * delta  # Wind pushes sideways
			
			# Update position: Verlet formula
			bone_positions[i] += velocity * damping + force
	
	# Step 3: Constraint solving (keep bones at correct distance)
	for iteration in range(3):  # Multiple passes for stability
		for i in range(1, bones.size()):
			var parent_idx = i - 1
			
			# Vector from parent to current bone
			var delta_pos = bone_positions[i] - bone_positions[parent_idx]
			var distance = delta_pos.length()
			var rest_length = bone_rest_lengths[i] if i < bone_rest_lengths.size() else 100.0
			
			if distance > 0:
				# Calculate correction
				var difference = (distance - rest_length) / distance
				var offset = delta_pos * difference * stiffness
				
				# Apply correction (only move child, parent is constrained)
				bone_positions[i] -= offset
	
	# Step 4: Apply positions to actual bones
	for i in range(bones.size()):
		bones[i].global_position = bone_positions[i]


func set_wind(direction: Vector2, strength: float) -> void:
	"""Set wind force (call from external script)"""
	wind_force = direction.normalized() * strength


func apply_impulse(bone_index: int, impulse: Vector2) -> void:
	"""Apply sudden force to specific bone (e.g., for grappling hook)"""
	if bone_index >= 0 and bone_index < bone_positions.size():
		bone_positions[bone_index] += impulse
