# Fixes & Issues Log

> **Purpose**: Living document tracking all bugs, performance issues, and fixes for audit trail and knowledge sharing.

## Fix Log Format
Each entry includes:
- **Fix ID**: Numbered sequentially
- **Date**: When the issue was discovered and fixed
- **Category**: Bug, Performance, Architecture, etc.
- **Root Cause**: Technical explanation
- **Solution**: How it was resolved
- **Files Modified**: Affected files
- **Status**: Fixed, In Progress, Monitoring

---

## FIX-001: MovementComponent Parent Reference Bug
**Date**: 2025-12-31  
**Category**: Bug - Initialization Error  
**Reporter**: Runtime error during first test run

### Root Cause
`MovementComponent` attempted to get parent with `get_parent()`, expecting `CharacterBody2D`. However, the actual hierarchy is:
```
Player (CharacterBody2D)
└── Components (Node)
    └── MovementComponent
```
Result: `get_parent()` returned `Components` node, not `CharacterBody2D`, causing type error.

### Solution
Changed parent reference to traverse two levels:
```gdscript
var parent: Node = get_parent()  # Components node
_character_body = parent.get_parent() as CharacterBody2D  # Player
```

### Files Modified
- `res://entities/player/MovementComponent.gd:L20-28`

### Status
✅ **Fixed** - Tested and verified

---

## FIX-002: StateMachine Initialization Timing Issue
**Date**: 2025-12-31  
**Category**: Bug - Initialization Order  
**Reporter**: States had null component references

### Root Cause
Race condition between `Player._ready()` and `StateMachine._ready()`:
1. `StateMachine._ready()` ran first, tried to inject null dependencies into states
2. `Player._ready()` ran second, called `state_machine.init()` with actual components

Godot's `_ready()` execution order is not guaranteed between parent and child nodes.

### Solution
Moved state initialization logic from `StateMachine._ready()` to `StateMachine.init()`:
- `init()` is explicitly called by `Player.gd` after component references are ready
- `_ready()` now empty (just a placeholder)
- Ensures dependency injection happens at the right time

### Files Modified
- `res://entities/player/StateMachine.gd:L17-37`

### Status
✅ **Fixed** - Dependency injection pattern working correctly

---

## FIX-003: DebugHUD Performance Bottleneck
**Date**: 2025-12-31  
**Category**: Performance - Frame Rate Drop  
**Reporter**: FPS dropped from 60 to 27 after adding DebugHUD

### Root Cause
DebugHUD ran expensive operations every frame (60 FPS):
1. **String concatenation**: 12+ `+=` operations creating 720 string allocations/sec
2. **`get_tree().get_node_count()`**: Full scene tree traversal 60 times/sec
3. **`get_node_or_null()`**: Path parsing 120 times/sec
4. **Label.text updates**: UI redraws 60 times/sec

Architecture violation: Logic hardcoded to frame rate instead of using configurable timing.

### Solution
Implemented Timer-based throttling pattern (same as CoyoteTimer/JumpBufferTimer):
1. **Timer component**: Updates at 10Hz (0.1s interval) instead of 60Hz
2. **Cached references**: Components looked up once in `_ready()`, not per-frame
3. **PackedStringArray**: Efficient string building with `"\n".join(lines)`
4. **Smart control**: Timer stops when HUD hidden

Performance improvements:
- String operations: 720/sec → 120/sec (83% reduction)
- `get_node_count()`: 60/sec → 10/sec (83% reduction)  
- `get_node_or_null()`: 120/sec → 0/sec (100% reduction)
- Label updates: 60/sec → 10/sec (83% reduction)

### Files Modified
- `res://components/DebugHUD.gd:L1-87`

### Status
✅ **Fixed** - FPS restored to ~60

---

## FIX-004: Console Print Bottleneck in AnimationComponent
**Date**: 2025-12-31  
**Category**: Performance - Progressive FPS Degradation  
**Reporter**: FPS drops during jumping (60→50→40→25) and doesn't recover

### Root Cause
Debug `print()` statement in `AnimationComponent._on_state_changed()`:
```gdscript
print("[AnimationComponent] State changed: %s -> %s" % [old_state, new_state])
```

This ran **on every state transition**:
- Each jump triggers 2-3 state changes (Idle→Jump→Fall→Idle)
- `print()` forces **console I/O operations** (extremely expensive in Godot)
- Console buffer fills up progressively, causing cumulative slowdown
- FPS degrades with each jump and never recovers

**Why This Is Critical**:
- Console output in Godot is **synchronous** - blocks the main thread
- Each print allocates string memory and writes to console buffer
- Multiple rapid prints (during jumping) compound the issue
- This is why FPS started at 60 but got progressively worse

