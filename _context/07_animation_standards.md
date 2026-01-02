# 2D Animation Standards Reference

Industry benchmarks and property examples for skeletal animation, with comparisons to GRIS and NEVA.

---

## Animation Frame Count Standards

### Industry Standard Frame Counts (at 60 FPS)

| Animation Type | Minimum (Prototype) | Standard (Shipped) | Polished (GRIS/NEVA) | GRIS/NEVA Reference |
|----------------|---------------------|-------------------|---------------------|---------------------|
| **Idle** | 60 frames (1s) | 180 frames (3s) | 240-360 frames (4-6s) | GRIS: ~240 frames, subtle breathing |
| **Walk** | 30 frames (0.5s) | 60 frames (1.0s) | 72-84 frames (1.2-1.4s) | GRIS: ~60 frames, floaty, contemplative |
| **Run** | 24 frames (0.4s) | 36 frames (0.6s) | 48-60 frames (0.8-1.0s) | GRIS: ~40 frames, fluid, graceful |
| **Jump (Up)** | 18 frames (0.3s) | 30 frames (0.5s) | 36-42 frames (0.6-0.7s) | GRIS: ~36 frames, hang time |
| **Fall/Airborne** | 12 frames (loop) | 36 frames (loop) | 60-72 frames (loop) | GRIS: ~60 frames, cloth flow |
| **Land** | 12 frames (0.2s) | 18 frames (0.3s) | 24-30 frames (0.4-0.5s) | GRIS: ~24 frames, soft impact |
| **Turn Around** | 12 frames (0.2s) | 18 frames (0.3s) | 24-30 frames (0.4-0.5s) | NEVA: ~24 frames, graceful pivot |
| **Wall Slide** | 18 frames (0.3s) | 36 frames (0.6s) | 60 frames (1.0s) | GRIS: Cloth draping emphasis |

### Frame Count at Different Framerates

| Animation | 12 FPS | 24 FPS | 30 FPS | 60 FPS |
|-----------|--------|--------|--------|--------|
| **Idle** | 24 frames (2s) | 48 frames (2s) | 60 frames (2s) | 120 frames (2s) |
| **Walk** | 12 frames (1.0s) | 24 frames (1.0s) | 30 frames (1.0s) | 60 frames (1.0s) |
| **Run** | 8 frames (0.6s) | 12 frames (0.6s) | 18 frames (0.6s) | 36 frames (0.6s) |

> **Note:** Most 2D games animate at **24-30 FPS** even if game runs at 60 FPS for performance and stylistic reasons.

---

## Animation Timing Standards

### Duration Benchmarks (in seconds)

| Animation Type | Minimal | Standard (GRIS/NEVA) | Extended | Your Target (GRIS/NEVA Style) |
|----------------|---------|---------------------|----------|-------------------------------|
| **Idle Loop** | 2-3s | 3-4s | 5-6s | **4s** (Slow, contemplative breathing) |
| **Walk Cycle** | 0.8s | 1.0-1.2s | 1.4-1.6s | **1.2s** (Floaty, graceful movement) |
| **Run Cycle** | 0.5s | 0.6-0.8s | 1.0s | **0.8s** (Fluid, not rushed) |
| **Jump Ascent** | 0.3s | 0.5-0.6s | 0.7-0.8s | **0.6s** (Extended hang time) |
| **Fall Start** | 0.15s | 0.2-0.3s | 0.4s | **0.3s** (Gentle transition) |
| **Landing** | 0.2s | 0.3-0.4s | 0.5s | **0.4s** (Soft, absorbed impact) |
| **Transition (Idle→Walk)** | 0.2s | 0.3-0.4s | 0.5-0.6s | **0.4s** (Smooth, flowing blend) |

### GRIS-Style "Floaty" Timing (PRIMARY REFERENCE)
- **Everything 30-50% slower** than typical platformers
- **Extended hang time** on jumps (0.6-0.8s ascent)
- **Cloth/cape/saree** animations 2-3x longer (overlap & follow-through)
- **Idle breathing** very subtle, 4-6s cycles
- **Weight feels ethereal** - less grounded, more dreamlike
- **Ease-in-out curves** on almost everything for smoothness

### NEVA-Style Timing (SECONDARY REFERENCE)
- **Similar to GRIS** but slightly more responsive (10-15% faster)
- **Maintains grace** while allowing better gameplay feel  
- **Emotional weight** in animations, not physical weight
- **Creature companion** has independent, flowing animation
- **Environmental interactions** are slow and reverent

