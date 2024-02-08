extends Node2D
var score:float = 0
var gravity_direction:Vector2 = Vector2.ZERO
@export var gravity_pull = 60000
@onready var character_body_2d: RigidBody2D = $CharacterBody2D
@onready var black_hole: ColorRect = $CanvasLayer2/BlackHole
@onready var game_over_panel: Panel = $CanvasLayer/GameOverPanel
@onready var start_menu_panel: Panel = $CanvasLayer/StartMenuPanel
@onready var score_label: Label = $CanvasLayer/GameUI/Score
@onready var game_ui: Control = $CanvasLayer/GameUI
@onready var fuel_spawner_timer: Timer = $FuelSpawnerTimer
@onready var fuel_spawner: Node2D = $FuelSpawner


var level:int = 1
var max_level:int = 10

var is_dead:bool = false
var is_on_menu:bool = false

func _ready() -> void:
	is_on_menu = true
	start_menu_panel.show()
	game_ui.hide()
	fuel_spawner_timer.stop()

func _physics_process(_delta: float) -> void:
	if is_on_menu: return
	if is_dead: return
	gravity_direction = character_body_2d.global_position.direction_to(get_viewport_rect().get_center()).normalized()
	character_body_2d.apply_force(gravity_direction*gravity_pull,gravity_direction)

func _on_start_button_pressed() -> void:
	character_body_2d.reset()
	is_on_menu = false
	is_dead = false
	start_menu_panel.hide()
	game_over_panel.hide()
	score = 0
	game_ui.show()
	for fuel in fuel_spawner.get_children():
		fuel.queue_free()
	fuel_spawner_timer.start()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		is_dead = true
		character_body_2d.die()
		game_over_panel.show()
		fuel_spawner_timer.stop()
		for fuel in fuel_spawner.get_children():
			fuel.queue_free()

func _on_level_timer_timeout() -> void:
	if is_on_menu: return
	if is_dead: return
	score = score+1
	score_label.text = str("Score: ",score)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