### Solution
Removed the debug `print()` statement entirely:
```gdscript
func _on_state_changed(old_state: String, new_state: String) -> void:
    # Animation logic goes here when AnimationPlayer is set up
    # (no print statement)
```

**Rule for future**: Use DebugHUD for runtime state display, NOT print statements in hot code paths.

### Files Modified
- `res://entities/player/AnimationComponent.gd:L17-35`

### Status
✅ **Fixed** - Verified no print statements remain in player components


---

## FIX-005: Print Statement Console I/O Bottleneck
**Date**: 2025-12-31  
**Category**: Performance - FPS Drop During Gameplay  
**Reporter**: User reported FPS drops and stuttering during jumping after adding DebugHUD

### Root Cause
Multiple debug `print()` statements in production code paths:
1. **Events.gd**: 2 print statements in helper emitters
   - `emit_camera_snap()`: Printed on every camera snap event
   - `emit_saree_latch()`: Printed on every saree latch event
2. **LevelManager.gd**: 4 print statements during room management
   - Room entry (line 24)
   - Room loading start (line 60)
   - Room loaded confirmation (line 79)
   - Room unloading (line 102)

These `print()` calls trigger **expensive console I/O operations** during gameplay:
- Console output is synchronous and blocks the main thread
- Each print allocates string memory and writes to console buffer
- Cumulative effect causes FPS degradation from 60 to 25-40
- Especially noticeable during jumping (multiple state transitions)

**Secondary Issue**: DebugHUD input handling used `_process()` to poll for F12 input 60 times per second, adding unnecessary overhead even when DebugHUD was hidden.

### Solution
**Print Statement Removal:**
- Removed all 6 print statements from Events.gd and LevelManager.gd
- Replaced with lightweight comments for code documentation
- Follows FIX-004 best practice: "Use DebugHUD for runtime state display, NOT print statements"

**DebugHUD Input Optimization:**
- Changed from `_process()` polling to `_unhandled_input()` event-driven handling
- Input checking now only occurs when F12 is actually pressed (event-driven)
- Eliminated 60 input checks per second when idle
- Streamlined toggle logic (removed compound F12+ESC check)

Performance improvements:
- Console I/O operations: 6+ events/gameplay → 0 (100% reduction)
- Input polling overhead: 60 checks/sec → 0 when idle (100% reduction)
- Expected FPS restoration: 25-40 → ~60

### Files Modified
- `res://scripts/auto_load/Events.gd:L20-26` (removed 2 print statements)
- `res://components/LevelManager.gd:L24,60,79,102` (removed 4 print statements)
- `res://components/DebugHUD.gd:L40-49` (optimized input handling)

### Status
✅ **Fixed** - All print statements removed, input handling optimized

---

## Statistics
- **Total Fixes**: 5
- **Critical Bugs**: 2 (FIX-001, FIX-002)
- **Performance Issues**: 3 (FIX-003, FIX-004, FIX-005)
- **Architecture Violations**: 0 (caught and prevented)

---

## Performance Best Practices (Learned)
1. **Never use `print()` in frequently-called code** (state transitions, _process, signals)
2. **Use DebugHUD with Timer throttling** for runtime debugging
3. **Profile before and after** adding debug features
4. **Remove all debug prints** before considering code "done"
5. **Use event-driven input handling** (`_unhandled_input()`) instead of polling in `_process()`

---

## FIX-006: Animation System Integration - Duplicate Signal Connection Crash
**Date**: 2026-01-02  
**Category**: Bug - Runtime Crash  
**Reporter**: User switching from PlayerRig to PlayerRigv2-m

### Root Cause
**Duplicate Signal Connection**: `state_changed` signal was connected in TWO places:
1. `Player.gd:27`: `state_machine.state_changed.connect(animation_component._on_state_changed)`
2. `AnimationComponent.gd:34`: `state_machine.state_changed.connect(_on_state_changed)`

When `AnimationComponent._ready()` tried to connect to the signal that `Player._ready()` had already connected, Godot threw `ERR_INVALID_PARAMETER` error, causing entire `Player._ready()` to fail. This prevented ALL component initialization, resulting in:
- No animation playback
- No state machine updates
- No debug output (components never initialized)

**Secondary Issues**:
1. **Animation Name Mismatch**: AnimationComponent used `.to_lower()` to convert state names (e.g., "Idle" → "idle"), but PlayerRigv2 had capitalized animation names ("Idle", "Walk")
2. **Node Path Mismatch**: AnimationComponent looked for `"Visuals/PlayerRig"` but user renamed to `"Visuals/PlayerRigv2-m"`
3. **Empty Animation Tracks**: Walk animation had 8 empty tracks (no keyframes), causing `AnimationMixer` errors preventing scene from loading

### Solution
**Signal Connection Fix**:
- Removed duplicate connection in `AnimationComponent.gd:34`
- Added comment explaining Player.gd handles connection
- Single connection point prevents error

