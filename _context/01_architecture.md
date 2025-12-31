# Architecture Blueprint

> **Purpose**: Defines the Node hierarchy and Design Patterns (State Machines, Signals).

## Key Architectural Directives

### Design Principles
- **Composition over Inheritance**: Use composition where possible to build flexible, modular systems.
- **Signal-Based Communication**: Components communicate via signals to maintain loose coupling.
- **State Machine Pattern**: Use Hierarchical State Machines for complex entity behaviors.

## Component Communication
- Use signals for cross-component communication
- Avoid tight coupling between systems
- Prefer event-driven architecture over direct method calls

---

# Player & Saree System Architecture

## 1. Player Node Hierarchy (CharacterBody2D)

### Core Components
- **CollisionShape2D**: Capsule shape for player physics
- **Sprite2D**: Visual body (head, torso, limbs)
- **AnimationPlayer**: Handles sprite animations

### Modular Component System
- **StateMachine (Node)**: Orchestrates state transitions
  - **Main States**: `Idle`, `Run`, `Jump`, `Fall`, `WallSlide` ✅ IMPLEMENTED
  - **Advanced States**: `DoubleJump`, `Glide` (planned)
  - **Saree Sub-States**: `LassoAim`, `LassoSwing`, `LassoRelease` (planned)
- **InputComponent (Node)**: Reads InputMap, emits input signals (`jump_pressed`, `move_input_changed`) ✅ IMPLEMENTED
- **MovementComponent (Node)**: Calculates velocity based on `PlayerMovementData` resource ✅ IMPLEMENTED
  - Includes CoyoteTimer and JumpBufferTimer for game feel
  - Wall jump with `apply_wall_jump(wall_normal)` function
- **AnimationComponent (Node)**: Wraps AnimationPlayer, listens to state change signals ✅ IMPLEMENTED (placeholder)

### Implementation Notes (2025-12-31)
**Pattern Used**: Dependency Injection
- `Player.gd` calls `state_machine.init(movement_component, animation_component)` in `_ready()`
- States access components via injected references (no `get_node()` calls)
- All signal wiring is programmatic in `Player.gd` (no manual editor connections)

**Files Created**:
- `res://entities/player/Player.tscn` - Main scene (CharacterBody2D, Layer 2, Mask 1+4)
- `res://entities/player/Player.gd` - Coordinator (31 lines, validates "No God Script" rule)
- `res://entities/player/InputComponent.gd`
- `res://entities/player/MovementComponent.gd` (with timers)
- `res://entities/player/AnimationComponent.gd`
- `res://entities/player/StateMachine.gd`
- `res://entities/player/states/` - BaseState, Idle, Run, Jump, Fall, WallSlide
- `res://resources/gameplay/PlayerMovementData.gd`
- `res://resources/gameplay/DefaultMovementData.tres`

### Saree System (Node2D)
Self-contained, modular subsystem that can be removed without breaking core movement:
- **SareeController**: Main brain, handles input signals (`cast`, `release`)
- **VerletSolver**: Pure physics math, no visuals
- **SareeRenderer (Line2D)**: Visual representation, polls VerletSolver for point positions
- **RayCast2D**: For aiming and detecting latch points

## 2. The Lasso Logic (The "Hook")
- **Mechanism**:
    1. Input `saree_cast` -> RayCast fires.
    2. If Hit -> Create `AnchorPoint` at hit position.
    3. Transition Player State -> `LassoSwing`.
    4. Physics: Apply force toward `AnchorPoint` (Pendulum logic).

## 3. Level System Architecture

### Main Game Scene Structure
- **MainGame (Node)**
    - **WorldEnvironment**: Glow, color correction, background canvas
    - **LevelManager (Node)**: Handles room streaming and transitions
    - **CurrentRoom (Node2D)**: Container for the active room scene
    - **Player**: Persistent across room transitions
    - **CameraRig**:
        - **PhantomCameraHost**: Manages camera priorities and transitions
        - **Camera2D**: The actual viewport camera

