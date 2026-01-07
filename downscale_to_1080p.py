#!/usr/bin/env python3
"""
Downscale 4K backgrounds to 1920×1080 for GRIS-style setup
"""

from PIL import Image
import os

# Paths
project_root = os.path.dirname(os.path.abspath(__file__))
bg_dir = os.path.join(project_root, "assets/art/environment/backgrounds")

# Files to downscale
files_to_process = [
    ("far_background_4k.png", "far_background_1080p.png"),
    ("far_floor_4k.png", "far_floor_1080p.png")
]

target_size = (1920, 1080)

print("🎨 Downscaling backgrounds to 1920×1080 (GRIS standard)...\n")

for input_file, output_file in files_to_process:
    input_path = os.path.join(bg_dir, input_file)
    output_path = os.path.join(bg_dir, output_file)
    
    if not os.path.exists(input_path):
        print(f"⚠️  Skipping {input_file} (not found)")
        continue
    
    # Open and resize
    img = Image.open(input_path)
    original_size = img.size
    
    # High-quality downscaling
    img_resized = img.resize(target_size, Image.Resampling.LANCZOS)
    
    # Save
    img_resized.save(output_path, "PNG", optimize=True)
    
    # Get file sizes
    original_mb = os.path.getsize(input_path) / (1024 * 1024)
    new_mb = os.path.getsize(output_path) / (1024 * 1024)
    
    print(f"✅ {input_file}")
    print(f"   {original_size[0]}×{original_size[1]} ({original_mb:.1f}MB) → {target_size[0]}×{target_size[1]} ({new_mb:.1f}MB)")
    print(f"   Saved as: {output_file}\n")

print("🎉 Done! New 1080p backgrounds created.")
print("\n📝 Next steps:")
print("1. Update RoomFar_Optimized.tscn to use the new _1080p.png files")
print("2. Change sprite region_rect to Rect2(0, 0, 1920, 1080)")
print("3. Set camera zoom to 1.0")
