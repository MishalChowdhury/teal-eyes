#!/usr/bin/env python3
"""
Script to fix Hip bone position in all animations in PlayerRigv2-m.tscn
Replaces all instances of Vector2(407, XXX) with Vector2(0, XXX) in animation keyframes
"""

import re
import sys

def fix_hip_animations(file_path):
    """Fix all Hip position animations in the .tscn file"""
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Count occurrences before
    before_count = len(re.findall(r'Vector2\(407,', content))
    print(f"Found {before_count} instances of Vector2(407, ...)")
    
    # Replace Vector2(407, XXX) with Vector2(0, XXX)
    # This regex captures the Y value and preserves it
    fixed_content = re.sub(
        r'Vector2\(407,\s*(\d+(?:\.\d+)?)\)',
        r'Vector2(0, \1)',
        content
    )
    
    # Count occurrences after
    after_count = len(re.findall(r'Vector2\(407,', fixed_content))
    replaced_count = before_count - after_count
    
    print(f"Replaced {replaced_count} instances")
    print(f"Remaining instances: {after_count}")
    
    if replaced_count > 0:
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
    print("Hip Animation Position Fixer")
    print("=" * 60)
    print(f"Target file: {file_path}")
    print()
    
    try:
        success = fix_hip_animations(file_path)
        if success:
            print()
            print("🎉 All done! The Hip bone animations have been updated.")
            print("   Close and reopen PlayerRigv2-m.tscn in Godot to see the changes.")
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)
