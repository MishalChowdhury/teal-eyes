@tool  # CRITICAL: Allows live editor iteration (v2.0)
extends Node2D
class_name SareeController

## Saree Controller - Manages visual rendering and physics simulation
## Connects the VerletSolver to the Line2D visual representation
## v2.0: Added fluid silk aesthetic with Catmull-Rom spline smoothing

@export var saree_data: SareePhysicsData:
	set(value):
		saree_data = value
		if saree_data and is_node_ready():
			_reinitialize_saree()  # Update visual immediately in editor

@onready var solver: VerletSolver = $VerletSolver
@onready var visual: Line2D = $SareeVisual

# Reference to the player's anchor point
var anchor: Marker2D = null

func _ready() -> void:
	# Configure Line2D for smooth, premium visual appearance (v2.0)
	visual.joint_mode = Line2D.LINE_JOINT_ROUND
	visual.begin_cap_mode = Line2D.LINE_CAP_ROUND
	visual.end_cap_mode = Line2D.LINE_CAP_ROUND
	visual.texture_mode = Line2D.LINE_TEXTURE_TILE  # CRITICAL: Prevent art stretching
	visual.antialiased = true
	
	# CRITICAL: Set Line2D to draw in global space to prevent position doubling
	visual.top_level = true
	
	# Find the SareeAnchor on the player
	anchor = owner.get_node_or_null("Visuals/SareeAnchor") if owner else null
	if anchor == null:
		push_error("SareeController: Could not find SareeAnchor in Player/Visuals")
		if owner:
			anchor = owner  # Fallback to player root
		else:
			return  # No owner in editor, skip initialization
	
	# Initialize the saree simulation
	_reinitialize_saree()

func _physics_process(delta: float) -> void:
	if not anchor or not saree_data:
		return
	
	# Get the current anchor position
	var anchor_pos = anchor.global_position
	
	# Update the physics simulation
	solver.update_simulation(delta, anchor_pos)
	# Visuals are now handled in _process() for interpolation

func _process(_delta: float) -> void:
	if not anchor or not saree_data:
		return
		
	# Manual Physics Interpolation (v3.0)
	# Decouple physics (60Hz) from rendering (120Hz+)
	var alpha = Engine.get_physics_interpolation_fraction()
	
	# Get interpolated positions from solver
	var interpolated_points = solver.get_interpolated_positions(alpha)

	# Apply Catmull-Rom spline smoothing for fluid silk appearance (v2.0)
	var smoothed = solver.get_smoothed_positions(
		saree_data.points_per_segment,
		saree_data.spline_tension,
		interpolated_points  # Pass interpolated points
	)
	
	visual.points = smoothed

## Reinitialize the saree simulation (called on resource change in editor)
func _reinitialize_saree() -> void:
	if not saree_data or not anchor:
		return
	
	# Pass the physics data to the solver
	solver.physics_data = saree_data
	
	# Initialize the Verlet simulation
	var start_pos = anchor.global_position
	solver.initialize(start_pos, saree_data.num_segments, saree_data.segment_length)
