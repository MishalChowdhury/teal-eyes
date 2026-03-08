# teal-eyes

> A 2D side-scroller featuring hand-drawn art and physics-driven Saree mechanics

**Status**: Active Development | **Target**: Steam (PC) & PS5

---

## 🎮 Overview

A 2D platformer with a unique "Saree-Lasso" mechanic using Verlet physics and snap-camera room exploration. Features skeletal animation, procedural generation, and hand-drawn 4K art assets.

### Core Mechanics
- **Component-based player** with 5 movement states (Idle, Run, Jump, Fall, WallSlide)
- **Skeletal animation system** with procedural sine-wave generation
- **Verlet physics** for realistic fabric simulation (Saree cloth dynamics)
- **Snap-camera** room transitions with zoom support
- **Manual physics interpolation** for 120Hz+ displays

---

## 🛠️ Tech Stack

- **Engine**: Godot 4.5 (Stable)
- **Language**: GDScript (strict typing preferred)
- **Art**: Hand-drawn, non-pixel art, 4K source (layered parallax)
- **Physics**: Custom Verlet integration, CharacterBody2D
- **Platforms**: Steam (PC) & PS5

---

## 📦 Installation

### Requirements
- Godot 4.5 or later
- Git LFS (for art assets)

### Setup
```bash
git clone https://github.com/[your-repo]/teal-eyes.git
cd teal-eyes
```

Open project in Godot 4.5+ and run `res://levels/MainLevel.tscn`

---

## ✨ Features

### Implemented
- ✅ **Player Controller**: Component-based architecture (InputComponent, MovementComponent, StateMachine)
- ✅ **5 Movement States**: Idle, Run, Jump, Fall, WallSlide with coyote time & jump buffering
- ✅ **Skeletal Animation**: 14-bone rig with procedurally generated animations
- ✅ **Procedural Animation**: Sine-wave motion with organic leg lag (cubic interpolation)
- ✅ **Saree Physics**: Verlet integration with smoothing (Catmull-Rom splines)
- ✅ **Multi-room Camera**: Phantom Camera integration for room snapping
- ✅ **Parallax Backgrounds**: 3-layer depth system (z-index based)
- ✅ **Debug Tools**: DebugHUD with FPS tracking, state display (F12 toggle)

### In Progress
- 🚧 Saree grappling mechanics (RayCast targeting, latch points)
- 🚧 Room system templates and connections

### Planned (30+ Levels Roadmap)
- 🎨 **Backgrounds**: Additional parallax layers and room variations
- 🧩 **Puzzles**: Environmental interaction mechanics
- 🎵 **Audio**: Music and sound effects integration
- 📖 **Story/Narrative**: Plot development
- 🎮 **Advanced States**: DoubleJump, Glide, Saree sub-states

---

## 🏗️ Architecture

### Component-Based Design
- **No God Scripts**: Player.gd is pure orchestration (36 lines)
- **Dependency Injection**: Components access each other via injected references
- **Signal-Driven**: Loose coupling via Events.gd autoload
- **Resource-Driven**: Zero hardcoded values (PlayerMovementData, SareePhysicsData)

### Key Systems
- **StateMachine**: Node-based states, disable `_physics_process` on inactive states
- **AnimationComponent**: Maps state changes to AnimationPlayer via signals
- **VerletSolver**: Custom physics for Saree with manual interpolation (60Hz physics → 120Hz+ render)
- **LevelManager**: 3-room buffer with async loading

---

## 📁 Project Structure

```
res://
├── _context/              # Living documentation (architecture, specs, status)
├── assets/art/            # 4K hand-drawn sprites & backgrounds
├── components/            # Reusable nodes (DebugHUD, LevelManager)
├── entities/
│   ├── player/            # Player.tscn, PlayerRig, states, components
│   └── saree/             # SareeController, VerletSolver
├── levels/                # Room scenes, TestPlayerMovement
├── resources/gameplay/    # Movement/physics data resources
└── scripts/auto_load/     # Events.gd, Global.gd
```

---

## 🙏 Credits & Attributions

### External Dependencies

**Bundled Addons**:
- [Phantom Camera](https://github.com/ramokz/phantom-camera) by ramokz - Multi-room camera system with priority handling

### Reference Implementations
*Studied for patterns and math, not copied verbatim*

- [Tshmofen/verlet-rope-4](https://github.com/Tshmofen/verlet-rope-4) - Verlet integration reference for stable rope physics
- [coffe789/Godot-2D-Cloth-and-Verlet-Physics-Simulator](https://github.com/coffe789/Godot-2D-Cloth-and-Verlet-Physics-Simulator) - Cloth constraint logic for Saree stiffness
- [Zoeticist-Games/godot-mood](https://github.com/Zoeticist-Games/godot-mood) - Component-based state machine pattern
- [EiTaNBaRiBoA/AsyncScene](https://github.com/EiTaNBaRiBoA/AsyncScene) - Async level loading pattern

### Art
All art assets created by Shanthini shanmugarajah ([@esvitez](https://github.com/esvitez)) - Hand-drawn original artwork

---

## 📄 License

**Code**: All Rights Reserved © 2026  
This is a private development project shared with collaborators.

**Third-Party Licenses**:
- Phantom Camera: MIT License (see `addons/phantom_camera/`)
- Godot Engine: MIT License

---

## 🔧 Development

### Documentation
See `_context/` folder for comprehensive project documentation:
- `00_master_manifest.md` - Project overview and core loop
- `01_architecture.md` - Design patterns and node hierarchy
- `02_tech_specs.md` - Physics math and configuration
- `07_implementation_status.md` - Feature catalog and completion status
- `09_animation_plan.md` - Animation specifications

### Key Configuration
- **Physics**: 100px = 1 meter, 60Hz fixed timestep
- **Resolution**: 1920×1080 base, 4K source assets
- **Collision Layers**: Strict 5-layer system (World, Player, Saree, Interactables, Hitbox)

---

## 🎯 Controls

- **A/D or Arrow Keys**: Move left/right
- **W or Space**: Jump
- **Shift**: Glide (planned)
- **Mouse**: Saree cast/release (planned)
- **F12**: Toggle debug HUD

---

**Built with Godot 4.5** | **Engine**: [godotengine.org](https://godotengine.org)
