extends Node

## Camera & Level Management
signal request_camera_snap(target_position: Vector2, zoom_level: float)
signal room_entered(room_id: String)
signal room_transition_triggered(from_room: String, to_room: String)
signal cutscene_started()
signal cutscene_ended()

## Player & Saree Signals
signal player_state_changed(new_state_name: String)
signal saree_cast_started(origin: Vector2, direction: Vector2)
signal saree_latch_success(anchor_position: Vector2, surface_normal: Vector2)
signal saree_latch_broken()

## System Signals
signal game_paused(is_paused: bool)
signal screen_shake_requested(intensity: float, duration: float)

## Optional Helper Emitters (for logging/debugging)
func emit_camera_snap(rect: Rect2, zoom: float = 1.0, dur: float = 1.0) -> void:
	request_camera_snap.emit(rect, zoom, dur)

func emit_saree_latch(anchor_pos: Vector2, normal: Vector2) -> void:
	saree_latch_success.emit(anchor_pos, normal)
