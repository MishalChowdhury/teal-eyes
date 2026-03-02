extends Node2D
class_name PalluRenderer

## Visual rendering for PalluChainPhysics using Line2D or Polygon2D
## Provides smooth, interpolated visualization of the physics chain

enum RenderMode {LINE, POLYGON}

# Configuration
@export var render_mode: RenderMode = RenderMode.LINE
@export var base_width: float = 60.0
@export var tip_width: float = 20.0
@export var pallu_texture: Texture2D
@export var pallu_color: Color = Color(0.4, 0.7, 0.9, 1.0)
@export var render_z_index: int = 1
@export var chain_physics: PalluChainPhysics # Injected or auto-detected

# References
var line_renderer: Line2D
var polygon_renderer: Polygon2D
var cached_polygon_size: int = 0


func _ready() -> void:
	# Get reference to physics chain (injected or from parent)
	if not chain_physics:
		chain_physics = get_parent() as PalluChainPhysics
	
	if not chain_physics:
		push_error("[PalluRenderer] No PalluChainPhysics assigned or found in parent!")
		return
	
	# Create renderers
	_setup_line_renderer()
	_setup_polygon_renderer()
	
	# Show appropriate renderer
	if line_renderer and polygon_renderer:
		line_renderer.visible = (render_mode == RenderMode.LINE)
		polygon_renderer.visible = (render_mode == RenderMode.POLYGON)


func _setup_line_renderer() -> void:
	"""Create Line2D for debug/simple rendering"""
	line_renderer = Line2D.new()
	line_renderer.name = "LineRenderer"
	line_renderer.width = base_width
	line_renderer.default_color = pallu_color
	line_renderer.joint_mode = Line2D.LINE_JOINT_ROUND
	line_renderer.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line_renderer.end_cap_mode = Line2D.LINE_CAP_ROUND
	line_renderer.antialiased = true
	line_renderer.top_level = true
	line_renderer.z_index = render_z_index
	
	# Width curve (taper from shoulder to tip)
	var width_curve: Curve = Curve.new()
	width_curve.add_point(Vector2(0.0, 1.0))
	width_curve.add_point(Vector2(1.0, tip_width / base_width))
	line_renderer.width_curve = width_curve
	
	add_child(line_renderer)


func _setup_polygon_renderer() -> void:
	"""Create Polygon2D for production rendering"""
	polygon_renderer = Polygon2D.new()
	polygon_renderer.name = "PolygonRenderer"
	polygon_renderer.texture = pallu_texture
	polygon_renderer.color = pallu_color
	polygon_renderer.top_level = true
	polygon_renderer.z_index = render_z_index
	polygon_renderer.visible = false
	
	add_child(polygon_renderer)


func _process(_delta: float) -> void:
	"""Update visual representation every frame"""
	if not chain_physics or chain_physics.segments.size() == 0:
		return
	
	if render_mode == RenderMode.LINE and line_renderer:
		_update_line_renderer()
	elif render_mode == RenderMode.POLYGON and polygon_renderer:
		_update_polygon_renderer()
	
	# Request redraw for debug visualization
	if chain_physics.debug_draw:
		chain_physics.queue_redraw()


func _update_line_renderer() -> void:
	"""Update Line2D with segment positions"""
	var points: PackedVector2Array = []
	
	for segment in chain_physics.segments:
		if is_instance_valid(segment):
			points.append(segment.global_position)
	
	line_renderer.points = points


func _update_polygon_renderer() -> void:
	"""Update Polygon2D mesh with ribbon geometry"""
	if chain_physics.segments.size() < 2:
		return
	
	# Only rebuild mesh if segment count changed (performance optimization)
	if cached_polygon_size != chain_physics.segments.size():
		_rebuild_polygon_mesh()
		cached_polygon_size = chain_physics.segments.size()
	else:
		_update_polygon_vertices()


func _rebuild_polygon_mesh() -> void:
	"""Full mesh rebuild when segment count changes"""
	var points: PackedVector2Array = []
	var uvs: PackedVector2Array = []
	
	# Collect segment positions
	var segment_positions: Array[Vector2] = []
	for segment in chain_physics.segments:
		if is_instance_valid(segment):
			segment_positions.append(segment.global_position)
	
	# Generate ribbon mesh (quad strip along the chain)
	for i in range(segment_positions.size()):
		var pos: Vector2 = segment_positions[i]
		
		# Calculate perpendicular direction for width
		var forward: Vector2
		if i < segment_positions.size() - 1:
			forward = (segment_positions[i + 1] - pos).normalized()
		else:
			forward = (pos - segment_positions[i - 1]).normalized()
		
		var perpendicular: Vector2 = Vector2(-forward.y, forward.x)
		
		# Width tapering
		var t: float = float(i) / float(segment_positions.size() - 1)
		var width: float = lerp(base_width, tip_width, t) * 0.5
		
		# Add two vertices (left and right edge)
		points.append(pos + perpendicular * width)
		points.append(pos - perpendicular * width)
		
		# UV coordinates
		uvs.append(Vector2(0.0, t))
		uvs.append(Vector2(1.0, t))
	
	polygon_renderer.polygon = points
	polygon_renderer.uv = uvs


func _update_polygon_vertices() -> void:
	"""Fast path - only update vertex positions without rebuilding mesh"""
	var points: PackedVector2Array = polygon_renderer.polygon
	if points.size() != chain_physics.segments.size() * 2:
		_rebuild_polygon_mesh()
		return
	
	var idx: int = 0
	for i in range(chain_physics.segments.size()):
		if not is_instance_valid(chain_physics.segments[i]):
			continue
			
		var pos: Vector2 = chain_physics.segments[i].global_position
		
		# Calculate perpendicular direction
		var forward: Vector2
		if i < chain_physics.segments.size() - 1:
			forward = (chain_physics.segments[i + 1].global_position - pos).normalized()
		else:
			forward = (pos - chain_physics.segments[i - 1].global_position).normalized()
		
		var perpendicular: Vector2 = Vector2(-forward.y, forward.x)
		
		# Width tapering
		var t: float = float(i) / float(chain_physics.segments.size() - 1)
		var width: float = lerp(base_width, tip_width, t) * 0.5
		
		# Update vertices
		points[idx] = pos + perpendicular * width
		points[idx + 1] = pos - perpendicular * width
		idx += 2
	
	polygon_renderer.polygon = points


func set_render_mode(mode: RenderMode) -> void:
	"""Switch between Line2D and Polygon2D rendering"""
	render_mode = mode
	if line_renderer and polygon_renderer:
		line_renderer.visible = (mode == RenderMode.LINE)
		polygon_renderer.visible = (mode == RenderMode.POLYGON)
