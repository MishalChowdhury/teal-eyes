#!/usr/bin/env python3
"""
Fix polygon coordinates in PlayerRig.tscn
Transforms texture-space coordinates to bone-local space
"""

import re
import sys

# Expected offset based on visual debug (red cross vs character position)
# From screenshot: skeleton is at ~40px, polygons are at ~280px = 240px offset
# Also need Y offset: polygon Y coords are ~100-300, should be around -50 to +50
OFFSET_X = -380  # Shift polygons left
OFFSET_Y = -200  # Shift polygons up

def transform_polygon_array(match):
    """Transform PackedVector2Array coordinates"""
    array_content = match.group(1)
    
    # Split into individual number pairs
    numbers = re.findall(r'-?\d+\.?\d*', array_content)
    
    # Transform each x,y pair
    transformed = []
    for i in range(0, len(numbers), 2):
        x = float(numbers[i])
        y = float(numbers[i+1])
        
        # Apply offset
        new_x = x + OFFSET_X
        new_y = y + OFFSET_Y
        
        transformed.append(f"{new_x}, {new_y}")
    
    return f"PackedVector2Array({', '.join(transformed)})"

def fix_coordinates(content):
    """Fix all polygon and UV coordinates"""
    # Fix polygon arrays
    content = re.sub(
        r'PackedVector2Array\(([^)]+)\)',
        transform_polygon_array,
        content
    )
    
    return content

if __name__ == "__main__":
    input_file = sys.argv[1] if len(sys.argv) > 1 else "entities/player/PlayerRig.tscn"
    
    with open(input_file, 'r') as f:
        content = f.read()
    
    fixed_content = fix_coordinates(content)
    
    # Backup original
    with open(input_file + '.bak_coords', 'w') as f:
        f.write(content)
    
    # Write fixed version
    with open(input_file, 'w') as f:
        f.write(fixed_content)
    
    print(f"✅ Fixed coordinates in {input_file}")
    print(f"📦 Backup saved to {input_file}.bak_coords")
    print(f"🔧 Applied offset: X={OFFSET_X}, Y={OFFSET_Y}")
