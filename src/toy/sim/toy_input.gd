class_name ToyInput
extends RefCounted
## One frame of player intent, already read from InputMap actions (or made
## by ScriptedPlayer). Aim is in field units: +y is up.

var move: float = 0.0
var climb: float = 0.0
var jump_pressed: bool = false
var fire_held: bool = false
var melee_pressed: bool = false
var reload_pressed: bool = false
var swap_pressed: bool = false
var aim: Vector2 = Vector2.RIGHT
