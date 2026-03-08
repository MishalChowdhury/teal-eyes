extends Node
class_name TransformationField

## Tracks player movement speed and exposes a transformation field.
## Place anywhere in the scene tree — it finds the player by group.
## TransformableObject reads field_strength, field_radius, field_position.

## Field radius when running at full speed
@export var max_radius: float = 320.0
## Field radius when stationary
@export var base_radius: float = 60.0
## Speed (px/s) at which field reaches max radius
@export var speed_for_max: float = 420.0
## Lerp speed when field is growing (player accelerating)
@export var grow_speed: float = 4.0
## Lerp speed when field is shrinking (player decelerating)
@export var shrink_speed: float = 2.5

## Read by TransformableObject — current field strength 0..1
var field_strength: float = 0.0
## Read by TransformableObject — current field radius in pixels
var field_radius: float = 0.0
## Read by TransformableObject — world position of field center
var field_position: Vector2 = Vector2.ZERO

var _player: CharacterBody2D = null


func _ready() -> void:
	field_radius = base_radius
	add_to_group("transformation_field")
	call_deferred("_find_player")


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D


func _physics_process(delta: float) -> void:
	if not _player:
		_find_player()
		return

	field_position = _player.global_position
	var speed := _player.velocity.length()
	var target_strength := clampf(speed / speed_for_max, 0.0, 1.0)

	var lerp_speed := grow_speed if target_strength > field_strength else shrink_speed
	field_strength = lerpf(field_strength, target_strength, delta * lerp_speed)
	field_radius = lerpf(base_radius, max_radius, field_strength)
