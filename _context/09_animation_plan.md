# 09 Animation Implementation Plan

> **Purpose**: Complete guide for creating bone animations for the skeletal rig.  
> **Context**: PlayerRig skeletal system is complete and integrated. Ready for animation keyframing.  
> **Goal**: Create 5 animations (idle, run, jump, fall, wall_slide) using Godot's AnimationPlayer.  
> **For**: New LLM Agent Session  
> **Last Updated**: 2026-01-01

---

## Current State Assessment

### ✅ What's Working

**Skeletal System**: [PlayerRig.tscn](file:///Users/mishal/Documents/teal-eyes/entities/player/PlayerRig.tscn)
- 14-bone Skeleton2D hierarchy fully rigged
- 14 Polygon2D meshes attached to bones
- All bones have proper rest transforms
- Z-index layering configured

**Animation Infrastructure**:
- AnimationPlayer node exists in PlayerRig
- 5 placeholder animations created: `idle`, `run`, `jump`, `fall`, `wall_slide`
- [AnimationComponent.gd](file:///Users/mishal/Documents/teal-eyes/entities/player/AnimationComponent.gd) maps states to animations
- System tested and working (triggers animations on state changes)

**Integration**:
- PlayerRig instanced in [Player.tscn](file:///Users/mishal/Documents/teal-eyes/entities/player/Player.tscn)
- Character renders correctly in game
- Movement system functional
- Ready for animation content

### ⚠️ Current Limitation

**All animations are empty** - No keyframes, just placeholder clips. AnimationComponent prints warnings like:
```
AnimationComponent: No animation 'idle' for state 'Idle'
```
This is expected and will be resolved once bones are keyframed.

---

## Bone Structure Reference

### Primary Bones for Animation

```
Bone_Hip (root, position: 0, -50)
├── Bone_Torso (position: 0, -30)
│   ├── Bone_Head (position: 0, -35)
│   ├── Bone_Shoulder_R (position: 0, -25)
│   │   └── Bone_UpperArm_R (position: 0, 20)
│   │       └── Bone_LowerArm_R (position: 0, 30)
│   │           └── Bone_Hand_R (position: 0, 25)
│   └── Bone_Shoulder_L (position: 0, -20)
│       └── Bone_UpperArm_L → LowerArm_L → Hand_L
├── Bone_Thigh_R (position: 5, 0)
│   └── Bone_Shin_R (position: 0, 35)
│       └── Bone_Foot_R (position: 0, 35)
└── Bone_Thigh_L (position: -5, 0)
    └── Bone_Shin_L → Foot_L
```

### Key Bones to Animate

**Essential**:
- `Bone_Hip` - Root movement (bob, sway)
- `Bone_Torso` - Breathing, leaning
- `Bone_UpperArm_R/L` - Arm swing
- `Bone_Thigh_R/L` - Leg motion

**Secondary**:
- `Bone_LowerArm_R/L` - Elbow bend
- `Bone_Shin_R/L` - Knee bend
- `Bone_Head` - Subtle head tilt

**Can Skip Initially**:
- Hands and feet (use parent rotation)

---

## Animation Specifications

### 1. Idle Animation

**Duration**: 1.0s (looping)  
**Purpose**: Breathing, subtle movement when standing still

**Keyframes**:

| Time | Bone | Property | Value | Notes |
|------|------|----------|-------|-------|
| 0.0s | Bone_Torso | rotation | 0.0 | Neutral |
| 0.5s | Bone_Torso | rotation | 0.02 | ~1° tilt (breathing in) |
| 1.0s | Bone_Torso | rotation | 0.0 | Back to neutral |
| 0.0s | Bone_Hip | position.y | -50 | Neutral |
| 0.5s | Bone_Hip | position.y | -51 | Slight bob up |
| 1.0s | Bone_Hip | position.y | -50 | Back down |

**Optional**:
- Bone_Head: Slight rotation opposite to torso (-0.01 rad)
- Bone_UpperArm_R: Tiny sway (0.01 rad)

**Easing**: Sine In/Out for smooth breathing

---

### 2. Run Animation

**Duration**: 0.6s (looping)  
**Purpose**: Running motion with arm swing and leg cycle

**Keyframes** (Symmetric pattern):

| Time | Bone | Property | Value | Notes |
|------|------|----------|-------|-------|
| 0.0s | Bone_UpperArm_R | rotation | 0.3 | Arm forward |
| 0.3s | Bone_UpperArm_R | rotation | -0.3 | Arm backward |
| 0.6s | Bone_UpperArm_R | rotation | 0.3 | Loop |
| 0.0s | Bone_UpperArm_L | rotation | -0.3 | Opposite |
| 0.3s | Bone_UpperArm_L | rotation | 0.3 | Opposite |
| 0.6s | Bone_UpperArm_L | rotation | -0.3 | Loop |
| 0.0s | Bone_Thigh_R | rotation | -0.2 | Leg back |
| 0.3s | Bone_Thigh_R | rotation | 0.2 | Leg forward |
| 0.6s | Bone_Thigh_R | rotation | -0.2 | Loop |
| 0.0s | Bone_Thigh_L | rotation | 0.2 | Opposite |
| 0.3s | Bone_Thigh_L | rotation | -0.2 | Opposite |
| 0.6s | Bone_Thigh_L | rotation | 0.2 | Loop |

**Additional**:
- Bone_Hip: Bob up/down (position.y: -50 → -48 → -50)
- Bone_Torso: Slight lean forward (rotation: 0.05)
- Bone_LowerArm_R/L: Mirror upper arm but reduced (0.15 rad)

**Easing**: Linear or Cubic for snappy movement

---

### 3. Jump Animation

**Duration**: 0.4s (one-shot, no loop)  
**Purpose**: Launch into air

**Keyframes**:

| Time | Bone | Property | Value | Notes |
|------|------|----------|-------|-------|
| 0.0s | Bone_UpperArm_R | rotation | 0.0 | Neutral |
| 0.2s | Bone_UpperArm_R | rotation | -0.5 | Arms up |
| 0.4s | Bone_UpperArm_R | rotation | -0.3 | Slightly down |
| 0.0s | Bone_Thigh_R | rotation | 0.0 | Neutral |
| 0.2s | Bone_Thigh_R | rotation | -0.3 | Legs tucking |
| 0.0s | Bone_Torso | rotation | 0.0 | Neutral |
| 0.2s | Bone_Torso | rotation | -0.1 | Lean back |

**Motion**: Quick thrust, then hold

**Easing**: Ease Out (explosive start)

---

### 4. Fall Animation

**Duration**: 0.3s (looping)  
**Purpose**: Falling/airborne state

**Keyframes**:

| Time | Bone | Property | Value | Notes |
|------|------|----------|-------|-------|
| 0.0s | Bone_UpperArm_R | rotation | -0.2 | Slightly up |
| 0.15s | Bone_UpperArm_R | rotation | 0.0 | Neutral |
| 0.3s | Bone_UpperArm_R | rotation | -0.2 | Back up |
| 0.0s | Bone_Thigh_R | rotation | 0.1 | Legs down |
| 0.0s | Bone_Torso | rotation | 0.05 | Slight forward lean |

**Motion**: Gentle sway, spread limbs

**Easing**: Sine In/Out for floating feel

---

### 5. Wall Slide Animation

**Duration**: 0.8s (looping)  
**Purpose**: Sliding down wall

**Keyframes**:

| Time | Bone | Property | Value | Notes |
|------|------|----------|-------|-------|
| 0.0s | Bone_UpperArm_R | rotation | -0.4 | Arm against wall |
| 0.4s | Bone_UpperArm_R | rotation | -0.45 | Slight push |
| 0.8s | Bone_UpperArm_R | rotation | -0.4 | Back |
| 0.0s | Bone_Torso | rotation | 0.1 | Lean into wall |
| 0.0s | Bone_Thigh_R | rotation | 0.15 | Legs bracing |

**Motion**: Slow, tense

**Easing**: Sine In/Out

---

## Implementation Workflow

### Step 1: Open PlayerRig.tscn

1. Navigate to `res://entities/player/PlayerRig.tscn`
2. Double-click to open in Godot editor
3. Scene tree shows: PlayerRig → AnimationPlayer

### Step 2: Select AnimationPlayer

1. Click `AnimationPlayer` node in scene tree
2. **Animation panel** appears at bottom of editor
3. Shows existing animations: idle, run, jump, fall, wall_slide

### Step 3: Create Animation (Example: Idle)

1. **Select animation**: Click "idle" in Animation dropdown
2. **Set timeline length**: Should be 1.0s (already set)
3. **Enable looping**: Click loop icon (🔄) - should be blue/enabled

### Step 4: Add Keyframes

**For each bone you want to animate**:

1. **Navigate to bone** in Scene tree
2. **Move timeline** to 0.0s (start)
3. **Click key icon** (🔑) next to bone's rotation property in Inspector
4. **Move timeline** to next keyframe time (e.g., 0.5s)
5. **Adjust rotation** value in Inspector (e.g., rotation: 0.02)
6. **Click key icon** again
7. **Repeat** for all keyframe times

### Step 5: Test Animation

1. **Click play button** (▶️) in Animation panel
2. Watch character animate in 2D view
3. **Adjust keyframes** as needed by:
   - Selecting keyframe in timeline
   - Changing value in Inspector
   - Re-keying

### Step 6: Configure Easing

1. **Right-click** on keyframe in timeline
2. **Select "Easing"** or "Interpolation"
3. **Choose**: Linear, Cubic, Sine In/Out, etc.
4. **Test** to see smoothness

### Step 7: Repeat for All Animations

- idle (1.0s, looping)
- run (0.6s, looping)
- jump (0.4s, one-shot)
- fall (0.3s, looping)
- wall_slide (0.8s, looping)

---

## Technical Guidelines

### Rotation Values

**Units**: Radians  
**Conversion**: 1 radian ≈ 57.3 degrees

**Safe ranges**:
- Arms: -0.5 to 0.5 rad (±28°)
- Legs: -0.3 to 0.3 rad (±17°)
- Torso: -0.1 to 0.1 rad (±6°)
- Head: -0.05 to 0.05 rad (±3°)

**Start small**: Test with 0.1 rad, increase if needed

### Position Adjustments

**Bone_Hip only**:
- position.y: -50 (neutral)
- Range: -52 to -48 (subtle bob)

**Don't move other bone positions** - use rotation instead

### Animation Properties

**Loop vs One-Shot**:
- Idle, Run, Fall, Wall_slide: Looping ✅
- Jump: One-shot (no loop) ❌

**Timeline Scrubbing**:
- Use timeline slider to preview
- Red line = current playhead position

### Symmetry Tips

For run animation:
- Right arm forward = Left arm backward
- Right leg backward = Left leg forward
- Keyframe at 0.0s and 0.3s, mirror values

---

## Verification Checklist

### Per Animation

- [ ] Timeline length correct
- [ ] Looping enabled (if needed)
- [ ] At least 3 keyframes per animated bone
- [ ] Animation plays smoothly in editor
- [ ] No sudden jerks or pops
- [ ] Returns to start pose (for loops)

### Integration Test

1. **Save** PlayerRig.tscn
2. **Run MainLevel** (F5)
3. **Test each state**:
   - Stand still → idle plays
   - Walk (A/D) → run plays
   - Jump (Space) → jump plays
   - Airborne → fall plays
   - Wall slide → wall_slide plays
4. **No console errors** (animation warnings should be gone)

### Polish Check

- [ ] Animations feel alive, not robotic
- [ ] Transitions between animations are smooth
- [ ] Character maintains proper silhouette
- [ ] Saree and hair polygons follow body properly

---

## Common Issues & Solutions

### Issue: Bone rotates wrong direction

**Solution**: Use negative rotation value (e.g., -0.3 instead of 0.3)

### Issue: Polygon doesn't follow bone

**Cause**: Polygon's `skeleton` property not set  
**Solution**: Check Polygon2D → Inspector → skeleton = `NodePath("../..")`

### Issue: Animation doesn't loop smoothly

**Solution**: 
- Last keyframe should match first keyframe values
- Or set timeline to loop seamlessly

### Issue: Limbs look broken/stretched

**Cause**: Rotating wrong bone or too much rotation  
**Solution**: Reduce rotation value, check bone hierarchy

---

## Estimated Timeline

| Animation | Complexity | Time | Notes |
|-----------|-----------|------|-------|
| Idle | Low | 15-20 min | Simple breathing motion |
| Run | Medium | 30-40 min | Symmetric arm/leg cycle |
| Jump | Low | 15-20 min | Single action, few keyframes |
| Fall | Low | 15-20 min | Gentle floating motion |
| Wall_slide | Low | 15-20 min | Static tension pose |

**Total**: ~2-2.5 hours for all 5 animations

**For simpler approach**: Start with idle + run only (~1 hour), rest can be basic poses

---

## Next Steps for Agent

1. **Read this plan** thoroughly
2. **Open** [PlayerRig.tscn](file:///Users/mishal/Documents/teal-eyes/entities/player/PlayerRig.tscn) in Godot
3. **Reference** bone structure above
4. **Start with idle** (easiest, tests workflow)
5. **Follow keyframing steps** for each animation
6. **Test frequently** in AnimationPlayer preview
7. **Save and verify** in MainLevel
8. **Document** any deviations or improvements

---

## Reference Files

**Scene Files**:
- [PlayerRig.tscn](file:///Users/mishal/Documents/teal-eyes/entities/player/PlayerRig.tscn) - Work here
- [Player.tscn](file:///Users/mishal/Documents/teal-eyes/entities/player/Player.tscn) - Instance of rig

**Code Files**:
- [AnimationComponent.gd](file:///Users/mishal/Documents/teal-eyes/entities/player/AnimationComponent.gd) - Animation trigger logic
- [StateMachine.gd](file:///Users/mishal/Documents/teal-eyes/entities/player/StateMachine.gd) - State definitions

**Integration Documentation**:
- [integration_complete.md](file:///Users/mishal/.gemini/antigravity/brain/f161ac07-d32a-41c5-8d7b-490da01607f1/integration_complete.md) - Current system state
- [07_implementation_status.md](file:///Users/mishal/Documents/teal-eyes/_context/07_implementation_status.md) - Project status

---

**Status**: ✅ Ready for animation implementation. All prerequisites complete.
