# 08 Physics & Sprite Manifest (Boss Directives) v3.0

> **Purpose**: Translates "The Boss's" specific rig requirements and **File Inputs** into strict logic for the developer.
> **Context**: "You" = Mishal (Lead Dev), "Your Partner" = LLM Agent.
> **Status**: ✅ IMPLEMENTED (2026-01-01)

---

## 0. Reference Assets (Input)
*The Agent is responsible for ingesting the uploaded files and moving them to the strict project path below.*

**Target Path**: `res://assets/art/characters/player/parts/`

**The "10 Images" (Puppet Parts):** there could be more images thie list is not restrictred to below, and names might be different.
* `head.png`
* `torso.png`
* `arm_upper_l.png`, `arm_lower_l.png`
* `arm_upper_r.png`, `arm_lower_r.png`
* `leg_upper_l.png`, `leg_lower_l.png`
* `leg_upper_r.png`, `leg_lower_r.png`
* `mannequin_sketch.png` (Reference)

---

## 1. The Physics "Sheet" (Calibration Data)
*These values are derived from the `mannequin_sketch.png`.*

| Parameter | Value | Notes |
| :--- | :--- | :--- |
| **Reference Height** | `500px` | *Calibrate physics so this height feels "heavy".* |
| **Gravity** | *Dynamic* | *Tune so a 500px character doesn't float.* |

---

## 2. Sprite & Rigging Requirements (The "Puppet" Strategy)

### The Tech Stack
1.  **Skeleton2D**: The backbone.
    * **Root**: "Hip" bone (Center of Gravity).
    * **Hierarchy**: Standard Humanoid (Hip -> Torso -> Head, Hip -> Thigh -> Shin).
2.  **Polygon2D (Per Limb)**:
    * **Action**: Create **10 separate Polygon2D nodes**, one for each image file.
    * **Parenting**: Each Polygon2D must be a child of its respective `Bone2D` (e.g., `leg_lower_l.png` Polygon goes inside `Bone_Shin_L`).
    * **Configuration**: Set `skeleton` property to the main Skeleton2D.

### The "Surgery" (Mesh Generation)
*Developer Note:* The Agent must set up the nodes. The User will perform the internal vertex drawing.
* **Step 1**: Load image into Polygon2D.
* **Step 2**: User uses "Create Polygon from Bitmap" (The detailed guide you will generate).

---

## 3. The Saree Integration
* **Target Node**: `RemoteTransform2D`
* **Location**: Child of `Bone_Torso`.
* **Linkage**: The `SareeController` connects here to follow the chest movement.

---

## 4. Implementation Checklist for Developer (The Agent)

1.  **File Management**: Move the 10 uploaded images + sketch to `res://assets/art/characters/player/parts/`.
2.  **Scene Generation**: Create `PlayerRig.tscn`.
    * **Structure**: `Skeleton2D` → `Bone2D` → `Polygon2D (Image)`.
    * **Automation**: Write the `.tscn` text so these 10 nodes are pre-created and linked to the image files.
3.  **Hand-off Guide**: Generate the "Mesh & Weights" guide for the User to finalize the geometry in the Editor.

---

## 5. Implementation Status

**Status**: ✅ COMPLETE (2026-01-01)

**Implemented Files**:
- [PlayerRig.tscn](file:///Users/mishal/Documents/teal-eyes/entities/player/PlayerRig.tscn) - Complete skeletal rig
- [Player.tscn](file:///Users/mishal/Documents/teal-eyes/entities/player/Player.tscn) - Updated with PlayerRig instance
- [AnimationComponent.gd](file:///Users/mishal/Documents/teal-eyes/entities/player/AnimationComponent.gd) - AnimationPlayer integration

**Skeleton Structure** (14 bones):
```
Bone_Hip (root, 0, -50)
├── Bone_Torso (0, -30)
│   ├── Bone_Head (0, -35) 
│   │   └── Part_Head, Part_Hair (z=2)
│   ├── Bone_Shoulder_R (0, -25)
│   │   ├── SareeAnchor (RemoteTransform2D)
│   │   └── Bone_UpperArm_R → LowerArm_R → Hand_R (z=2)
│   ├── Bone_Shoulder_L (0, -20)
│   │   └── Bone_UpperArm_L → LowerArm_L → Hand_L (z=-1, behind saree)
│   └── Part_Torso, Part_Saree (z=1)
├── Bone_Thigh_R (5, 0) → Shin_R → Foot_R
└── Bone_Thigh_L (-5, 0) → Shin_L → Foot_L
```

**Polygon Meshes** (14 total):
- Torso, Saree, Head, Hair
- Upper/Lower/Hand Arms (R/L) 
- Upper/Lower/Foot Legs (R/L)

**AnimationPlayer**:
- 5 placeholder animations created (idle, run, jump, fall, wall_slide)
- Ready for keyframe animation (Phase C - deferred)

**Integration**:
- PlayerRig instanced into Player/Visuals (scene instantiation)
- Saree RemoteTransform2D connected to Bone_Shoulder_R
- Character renders with proper z-index layering
- Movement and physics systems verified working

**Reference Documentation**:
- [integration_complete.md](file:///Users/mishal/.gemini/antigravity/brain/f161ac07-d32a-41c5-8d7b-490da01607f1/integration_complete.md)
- [animation_implementation_plan.md](file:///Users/mishal/.gemini/antigravity/brain/f161ac07-d32a-41c5-8d7b-490da01607f1/animation_implementation_plan.md)