**Animation Name Fix**:
- Renamed all animations to lowercase in PlayerRigv2-m.tscn:
  - "Idle" → "idle"
  - "Walk" → "walk"  
  - "JumpFloaty" → "jump"
  - "FallFloaty" → "fall"
  - "LandFloaty" → "land"
  - "RunFloaty" → "run"
  - "WallSlideFloaty" → "wallslidefloaty"
  - "TurnAround" → "turnaround"

**Node Path Fix**:
- Updated `AnimationComponent.gd:15`: `"Visuals/PlayerRigv2-m"`
- Updated error message to match new path

**Empty Track Fix**:
- Deleted 8 empty animation tracks in Walk animation (Spine, Shoulders, Arms, Wrists)
- Kept only tracks with actual keyframe data

### Files Modified
- `res://entities/player/AnimationComponent.gd:14-17,34-38`
- `res://entities/player/PlayerRigv2-m.tscn` (animation names + track cleanup)

### Status
✅ **Fixed** - Animations playing correctly, no crashes

---

## Statistics
- **Total Fixes**: 6
- **Critical Bugs**: 3 (FIX-001, FIX-002, FIX-006)
- **Performance Issues**: 3 (FIX-003, FIX-004, FIX-005)
- **Architecture Violations**: 0 (caught and prevented)

---

## Performance Best Practices (Learned)
1. **Never use `print()` in frequently-called code** (state transitions, _process, signals)
2. **Use DebugHUD with Timer throttling** for runtime debugging
3. **Profile before and after** adding debug features
4. **Remove all debug prints** before considering code "done"
5. **Use event-driven input handling** (`_unhandled_input()`) instead of polling in `_process()`
6. **Avoid heavy parallax backgrounds in test scenes** - use simple ColorRect for better performance



---

## FIX-007: Camera Framing System Implementation
**Date**: 2026-01-03  
**Category**: Feature - Camera System  
**Reporter**: User requested GRIS-style camera framing with floor in lower third

### Problem
Original camera system had multiple issues:
1. Hardcoded `Camera2D` zoom (1.5×) in Level01.tscn overrode PhantomCamera settings
2. Floor appearing in middle of screen instead of lower third
3. PhantomCamera `follow_offset` not calculated correctly for different zoom levels
4. Background sprites too small to cover viewport at lower zoom levels (0.3×)
5. PhantomCamera tween causing unwanted startup animation

### Solution
**Created Test Template System:**
- `TestTemplateFar.tscn`: 0.3× zoom, 7680px wide, camera offset (0, -900)
- `TestTemplateMid.tscn`: 0.8× zoom, 3840px wide, camera offset (0, -450)
- `TestTemplateClose.tscn`: 1.2× zoom 2560px wide, camera offset (0, -300)
- `TestTemplateIntimate.tscn`: 1.5× zoom, 1920px wide, camera offset (0, -240)

**PhantomCamera Integration:**
- Created `TestLevel01Phantom.tscn` combining all 4 test templates
- Added Area2D triggers (visible in editor) at correct heights to detect room entry
- Updated `Room.gd` to connect to pre-existing triggers instead of creating dynamically
- Set Camera2D to neutral state (zoom 1×, no manual offset) to let PhantomCamera control
- Removed tween from first room camera to prevent startup animation
- Other rooms use 1.5s tween for smooth zoom transitions

**Camera Math:**
- Floor at y=0 (Ground-Level Origin System)
- Camera offset calculated as: `-(viewport_height_at_zoom / 3)` for lower-third framing
- Trigger areas positioned at y=-1080 to cover player movement area
- PhantomCamera initial position matches player spawn to prevent camera "fly-in"

### Files Created
- `levels/TestTemplateMid.tscn`
- `levels/TestTemplateClose.tscn`
- `levels/TestTemplateIntimate.tscn`
- `levels/TestTemplateFar.tscn`
- `levels/TestLevel01Phantom.tscn`
- `levels/TestLevel01V2.tscn` (intermediate Camera2D-only version)
- `scripts/debug/FPSCounter.gd`
- `scripts/debug/CameraDebug.gd`

### Files Modified
- `levels/Room.gd`: Simplified trigger creation, connects to existing Area2D nodes
- `levels/acts/act_01/level_01/Level01.tscn`: Reset Camera2D offset and zoom

### Status
✅ **Complete** - Smooth zoom transitions working, floor framing correct, player visible at startup

---

## Statistics
- **Total Fixes**: 7
- **Critical Bugs**: 3 (FIX-001, FIX-002, FIX-006)
- **Performance Issues**: 3 (FIX-003, FIX-004, FIX-005)
- **Features**: 1 (FIX-007)
- **Architecture Violations**: 0 (caught and prevented)

