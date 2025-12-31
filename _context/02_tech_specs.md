# Technical Specifications - "The Math"

> **Purpose**: Hard numbers for physics and rendering.

## 1. Physics Philosophy
- **Units**: Metric. 1 Meter = 100 Pixels
- **Framerate**: Physics ticks at 60Hz (`_physics_process`)
- **Integration**: Custom Verlet Integration for the Saree; Kinematic (`move_and_slide`) for the Player
- **V-Sync**: Disabled. Use fixed timestep independent of rendering FPS to ensure consistent physics across all hardware

## 2. Physics Scale
- **Standard Scale**: 100 pixels = 1 meter
- Use this ratio consistently across all physics calculations
- **Player Height**: ~3.6 meters (360px at standard zoom)

## 3. Configuration Strategy (NO HARDCODING)
All "Magic Numbers" must be exported via custom `Resource` files.
- **DO NOT** write `const GRAVITY = 980` in a script
- **DO** create a `PlayerMovementData` resource

### A. PlayerMovementData (Resource)
*Location: `res://resources/gameplay/player_movement_data.tres`*

Defines the feel of the character:
- `run_speed` (float): Standard move speed (pixels/sec)
- `jump_velocity` (float): Peak jump force
- `double_jump_velocity` (float): Second jump force multiplier
- `glide_gravity_scale` (float): Gravity reduction while gliding (0.0-1.0)
- `acceleration` (float): Ground friction/startup
- `air_acceleration` (float): Control while airborne
- `coyote_time` (float): Grace period after leaving a ledge (seconds)
- `wall_slide_friction` (float): Velocity multiplier when sliding on walls (0.8 recommended)
- `wall_slide_max_speed` (float): Maximum descent speed while wall sliding (pixels/sec)

### B. SareePhysicsData (Resource)
*Location: `res://resources/gameplay/saree_physics_data.tres`*

Defines the "Cloth" simulation:
- `segment_length` (float): Distance between Verlet points (e.g., 10.0 px)
- `stiffness` (float): 0.0 to 1.0 (How much the cloth resists stretching)
- `drag` (float): Air resistance applied to points (0.98 decay)
- `gravity_scale` (float): Multiplier for global gravity affecting the saree
- `simulation_iterations` (int): Number of constraint passes per frame (Higher = stiffer)
- `max_length_meters` (float): Maximum lasso distance (19.2m = 1920px)
- `pull_force` (float): Force applied when pulling (500.0 recommended)
- `break_distance_multiplier` (float): Distance beyond max_length before disconnect (1.1 = 10% overshoot)

## 4. Rendering

### Resolution & Zoom
- **Base Window**: 1920x1080 (Aspect Ratio 16:9)
- **Art Source**: 4K (3840x2160)
- **Standard Zoom**: 1.0 (No scaling, 1:1 pixel mapping at 1080p)
- **Zoom Range**: 0.5x (zoomed out) to 2.0x (zoomed in)
- **Scaling**: Assets will be downsampled from 4K sources

### Display Settings
- **Viewport**: Maintain 16:9 aspect ratio
- **Stretching**: Configure for proper scaling on different resolutions
- **Texture Filter**: Linear (smooth scaling)
- **Mipmaps**: Enabled (for zooming support)
- **Debanding**: Enabled in Project Settings (prevents gradient banding)

### Parallax Depth System
Background layers use z-index for depth sorting. Parallax speed formula:

**Formula**: `parallax_speed = 1.0 - (abs(z_index) / 50.0)`

**Layer Definitions**:
- **Layer 5** (Foreground): `z_index = 5`, parallax = 1.10 (moves faster than camera)
- **Layer 0** (Play Area): `z_index = 0`, parallax = 1.0 (moves with camera, 1:1)
- **Layer -5** (Mid-Ground): `z_index = -5`, parallax = 0.9
- **Layer -10** (Background): `z_index = -10`, parallax = 0.8
- **Layer -25** (Far Background): `z_index = -25`, parallax = 0.5
- **Layer -50** (Sky): `z_index = -50`, parallax = 0.0 (static skybox)

## 5. Saree Physics Constants

### Gameplay Mechanics
- **MAX_LENGTH_METERS**: 19.2 (1920 pixels = ½ screen width at 4K)
- **PULL_FORCE**: 500.0 (adjustable via `SareePhysicsData` resource)
- **WALL_SLIDE_FRICTION**: 0.8
- **WALL_SLIDE_MAX_SPEED**: 100.0 pixels/sec

### Interaction Logic (Mass-Based)
```gdscript
# Pseudocode for saree pull behavior
if target.is_static():
    # Infinite mass - pull player toward anchor
    apply_force_to_player(direction_to_anchor * PULL_FORCE)
elif target.mass < player.mass:
    # Light object - pull object toward player
    apply_force_to_target(direction_to_player * PULL_FORCE)
else:
    # Heavy object - pull player (or drag object slowly)
    apply_force_to_player(direction_to_anchor * PULL_FORCE)
```

