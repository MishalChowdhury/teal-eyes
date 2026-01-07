extends Node

## Global wind system for cloth physics
## Manages wind direction, strength, and applies to all Pallu instances

# Wind parameters
@export var wind_enabled: bool = true
@export var base_wind_direction: Vector2 = Vector2(1, 0)  # Right by default
@export var base_wind_strength: float = 50.0
@export var gust_enabled: bool = true
@export var gust_frequency: float = 2.0  # Seconds between gusts
@export var gust_strength_multiplier: float = 2.0

# Internal state
var current_wind_force: Vector2 = Vector2.ZERO
var gust_timer: float = 0.0
var noise: FastNoiseLite


func _ready() -> void:
	# Initialize noise for natural wind variation
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.5


func _process(delta: float) -> void:
	if not wind_enabled:
		current_wind_force = Vector2.ZERO
		return
	
	# Base wind
	var wind_force = base_wind_direction.normalized() * base_wind_strength
	
	# Add gusts
	if gust_enabled:
		gust_timer += delta
		var noise_value = noise.get_noise_1d(Time.get_ticks_msec() / 1000.0)
		var gust_multiplier = 1.0 + (noise_value * gust_strength_multiplier)
		wind_force *= gust_multiplier
	
	current_wind_force = wind_force
	
	# Apply to all Pallu instances
	_apply_wind_to_pallus()


func _apply_wind_to_pallus() -> void:
	"""Find all PalluPhysics instances and apply wind"""
	var pallus = get_tree().get_nodes_in_group("pallu_physics")
	for pallu in pallus:
		if pallu.has_method("set_wind"):
			pallu.set_wind(current_wind_force.normalized(), current_wind_force.length())


func set_wind(direction: Vector2, strength: float) -> void:
	"""Manually set wind (overrides base wind)"""
	base_wind_direction = direction
	base_wind_strength = strength


func enable_wind() -> void:
	wind_enabled = true


func disable_wind() -> void:
	wind_enabled = false
	current_wind_force = Vector2.ZERO
