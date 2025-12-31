extends Node

## Global Game Settings
var game_paused: bool = false

## Project Constants
const PIXELS_PER_METER: int = 100
const TARGET_PHYSICS_FPS: int = 60

## Utility Functions
func meters_to_pixels(meters: float) -> float:
	return meters * PIXELS_PER_METER

func pixels_to_meters(pixels: float) -> float:
	return pixels / float(PIXELS_PER_METER)