---

## Property Value Examples

### Bone Rotation Ranges (in degrees)

#### **Arm Animations**

| Bone | Idle | Walk (Forward Swing) | Walk (Back Swing) | Run (Extreme) | Jump | Notes |
|------|------|---------------------|------------------|---------------|------|-------|
| **Shoulder** | 0° | +15° | -20° | ±30° | +20° | Root of arm chain |
| **Upper Arm** | -10° | +30° | -45° | ±60° | +45° | Main swing from shoulder |
| **Forearm** | +5° | +15° | +10° | +25° | +30° | Subtle bend, follows upper |
| **Hand** | 0° | ±5° | ±5° | ±10° | ±15° | Minimal, follows wrist |

#### **Leg Animations**

| Bone | Idle | Walk (Forward) | Walk (Back) | Run (Forward) | Run (Back) | Notes |
|------|------|---------------|-------------|--------------|-----------|-------|
| **Hip** | +5° | +20° | -15° | +35° | -25° | Drives leg motion |
| **Thigh** | 0° | +45° | -30° | +60° | -45° | Main leg swing |
| **Shin** | -5° | -15° | -45° | -20° | -60° | Knee bend (negative = back) |
| **Foot** | 0° | +10° | -15° | +15° | -20° | Toe-off/heel-strike |

#### **Torso/Spine Animations**

| Bone | Idle | Walk | Run | Jump (Up) | Fall | Notes |
|------|------|------|-----|-----------|------|-------|
| **Hip (Root)** | Y: 0px | Y: ±3px | Y: ±8px | Y: -15px | Y: +5px | Vertical bobbing |
| **Spine** | +2° | ±3° | ±5° | -10° | +15° | Counterbalance rotation |
| **Head** | 0° | ±2° | ±4° | -5° | +8° | Follows spine, subtle |

### Position/Translation Examples

| Animation | Root Position Offset | Purpose |
|-----------|---------------------|---------|
| **Walk Cycle** | X: 0-20px forward per cycle | Optional, creates "sliding" feel |
| **Idle Breathing** | Y: ±1-2px | Subtle vertical bob |
| **Landing Squash** | Y: -5px (down), then +2px | Impact compression |
| **Jump Anticipation** | Y: +3px (crouch), then launch | Pre-jump squat |

### Scale Values (Squash & Stretch)

| Animation Moment | Scale X | Scale Y | Notes |
|------------------|---------|---------|-------|
| **Idle (neutral)** | 1.0 | 1.0 | No deformation |
| **Landing Impact** | 1.15 | 0.85 | Squash on impact |
| **Jump Stretch** | 0.95 | 1.05 | Stretch at apex |
| **Run (peak bob)** | 1.03 | 0.97 | Subtle compression |
| **Anticipation** | 1.05 | 0.95 | Pre-action squash |

> **Important:** Use squash/stretch sparingly for 2D skeletal rigs - usually only on root bone or specific body parts.

---

## Implementation Priority Guide

### Phase 1: Prototype/MVP (Now) 🎯
**Goal:** Get functional gameplay first, art polish later

| Animation | Frame Count | Duration | Priority | Notes |
|-----------|-------------|----------|----------|-------|
| **Idle** | 60 frames | 1.0s | HIGH | Gentle breathing, minimal movement |
| **Walk** | 30 frames | 0.5s | HIGH | 6-pose cycle, simplified timing |
| **Jump** | 18 frames | 0.3s | HIGH | 3 poses with extended timing |
| **Fall** | 12 frames | Loop | HIGH | Subtle limb sway |
| **Land** | 12 frames | 0.2s | MEDIUM | Soft landing, gentle impact |

**Rotation Ranges (Prototype):**
- Simplified ±20-30° ranges for all bones
- Focus on clear silhouette reads
- Skip secondary motion (fingers, hair, cloth details)

**Property Targets:**
- Rotation: ±20° average
- Position: Minimal (0-5px)
- Scale: None (1.0 uniform)

---

### Phase 2: Shipped/Production (Later) 🚀
**Goal:** Professional quality, smooth transitions

