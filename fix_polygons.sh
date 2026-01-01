#!/bin/bash
# Reset all Polygon2D position and scale transforms in PlayerRig.tscn

# This script removes position and scale properties from Polygon2D nodes
# so they default to (0,0) and (1,1) relative to their parent bones

sed -i.bak2 '
/\[node name="Part_/ , /^$/ {
    /^position = Vector2(-[0-9]/ d
    /^scale = Vector2(0\.[0-9]/ d
}
' entities/player/PlayerRig.tscn

echo "Polygon2D transforms reset. Reload the scene in Godot."
