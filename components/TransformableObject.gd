extends Node
class_name TransformableObject

## Makes the parent Node2D visually (and optionally physically) transform
## between a frozen grey state and a fully alive colorful state.
## Attach as a child of any Node2D in the level.
##
## Reads from TransformationField (in group "transformation_field") each frame.

## ── Visual ────────────────────────────────────────────────────────────────

## Modulate applied when fully frozen
@export var frozen_color: Color = Color(0.35, 0.35, 0.45)
## Modulate applied when fully alive (white = original color)
@export var alive_color: Color = Color(1.0, 1.0, 1.0)

## ── Reach ─────────────────────────────────────────────────────────────────

## Base reach: how far from player this transforms with zero field
@export var base_reach: float = 120.0
## At max field strength, effective reach = base_reach * this multiplier
@export var max_reach_multiplier: float = 3.0

## ── Behaviour ─────────────────────────────────────────────────────────────

## If true: once fully alive it stays that way permanently
@export var holds_transform: bool = false
## How fast the object reverts when player leaves (units/second, higher = faster)
@export var decay_rate: float = 1.5

## ── Physics (optional) ────────────────────────────────────────────────────

## If true: CollisionShape2D on parent is disabled while frozen.
## Use for platforms the player can only stand on when alive.
@export var disable_collision_when_frozen: bool = false

# ── Runtime ──────────────────────────────────────────────────────────────

var transform_amount: float = 0.0  ## 0 = frozen  1 = alive
var _locked_alive: bool = false

@onready var _target: Node2D = get_parent() as Node2D

var _field: TransformationField = null
var _collision: CollisionShape2D = null
var _col_was_solid: bool = false  # hysteresis state


func _ready() -> void:
	_target.modulate = frozen_color

	if disable_collision_when_frozen:
		_collision = _target.get_node_or_null("CollisionShape2D")
		if _collision:
			_collision.disabled = true  # start frozen = no collision

	call_deferred("_find_field")


func _find_field() -> void:
	_field = get_tree().get_first_node_in_group("transformation_field") as TransformationField


func _process(delta: float) -> void:
	if _locked_alive:
		return

	if not _field:
		_find_field()
		if not _field:
			return

	# ── Calculate target transform amount ──────────────────────────────────

	var f_pos := _field.field_position
	var f_strength := _field.field_strength
	var f_radius := _field.field_radius

	# Reach grows with field strength beyond the base
	var extra := base_reach * (max_reach_multiplier - 1.0) * f_strength
	var effective_reach := f_radius + extra

	var distance := _target.global_position.distance_to(f_pos)
	var proximity := 1.0 - clampf(distance / effective_reach, 0.0, 1.0)
	var target_amount := proximity

	# ── Lerp toward target ────────────────────────────────────────────────

	if target_amount > transform_amount:
		transform_amount = move_toward(transform_amount, target_amount, delta * 5.0)
	else:
		transform_amount = move_toward(transform_amount, target_amount, delta * decay_rate)

	# ── Permanent lock ────────────────────────────────────────────────────

	if holds_transform and transform_amount >= 0.99:
		transform_amount = 1.0
		_locked_alive = true

	_apply_visuals()


func _apply_visuals() -> void:
	_target.modulate = frozen_color.lerp(alive_color, transform_amount)

	# Collision toggle with hysteresis to prevent flickering
	if _collision:
		var should_be_solid: bool
		if _col_was_solid:
			should_be_solid = transform_amount >= 0.2   # hold solid until 20%
		else:
			should_be_solid = transform_amount >= 0.5   # become solid at 50%

		_collision.disabled = not should_be_solid
		_col_was_solid = should_be_solid
