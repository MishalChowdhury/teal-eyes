# Master Manifest - "The God File"

> **Purpose**: High-level overview. All agents read this first to understand the "Vibe" and Core Loop.

## Project Overview

**Project Name**: teal-eyes

**Engine**: Godot 4.5 (Stable)

**Language**: GDScript (Strict Typing preferred)

**Core Mechanic**: 2D Side-scroller with "Saree-Lasso" physics (Verlet Integration) and "Snap-Camera" room exploration.

**Art Style**: Hand-drawn, non-pixel art, high-res (4K source), layered parallax.

**Target Platforms**: Steam (PC) & PS5

## Implementation Status

### ✅ Completed Systems
- **Player Controller**: Component-based architecture with InputComponent, MovementComponent, AnimationComponent, and StateMachine
  - 5 functional states: Idle, Run, Jump, Fall, WallSlide
  - Wall jump with horizontal pushback
  - Coyote time and jump buffering
  - Resource-driven movement configuration (`DefaultMovementData.tres`)
- **Debug Tools**: DebugHUD with FPS tracking, velocity, state display (F12 toggle)
- **Test Environment**: `TestPlayerMovement.tscn` for movement validation

### 🚧 In Progress
- Saree/Lasso system (placeholder Marker2D exists)
- Animation system (AnimationComponent ready, needs AnimationPlayer setup)

### 📋 Planned
- Camera snap system (Phantom Camera integration)
- Room streaming and level management
- Advanced movement states (DoubleJump, Glide)
- Saree sub-states (LassoAim, LassoSwing, LassoRelease)

## Knowledge Base References

### Saree Physics (Verlet Integration)
- **Concept**: Godot 4 Verlet Rope implementations
- **Context**: "Study how Line2D points are updated in the _physics_process using a simple Verlet integration loop (pos = 2*pos - old_pos + accel * dt^2). We need this for the Saree, NOT RigidBody2D chains (too unstable)."

### Camera System (The "Snap" Logic)
- **Resource**: Phantom Camera for Godot
- **Context**: "We will use Phantom Camera for 'Room Snapping'. When the player enters a Area2D (Room trigger), the camera smoothly transitions to that room's specific Framed View."

### Character State Machine
- **Resource**: Godot Finite State Machine (GDQuest)
- **Context**: "The Player Controller must use a Hierarchical State Machine with the following states:"
  - **Main Movement States**: `Idle`, `Run`, `Jump`, `Fall`, `WallSlide`
  - **Advanced Movement States**: `DoubleJump`, `Glide`
  - **Saree Sub-States**: `LassoAim`, `LassoSwing`, `LassoRelease`
