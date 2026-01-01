#!/bin/bash
# Strip all polygon and UV coordinate data from PlayerRig.tscn
# Keeps the Polygon2D nodes and setup, just removes the bad coordinates

sed -i.bak_before_clean '
/^polygon = PackedVector2Array/ d
/^uv = PackedVector2Array/ d
' entities/player/PlayerRig.tscn

echo "✅ Polygon coordinates cleared from PlayerRig.tscn"
echo "📦 Backup: PlayerRig.tscn.bak_before_clean"
echo ""
echo "Next steps:"
echo "1. Open PlayerRig.tscn in Godot"
echo "2. Scale ReferenceFull sprite to 0.24"
echo "3. Re-create polygon outlines (14 parts)"