### LevelManager Component
**Purpose**: Centralized room streaming logic to prevent code duplication.

**Responsibilities**:
- Listen for `Events.room_entered(room_id)` signal
- Manage the 3-room buffer (current + neighbors)
- Asynchronously load connecting rooms via `ResourceLoader.load_threaded_request()`
- Unload distant rooms (distance > 1 connection)
- Handle room transition animations

**Why Not in Global.gd or Events.gd?**
- `Events.gd` is stateless (no variables allowed)
- `Global.gd` is for constants and utilities
- `LevelManager` needs to track loaded rooms and handle complex async logic

```gdscript
# Example LevelManager structure
extends Node
class_name LevelManager

var current_room: Room
var loaded_rooms: Dictionary = {}  # room_id -> Room instance

func _ready():
    Events.room_entered.connect(_on_room_entered)

func _on_room_entered(room_id: String):
    # Load neighbors asynchronously
    # Unload distant rooms
    # Update current_room reference
    pass
```


---

# Architecture Guidelines & Standards

## 1. Core Principles
- **Composition over Inheritance**: Do not make a generic `Entity` class. Use distinct Nodes (`HealthComponent`, `HitboxComponent`) attached to the scene
- **Resources for Data**: Logic scripts (`.gd`) should be generic. Data scripts (`.tres`) provide the specifics
- **Signal-Driven Architecture**: Nodes should not hard-reference each other deeply. Use Signals or the EventBus

## 2. The "No God Script" Rule
The `Player.gd` script should NOT handle inputs, animations, and physics directly. It should be a coordinator/wrapper.

### Enforcement
All player functionality must be delegated to specialized components as outlined in the Player Node Hierarchy above.

## 3. The Saree System (Modular Design)
The Saree must be detachable. If we remove the `SareeSystem` node, the player should still be able to walk and jump (just not use the lasso).

**Component Separation**:
- **SareeController**: The brain. Accepts input signals (`cast`, `release`)
- **VerletSolver**: The engine. Pure math node. No visuals
- **SareeRenderer**: The visual. A `Line2D` that polls the `VerletSolver` for point positions

## 4. Global Communication (EventBus)
Use the `Events.gd` AutoLoad for global communication. See [`05_event_bus_spec.md`](file:///Users/mishal/Documents/teal-eyes/_context/05_event_bus_spec.md) for details.

**Purpose**: Decouple the UI and Level interactions from the Player.

**Example Usage**:
- ❌ **Don't do**: `Player.get_node("Camera").zoom_out()`
- ✅ **Do**: `Events.request_camera_snap.emit(room_rect, zoom_level)`

## 5. Directory Structure (Strict)

Project must follow this exact structure:

```
res://
├── _context/                # Living documentation (agents read, devs update)
├── assets/
│   ├── art/
│   │   ├── characters/      # 4K source sprite imports
│   │   ├── environment/     # Rooms, props, backgrounds
│   │   └── ui/              # Interface elements
│   └── audio/               # Sound effects and music
├── components/              # Generic reusable nodes
│   ├── HealthComponent.gd
│   ├── HitboxComponent.gd
│   └── StateMachine.gd
├── entities/
│   ├── player/              # Player.tscn, Player.gd, player components
│   └── saree/               # SareeController.tscn, VerletSolver.gd
├── levels/
│   ├── rooms/               # Room_01.tscn, Room_02.tscn, etc.
│   └── main_game.tscn       # The "World" container scene
├── resources/
│   ├── gameplay/            # PlayerMovementData.tres, SareePhysicsData.tres
│   └── visuals/             # SareeCurve.tres, Gradients.tres
└── scripts/
    ├── auto_load/           # Events.gd, Global.gd (AutoLoad singletons)
    └── utils/               # MathHelpers.gd, Extensions.gd
```