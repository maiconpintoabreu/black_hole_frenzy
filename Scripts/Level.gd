extends Node2D
class_name Level
var score:float = 0
var gravity_direction:Vector2 = Vector2.ZERO
@export var gravity_pull = 0.2
@onready var character_body_2d: RigidBody2D = $CharacterBody2D
@onready var black_hole: TextureRect = $CanvasLayer2/BlackHole
@onready var game_over_panel: Panel = $CanvasLayer/GameOverPanel
@onready var start_menu_panel: Panel = $CanvasLayer/StartMenuPanel
@onready var score_label: Label = $CanvasLayer/GameUI/Score
@onready var game_ui: Control = $CanvasLayer/GameUI
@onready var fuel_spawner_timer: Timer = $FuelSpawnerTimer
@onready var fuel_spawner: Node2D = $FuelSpawner
var character_by_black_hole:Vector2
var character_distance_black_hole:float
@onready var area_2d: Area2D = $CanvasLayer2/BlackHole/Area2D
@onready var mobile_ui: Control = $CanvasLayer/GameUI/MobileUI
@onready var pause_panel: Panel = $CanvasLayer/PausePanel


var level:int = 1
var max_level:int = 10

var is_dead:bool = false
var is_on_menu:bool = false

func _ready() -> void:
	is_on_menu = true
	start_menu_panel.show()
	game_ui.hide()
	pause_panel.hide()
	fuel_spawner_timer.stop()

func _physics_process(_delta: float) -> void:
	if is_on_menu: return
	if is_dead: return
	character_by_black_hole = character_body_2d.global_position.direction_to(area_2d.global_position)
	character_distance_black_hole = character_body_2d.global_position.distance_to(area_2d.global_position)
	gravity_direction = character_by_black_hole.normalized()
	character_body_2d.apply_force(gravity_direction*(gravity_pull*(level)),gravity_direction)

func _on_start_button_pressed() -> void:
	get_tree().paused = false
	character_body_2d.reset()
	is_on_menu = false
	is_dead = false
	start_menu_panel.hide()
	game_over_panel.hide()
	pause_panel.hide()
	score = 0
	game_ui.show()
	for fuel in fuel_spawner.get_children():
		fuel.queue_free()
	fuel_spawner_timer.start()
func game_over()->void:
	is_dead = true
	game_ui.hide()
	character_body_2d.die()
	game_over_panel.show()
	fuel_spawner_timer.stop()
	for fuel in fuel_spawner.get_children():
		fuel.queue_free()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		game_over()
func round_place(num:float,places:int)->float:
	return (round(num*pow(10,places))/pow(10,places))
	
func _on_level_timer_timeout() -> void:
	if is_on_menu: return
	if is_dead: return
	var add_score:float = (50/character_distance_black_hole)*level
	score = score+add_score
	score_label.text = str("Score: ",round_place(score,1)," +",round_place(add_score,1))
	if fmod(score, 20*level) == 0.0:
		level = clamp(level+1,1,max_level)

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		mobile_ui.show()
	else:
		mobile_ui.hide()


func _on_pause_button_pressed() -> void:
	pause_panel.show()
	get_tree().paused = true


func _on_continue_button_pressed() -> void:
	pause_panel.hide()
	get_tree().paused = false
