# 04 Game Requirements

## 1. The Mechanic: Saree Lasso
- **Dynamic:** The Saree must trail behind the player physically (drag/gravity).
- **Function:** It acts as a grappling hook.
    - On `cast`: The tail end shoots toward the mouse/target.
    - On `hit`: It locks.
    - On `pull`: It exerts a force on the Player's `velocity`.

## 2. The Camera: "Gris" Snap
- Camera must not "smooth follow" continuously.
- It must **Lock** to the current Room's bounds.
- Transitions between rooms must be handled via `PhantomCamera` priorities or smooth dampening.

## 3. Art Constraints (For Devs)
- All collision shapes must match the visual "Ground" layer (Mid-ground).
- Saree texture must tile seamlessly.
- **Debanding** must be enabled in Project Settings to support watercolor gradients.