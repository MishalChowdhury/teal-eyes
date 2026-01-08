#!/usr/bin/env python3
"""
Script to fix Hip bone Y position in all animations in PlayerRigv2-m.tscn
Replaces all instances of Vector2(0, 280) with Vector2(0, 0) in Hip animation keyframes
Also updates variations like 281, 282, 285, etc. to 1, 2, 5, etc.
"""

import re
import sys

def fix_hip_y_animations(file_path):
    """Fix all Hip Y position animations in the .tscn file"""
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Count occurrences before
    before_count = len(re.findall(r'Vector2\(0,\s*2[7-9]\d\)', content))
    print(f"Found {before_count} instances of Vector2(0, 27X-29X)")
    
    # Replace Vector2(0, 280+offset) with Vector2(0, 0+offset)
    # This preserves the animation offsets relative to the base position
    def replace_y(match):
        y_value = int(match.group(1))
        new_y = y_value - 280  # Subtract 280 from all Y values
        return f'Vector2(0, {new_y})'
    
    fixed_content = re.sub(
        r'Vector2\(0,\s*(\d+)\)',
        replace_y,
        content
    )
    
    # Count occurrences after
    after_count = len(re.findall(r'Vector2\(0,\s*2[7-9]\d\)', fixed_content))
    replaced_count = before_count - after_count
    
    print(f"Replaced {replaced_count} instances")
    print(f"Remaining instances with 27X-29X: {after_count}")
    
    if replaced_count > 0 or before_count > 0:
        # Write back to file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(fixed_content)
        print(f"✅ Successfully updated {file_path}")
        return True
    else:
        print("⚠️ No changes made")
        return False

if __name__ == "__main__":
    file_path = "/Users/mishal/Documents/teal-eyes/entities/player/PlayerRigv2-m.tscn"
    
    print("=" * 60)
    print("Hip Y Position Animation Fixer")
    print("=" * 60)
    print(f"Target file: {file_path}")
    print("Changing all Vector2(0, 280+X) to Vector2(0, 0+X)")
    print()
    
    try:
        success = fix_hip_y_animations(file_path)
        if success:
            print()
            print("🎉 All done! The Hip Y positions have been updated.")
            print("   Close and reopen PlayerRigv2-m.tscn in Godot.")
            print("   The feet should now be at Y=0!")
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)