| Animation | Frame Count | Duration | Priority | Notes |
|-----------|-------------|----------|----------|-------|
| **Idle** | 180 frames | 3s | HIGH | Slow breathing, subtle weight shifts |
| **Walk** | 60 frames | 1.0s | HIGH | 12-pose cycle, floaty feel |
| **Run** | 36 frames | 0.6s | MEDIUM | Graceful, flowing motion |
| **Jump (Full)** | 30 frames | 0.5s | HIGH | Extended hang, anticipation → apex |
| **Fall** | 36 frames | Loop | MEDIUM | Cloth flow, gentle limb sway |
| **Land** | 18 frames | 0.3s | MEDIUM | Soft impact → settle |
| **Transitions** | 18-24 frames | 0.3-0.4s | MEDIUM | Smooth, gentle blends |

**Rotation Ranges (Production):**
- Use full ranges from tables above
- Add secondary motion (forearms, hands follow)
- Include overlap & follow-through

**Property Targets:**
- Rotation: Full ranges (±45-60° extremes)
- Position: Y-bobbing (±5-10px)
- Scale: Subtle squash/stretch (±5-10%)

---

### Phase 3: Polish/AAA (Final Polish) ✨
**Goal:** GRIS/NEVA level quality - floaty, emotional, artistic

| Animation | Frame Count | Duration | Priority | Notes |
|-----------|-------------|----------|----------|-------|
| **Idle** | 240-360 frames | 4-6s | MEDIUM | Multiple variants, breathing, micro-movements |
| **Walk** | 72-84 frames | 1.2-1.4s | HIGH | Extended, contemplative movement |
| **Run** | 48-60 frames | 0.8-1.0s | HIGH | Graceful flow, cape/saree animation |
| **Jump** | 36-42 frames | 0.6-0.7s | HIGH | Extended hang time, cloth flutter |
| **Wall Slide** | 60-72 frames | Loop | HIGH | Saree draping, slow descent |
| **Double Jump** | 30-36 frames | 0.5-0.6s | LOW | Ethereal, floaty second jump |
| **Turn Around** | 24-30 frames | 0.4-0.5s | MEDIUM | Graceful pivot with inertia |
| **Ledge Grab** | 42-48 frames | 0.7-0.8s | LOW | Slow reach → gentle pull-up |

**Advanced Techniques:**
- **Additive layers** (breathing on top of all animations)
- **Procedural blend** (head look-at, IK for hands/feet)
- **Particle integration** (dust on land, footsteps)
- **Cloth simulation** overlay (saree system you have!)
- **Camera shake** triggers from animation events

---

## Comparison to Referenced Games

### GRIS Animation Characteristics (PRIMARY INSPIRATION)
- **Frame count:** High (60-72 frames for walk cycles)
- **Timing:** Slower, floaty, dreamlike (1.0-1.4s walk cycles)
- **Style:** Heavy emphasis on secondary motion, cloth, particles, environmental effects
- **Easing:** Almost exclusively ease-in-out curves for ethereal smoothness
- **Movement philosophy:** Emotion over physics, grace over realism
- **Unique traits:**
  - Cloth/cape has dedicated bone chain (8-12 bones) with layered animation
  - Character physically "grows" during emotional story beats
  - Environmental reactions deeply integrated (wind, water, gravity shifts)
  - Hang time on jumps feels suspended, defying physics
  - Color and form shifts are part of animation language

**Core GRIS Principles:**
- Every movement tells an emotional story
- Physics are suggestions, not rules
- Beauty and flow over snappiness
- Silence and stillness are powerful
- Layered secondary motion (cloth, hair, particles)

### NEVA Animation Characteristics (SECONDARY INSPIRATION)
- **Frame count:** High (48-60 frames for walk cycles)
- **Timing:** Similar to GRIS but ~15% faster for slight gameplay responsiveness
- **Style:** Graceful with subtle weight, companion creature animations
- **Easing:** Ease-in-out with occasional ease-out for impacts
- **Movement philosophy:** Emotional connection through motion
- **Unique traits:**
  - Companion creature has independent, expressive animation cycles
  - Human-creature synchronization in key moments
  - More grounded than GRIS but still dreamlike
  - Gentle combat animations that feel reluctant
  - Environmental storytelling through reactive animations

**Core NEVA Principles:**
- Relationship expressed through animation timing
- Slightly more responsive than GRIS while maintaining grace
- Weight exists but doesn't dominate
- Animations support narrative emotional beats

