# 06 Verified Mechanics & Reference Repositories

## 1. The "Saree" Physics (Verlet Rope + Cloth)
*Mechanic: A flowing fabric that simulates drag, gravity, and collision without using expensive RigidBody chains.*

### A. The Core Physics Engine (Stability)
* **Repo:** [Tshmofen/verlet-rope-4](https://github.com/Tshmofen/verlet-rope-4)
* **Why Verified:**
    * Standard implementation of "Verlet Integration" for Godot 4.
    * Solves the "Jitter" problem common in 2D ropes.
    * Includes **Wind Simulation** (Essential for the "Gris" aesthetic).
* **Agent Instruction:** Use this repo's math for the `VerletSolver.gd` class. Specifically, look at how they handle `update_particles()` to keep the simulation stable at 60fps.

### B. The "Cape/Saree" Aesthetic (Visuals)
* **Repo:** [coffe789/Godot-2D-Cloth-and-Verlet-Physics-Simulator](https://github.com/coffe789/Godot-2D-Cloth-and-Verlet-Physics-Simulator)
* **Why Verified:**
    * Specifically designed for **Player Capes/Cloth**.
    * Uses a "Grid" based Verlet (rather than just a single line), which is perfect for the **Saree Pallu** (the wide end of the fabric).
* **Agent Instruction:** Study the `constrain()` function. We need to implement a simplified version of this "stiffness" logic so the Saree doesn't look like a wet noodle.

### C. Manual Physics Interpolation (High-Refresh Rate Fix)
* **Problem:** Physics runs at 60Hz. M1/Gaming Monitors run at 120Hz+. Visuals snapped to physics ticks look jittery/laggy.
* **Solution:** Decouple Rendering from Physics.
    * `_physics_process`: Calculate positions.
    * `_process`: Calculate `alpha` using `Engine.get_physics_interpolation_fraction()`. Lerp between `previous` and `current` physics positions.
    * **Why Verified:** Standard Game Loop architectural pattern (Fixed Update vs Variable Render). Essential for Godot 4 on Mac/High-Refresh.

---

## 2. The Camera System (Phantom Camera)
*Mechanic: Smoothly snapping between rooms based on trigger zones, with priority handling.*

* **Repo:** [ramokz/phantom-camera](https://github.com/ramokz/phantom-camera)
* **Why Verified:**
    * The "Gold Standard" for Godot 4 cameras (3k+ stars).
    * Has a built-in **"Framed Follow"** mode (Exactly matches our `Room.gd` requirement).
    * Handles **Zoom transitions** automatically (Crucial for the "Portrait" to "Landscape" shifts we defined).
* **Agent Instruction:** Do NOT write a custom camera smoother. Use `PhantomCamera2D` nodes inside our Room scenes.
    * *Config:* Set `follow_mode = Framed`. Set `zoom` on the PhantomCamera resource, not the Camera2D itself.

---

## 3. The State Machine & Components
*Mechanic: Modular Player Controller without "God Scripts".*

* **Repo:** [Zoeticist-Games/godot-mood](https://github.com/Zoeticist-Games/godot-mood)
* **Why Verified:**
    * **Composition-Oriented:** Matches our `01_architecture.md` perfectly.
    * Treats States as **Nodes** (Components) that can be disabled/enabled.
* **Agent Instruction:** Structure our `StateMachine` node to disable `_physics_process` on inactive states, similar to how this repo handles "Moods".

---

## 4. Async Level Loading
*Mechanic: Streaming neighboring rooms without freezing the game.*

* **Repo:** [EiTaNBaRiBoA/AsyncScene](https://github.com/EiTaNBaRiBoA/AsyncScene)
* **Why Verified:**
    * Godot 4 specific.
    * Uses `ResourceLoader.load_threaded_request` correctly.
* **Agent Instruction:** Our `LevelManager` should replicate this `_load_next_level()` pattern. Use a "double-buffer" approach (instantiate new room in background -> wait for frame -> add to tree).