### Tension & Breaking Rules
- **Soft Constraint**: Saree does NOT break permanently
- **Disconnect Behavior**: If `distance(player, anchor) > max_length * 1.1`:
  1. Apply small "tug" force to player (feedback)
  2. Emit `Events.saree_latch_broken.emit()`
  3. Disconnect and return to idle state

## 6. Collision Layer System (Strict)

**Critical**: Proper layer configuration prevents the Saree from detecting the player's own hitbox.

### Layer Definitions
- **Layer 1: World** - Floors, walls, platforms (StaticBody2D)
- **Layer 2: Player** - The CharacterBody2D and its collision shape
- **Layer 3: Saree** - The Saree's active hitbox/physics area
- **Layer 4: Interactables** - Lasso hooks, pushable boxes, dynamic objects
- **Layer 5: Hitbox/Hurtbox** - Enemy interactions, damage areas

### Interaction Rules

**Player Movement**:
- **Collision Layer**: Layer 2
- **Collision Mask**: Layers 1 + 4 (collides with World and Interactables)

**Saree RayCast**:
- **Collision Layer**: Layer 3
- **Collision Mask**: Layers 1 + 4 (detects World and Interactables, IGNORES Layer 2/Player)

**World Objects**:
- **Collision Layer**: Layer 1
- **Collision Mask**: Layers 2 + 3 (interacts with Player and Saree)

**Interactable Objects**:
- **Collision Layer**: Layer 4
- **Collision Mask**: Layers 2 + 3 (can be moved by Player, latched by Saree)

### Implementation in Godot
```gdscript
# Example: Configure Saree RayCast to ignore player
@onready var saree_raycast: RayCast2D = $SareeSystem/RayCast2D

func _ready():
    # Set which layer the raycast EXISTS on (for queries)
    saree_raycast.collision_layer = 0  # Not a physical object
    
    # Set which layers the raycast DETECTS (World + Interactables ONLY)
    saree_raycast.collision_mask = (1 << 0) | (1 << 3)  # Layers 1 and 4
    # This prevents detecting Layer 2 (Player)
```

## 6. The Math (Verlet Integration)
*Agents must implement this algorithm in the SareeComponent.*

### Point Update Loop
```gdscript
# For each point in the verlet chain:
velocity = current_pos - previous_pos
new_pos = current_pos + velocity * drag + gravity * delta * delta
previous_pos = current_pos
current_pos = new_pos
```

### Constraint Solving
```gdscript
# After position updates, enforce distance constraints:
for iteration in simulation_iterations:
    for i in range(len(points) - 1):
        var delta_pos = points[i+1] - points[i]
        var distance = delta_pos.length()
        var difference = (distance - segment_length) / distance
        var offset = delta_pos * difference * 0.5 * stiffness
        points[i] += offset
        points[i+1] -= offset
```

## 7. Input Mapping

### InputMap Actions
- `move_left`: Move character left
- `move_right`: Move character right
- `jump`: Jump action (hold for variable height)
- `glide`: Activate glide (while airborne)
- `saree_cast`: Cast/aim the Saree-Lasso
- `saree_pull`: Pull/retract the Saree-Lasso
- `saree_release`: Manually disconnect from anchor

### Input Handling
- Use Godot's InputMap system
- Support both keyboard and gamepad inputs
- Ensure proper input buffering for responsive controls (6-frame buffer recommended)

## 8. Room Management (The "3-Room Buffer")

### Streaming Strategy
- **Always Loaded**: `Current_Room` + all directly connected neighbors
- **Unload**: Any room with connection distance > 1
- **Loading Method**: Use `ResourceLoader.load_threaded_request()` for async loading to prevent frame drops

### Implementation
```gdscript
# Pseudocode for room streaming
func on_room_entered(new_room: Room):
    var neighbors = new_room.get_connected_rooms()
    for neighbor in neighbors:
        if not neighbor.is_loaded():
            ResourceLoader.load_threaded_request(neighbor.scene_path)
    
    # Unload distant rooms
    for loaded_room in currently_loaded_rooms:
        if loaded_room.distance_from(new_room) > 1:
            loaded_room.queue_free()
```

## 9. Saree Aiming System

### Diegetic Targeting (No UI Crosshair)
- **Max Range**: 19.2 meters (1920 pixels)
- **Visual Feedback**: When holding `saree_cast`:
  1. Saree tail visually uncoils and points toward mouse position
  2. If valid target in range: Target glows faintly (contextual highlight shader)
  3. If no valid target: Saree remains loose, no glow effect
- **RayCast Detection**: Use `RayCast2D` from player to mouse position, filtered by collision layers