### Your Game (Teal Eyes) - GRIS/NEVA Aesthetic ONLY
**Pure GRIS/NEVA approach:**
- **ALL gameplay:** Floaty, contemplative (1.0-1.2s walk cycles minimum)
- **Saree/Cloth:** Extensive secondary motion, key visual identity
- **Jump/Movement:** Extended hang time, ethereal feel
- **Idle states:** Long, subtle, meditative (4-6s cycles)
- **Transitions:** Always smooth, never snappy or abrupt
- **Philosophy:** Cinematic beauty and emotional resonance over "tight controls"
- **Player feeling:** Moving through a dream/watercolor painting

**NO Venba/snappy platformer timing** - this game prioritizes:
- Visual poetry over gameplay precision
- Emotional journey over mechanical challenge  
- Flowing grace over responsive controls
- Artistic expression over traditional game feel

---

## Quick Reference: What to Implement When

### ✅ **Do Now (Phase 1)**
- [ ] Idle: 60 frames, 1s, gentle breathing
- [ ] Walk: 30 frames, 0.5s, 6-pose cycle
- [ ] Jump: 12 frames, 0.2s, 3 poses
- [ ] Fall: 6 frames, held pose
- [ ] Land: 6 frames, 0.1s, quick squash
- **Rotation ranges:** ±20° average
- **No squash/stretch yet**
- **No transitions yet**

### ⏸️ **Do Later (Phase 2)**
- [ ] Extend Idle to 180 frames (3s)
- [ ] Extend Walk to 60 frames (1.0s)
- [ ] Add Run animation (36 frames, 0.6s)
- [ ] Extend Jump/Fall/Land
- [ ] Add 12-frame transitions between states
- **Full rotation ranges:** ±30-60°
- **Add Y-position bobbing:** ±5-10px
- **Subtle squash/stretch:** ±5%

### 🎨 **Polish Eventually (Phase 3)**
- [ ] Multiple idle variants
- [ ] Turn-around animation
- [ ] Wall slide animation
- [ ] Ledge grab/climb
- [ ] Additive breathing layer
- [ ] Procedural head look-at
- [ ] Particle integration
- [ ] Camera shake events
- **Advanced cloth sim** integration
- **IK constraints** for feet/hands

---

## Example Animation Property Sheet

### Example: Walk Cycle (GRIS/NEVA Style)

**Duration:** 1.2s (72 frames at 60 FPS)
**Loop:** Yes
**Poses:** 12 (6 main + 6 in-betweens)
**Easing:** Ease-in-out on all keyframes

| Frame | Time | Pose Name | Left Leg (Thigh) | Right Leg (Thigh) | Left Arm | Right Arm | Notes |
|-------|------|-----------|------------------|------------------|----------|-----------|-------|
| 0 | 0.0s | Contact L | +45° | -30° | -30° | +20° | Left foot forward |
| 5 | 0.08s | Down L | +30° | -20° | -20° | +15° | Weight shift |
| 10 | 0.17s | Passing | +10° | +10° | -5° | -5° | Center, high point |
| 15 | 0.25s | Up L | -10° | +25° | +5° | -15° | Lifting off |
| 20 | 0.33s | Contact R | -30° | +45° | +20° | -30° | Right foot forward |
| 25 | 0.42s | Down R | -20° | +30° | +15° | -20° | Weight shift |
| 30 | 0.50s | Passing | +10° | +10° | -5° | -5° | Center, high point |
| 35 | 0.58s | Up R | +25° | -10° | -15° | +5° | Lifting off |
| 40 | 0.67s | Contact L | +45° | -30° | -30° | +20° | **Loop back to 0** |

**Additional Properties:**
- **Hip Y-Position:** Slow sine wave, ±8-10px, extended peaks at passing poses
- **Spine Rotation:** ±4-5°, gentle counter-rotation
- **Head Rotation:** ±3°, lags behind spine with delay
- **Interpolation:** All ease-in-out for floaty feel
- **Hang time:** Passing poses held ~20% longer

---

## Ready to Animate! 🎬

Use this reference to:
- ✅ **Set realistic frame count goals** for each animation phase
- ✅ **Know what rotation ranges** to target for bones
- ✅ **Prioritize work** (prototype → production → polish)
- ✅ **Compare to GRIS/NEVA standards** (floaty, contemplative)
- ✅ **Make informed decisions** on timing and easing

Start with **Phase 1** and iterate! 💪
