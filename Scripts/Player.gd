extends RigidBody2D
class_name Player
@onready var screen_size = get_viewport_rect().size
@onready var left_turbune: AnimatedSprite2D = $LeftTurbune
@onready var right_turbune: AnimatedSprite2D = $RightTurbune
@onready var power_bar: ProgressBar = $"../CanvasLayer/GameUI/PowerBar"

@export var engine_power:float = 120000
@export var spin_power:float = 250000
@export var power_drain:float = 10
var thrust := Vector2.ZERO
var rotation_dir:float = 0
var teleport_pos:Vector2 = Vector2.ZERO

var start_position:Vector2
var start_rotation:float

var is_dead:bool = false

func reset()->void:
	teleport_pos = start_position
	rotation = start_rotation
	freeze = false
	is_dead = false
	power_bar.value = power_bar.max_value

func die()->void:
	call_deferred("die_deferred")

func die_deferred()->void:
	freeze = true
	is_dead = true
func refill_fuel(fuel:float):
	power_bar.value = power_bar.value+fuel
func _ready()->void:
	start_position = global_position
	start_rotation = global_rotation

func get_input()->void:
	thrust = Vector2.ZERO
	rotation_dir = Input.get_axis("ui_left", "ui_right")
	if Input.is_action_pressed("ui_up"):
		thrust = transform.x * engine_power
		left_turbune.show()
		right_turbune.show()
	else:
		left_turbune.hide()
		right_turbune.hide()
		if rotation_dir < 0:
			right_turbune.show()
		elif rotation_dir > 0:
			left_turbune.show()
		
func _physics_process(delta:float)->void:
	if is_dead: return
	if power_bar.value < 1: 
		left_turbune.hide()
		right_turbune.hide()
		constant_force = Vector2.ZERO
		constant_torque = 0.0
		return
	get_input()
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
	if left_turbune.visible and right_turbune.visible:
		power_bar.value = power_bar.value - power_drain * delta

func _integrate_forces(state: PhysicsDirectBodyState2D)->void:
	if teleport_pos != Vector2.ZERO:
		state.transform.origin = teleport_pos
		teleport_pos = Vector2.ZERO
	var xform = state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screen_size.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screen_size.y)
	state.transform = xform
