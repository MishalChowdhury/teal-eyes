# 05 Event Bus Specification

> **Purpose**: Define global event signals for decoupled system communication.

## 1. Philosophy
- **Stateless Relay**: `Events.gd` must NOT hold state variables. It simply defines signals and emits them.
- **Strict Typing**: All signal arguments must be typed to prevent "Variant" confusion.
- **Scope**: Only global events (Level transitions, UI updates, Gameplay state changes) go here. Local interactions (like a button opening a nearby door) should use direct signal connections.

## 2. Signal Definitions

### A. Camera & Level System
*Used by `PhantomCameraHost` and `Room.gd` triggers.*
- `request_camera_snap(target_rect: Rect2, zoom_level: float, duration: float)` → Triggers a smooth transition to a specific room view.
- `room_entered(room_id: String)` → Updates the minimap or streaming system.
- `cutscene_started()` / `cutscene_ended()` → Disables/Enables Player Input.

### B. Player & Saree Mechanics
*Used by `SareeController` and `VFXManager`.*
- `player_state_changed(new_state_name: String)` → For UI debug or music changes.
- `saree_cast_started(origin: Vector2, direction: Vector2)` → Triggers "Whoosh" sound/anim.
- `saree_latch_success(anchor_position: Vector2, surface_normal: Vector2)` → Triggers impact particles and "Tension" physics state.
- `saree_latch_broken()` → When the player releases or line snaps.

### C. System & UI
- `game_paused(is_paused: bool)`
- `screen_shake_requested(intensity: float, duration: float)`

## 3. Implementation Example

```gdscript
# Events.gd (AutoLoad)
extends Node

# Camera & Level Signals
signal request_camera_snap(target_rect: Rect2, zoom_level: float, duration: float)
signal room_entered(room_id: String)
signal cutscene_started()
signal cutscene_ended()

# Player & Saree Signals
signal player_state_changed(new_state_name: String)
signal saree_cast_started(origin: Vector2, direction: Vector2)
signal saree_latch_success(anchor_position: Vector2, surface_normal: Vector2)
signal saree_latch_broken()

# System Signals
signal game_paused(is_paused: bool)
signal screen_shake_requested(intensity: float, duration: float)

# Optional Helper Emitters (for logging/debugging)
func emit_camera_snap(rect: Rect2, zoom: float = 1.0, dur: float = 1.0) -> void:
    print("[EventBus] Camera snap requested: ", rect)
    request_camera_snap.emit(rect, zoom, dur)

func emit_saree_latch(anchor_pos: Vector2, normal: Vector2) -> void:
    print("[EventBus] Saree latched at: ", anchor_pos)
    saree_latch_success.emit(anchor_pos, normal)
```

## 4. Usage Guidelines

### DO ✅
- Use for cross-system communication (e.g., UI reacting to gameplay events)
- Emit events when something significant has **already happened**
- Type all signal parameters

### DON'T ❌
- Store state variables in `Events.gd`
- Use for local interactions (prefer direct node signals)
- Emit events speculatively or "just in case"

## 5. Expansion Protocol
When adding new signals:
1. Determine if it's truly global (affects multiple unrelated systems)
2. Add to appropriate category (A, B, or C)
3. Document the signal's purpose and which systems emit/listen
4. Update this document immediately
