extends Resource
class_name SareePhysicsData

## Saree Physics Configuration Resource
## Defines the cloth simulation parameters for the Verlet-based saree system

# Rope Structure
@export var num_segments: int = 40  ## Number of Verlet points in the chain (increased for higher resolution)
@export var segment_length: float = 10.0  ## Distance between points (pixels)

# Visual Smoothing (NEW - v2.0)
@export_range(2, 8) var points_per_segment: int = 4  ## Visual interpolation density (4 = 120 visual points for 30 physics points)
@export_range(0.0, 1.0) var spline_tension: float = 0.5  ## DEPRECATED (v2.1): Uniform spline used for performance. This value is ignored.

# Physics Properties
@export_range(0.0, 1.0) var stiffness: float = 0.8  ## Resistance to stretching (keep HIGH for silk, not rubber)
@export_range(0.0, 1.0) var drag: float = 0.98  ## Air resistance coefficient (lower = more drag)
@export var gravity_scale: float = 1.0  ## Gravity multiplier (0.6-1.5 for sway feel, lower = floatier)

# Motion Damping (NEW - v2.0)
@export_range(0.0, 0.1) var damping_coefficient: float = 0.02  ## Frame-rate independent velocity damping (higher = faster settling)

# Constraint Solver
@export_range(1, 10) var simulation_iterations: int = 4  ## Number of constraint passes per frame (increased from 3)

# Wind System (Optional)
@export var wind_strength: float = 0.0  ## Magnitude of wind force
@export var wind_direction: Vector2 = Vector2.RIGHT  ## Direction of wind force

# Advanced (Future Use)
@export var max_length_meters: float = 19.2  ## Maximum lasso distance (1920px = 19.2m)
@export var pull_force: float = 500.0  ## Force when pulling (for grappling mechanics)
@export var break_distance_multiplier: float = 1.1  ## Distance beyond max before disconnect
