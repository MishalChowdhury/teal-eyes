@tool  # CRITICAL: Required because parent SareeController uses @tool (v2.0)
extends Node
class_name VerletSolver

## Verlet Integration Physics Engine for Saree Simulation
## Implements the algorithm from 02_tech_specs.md lines 149-172
## v2.0: Added Catmull-Rom spline interpolation and frame-rate independent damping

@export var physics_data: SareePhysicsData

# Verlet Point Data
var positions: Array[Vector2] = []
var previous_positions: Array[Vector2] = []

# Cached Physics Values
var gravity: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Cache gravity from project settings
	gravity = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))

## Initialize the Verlet chain
## CRITICAL: All points start at start_pos to prevent Frame 1 explosion
func initialize(start_pos: Vector2, num_segments: int, segment_length: float) -> void:
	positions.clear()
	previous_positions.clear()
	
	# Create all points at the same position (they'll naturally fall on frame 2)
	for i in range(num_segments):
		positions.append(start_pos)
		previous_positions.append(start_pos)

## Main simulation update loop
func update_simulation(delta: float, head_position: Vector2) -> void:
	if positions.is_empty() or not physics_data:
		return
	
	# Lock the first point to the player's anchor (shoulder)
	positions[0] = head_position
	previous_positions[0] = head_position
	
	# Apply forces to all other points
	apply_forces()
	
	# Update positions using Verlet integration
	_update_points(delta)
	
	# Solve distance constraints
	solve_constraints()

## Update all points using Verlet integration
## Formula from tech specs: new_pos = current_pos + velocity * drag + gravity * delta²
func _update_points(delta: float) -> void:
	for i in range(1, positions.size()):  # Skip point 0 (locked to player)
		var velocity = positions[i] - previous_positions[i]
		
		# Apply frame-rate independent damping (v2.0)
		velocity *= (1.0 - physics_data.damping_coefficient * delta)
		
		var acceleration = gravity * physics_data.gravity_scale
		
		# Add wind force if enabled
		if physics_data.wind_strength > 0.0:
			acceleration += physics_data.wind_direction.normalized() * physics_data.wind_strength
		
		var new_pos = positions[i] + velocity * physics_data.drag + acceleration * delta * delta
		
		previous_positions[i] = positions[i]
		positions[i] = new_pos

## Apply external forces (gravity, wind)
func apply_forces() -> void:
	# Forces are applied in _update_points for efficiency
	pass

## Solve stick constraints to maintain segment lengths
## Formula from tech specs lines 162-172
func solve_constraints() -> void:
	for _iteration in range(physics_data.simulation_iterations):
		for i in range(positions.size() - 1):
			var delta_pos = positions[i + 1] - positions[i]
			var distance = delta_pos.length()
			
			# Avoid division by zero
			if distance < 0.001:
				continue
			
			var difference = (distance - physics_data.segment_length) / distance
			var offset = delta_pos * difference * 0.5 * physics_data.stiffness
			
			# Point 0 is locked, only adjust point i+1
			if i == 0:
				positions[i + 1] -= offset * 2.0
			else:
				positions[i] += offset
				positions[i + 1] -= offset

## Get all current positions (for rendering)
func get_positions() -> Array[Vector2]:
	return positions

## Get interpolated positions for smooth rendering
## alpha is the interpolation fraction (0.0 to 1.0)
func get_interpolated_positions(alpha: float) -> Array[Vector2]:
	var interpolated: Array[Vector2] = []
	interpolated.resize(positions.size())
	
	for i in range(positions.size()):
		interpolated[i] = previous_positions[i].lerp(positions[i], alpha)
		
	return interpolated

## Generate smooth curve using Uniform Catmull-Rom spline interpolation (v2.1 Optimized)
## Performance: Replaces expensive pow() calls with standard vector math
## Optional: input_points can be passed for interpolation (defaults to self.positions if null)
func get_smoothed_positions(points_per_segment: int, _tension: float, input_points: Array[Vector2] = []) -> Array[Vector2]:
	var points_to_use = input_points if not input_points.is_empty() else positions
	
	if points_to_use.size() < 2:
		return points_to_use
	
	var smoothed: Array[Vector2] = []
	
	# For Catmull-Rom, we need 4 points (p0, p1, p2, p3) to interpolate between p1 and p2
	for i in range(points_to_use.size() - 1):
		# Get control points (handle boundary cases)
		var p0 = points_to_use[max(0, i - 1)]  # Previous point (or current if first)
		var p1 = points_to_use[i]  # Start of segment
		var p2 = points_to_use[i + 1]  # End of segment
		var p3 = points_to_use[min(points_to_use.size() - 1, i + 2)]  # Next point (or current if last)
		
		# Generate interpolated points along this segment
		for j in range(points_per_segment):
			var t = float(j) / float(points_per_segment)
			# Use Uniform spline (alpha=0.0) which is much faster than Centripetal
			# because it avoids the pow() function entirely
			var point = _uniform_catmull_rom(p0, p1, p2, p3, t)
			smoothed.append(point)
	
	# Add final point
	smoothed.append(points_to_use[-1])
	
	return smoothed

## Optimized Uniform Catmull-Rom Spline
## No pow() calls, bare metal vector math
func _uniform_catmull_rom(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 = t * t
	var t3 = t2 * t
	
	# Standard Catmull-Rom Matrix form for Uniform Spline
	# 0.5 * ( (2*p1) + (-p0 + p2)*t + (2*p0 - 5*p1 + 4*p2 - p3)*t2 + (-p0 + 3*p1 - 3*p2 + p3)*t3 )
	
	var term1 = p1 * 2.0
	var term2 = (p2 - p0) * t
	var term3 = (p0 * 2.0 - p1 * 5.0 + p2 * 4.0 - p3) * t2
	var term4 = (p1 * 3.0 - p0 - p2 * 3.0 + p3) * t3
	
	return (term1 + term2 + term3 + term4) * 0.5
