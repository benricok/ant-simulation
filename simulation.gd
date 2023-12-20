extends Button

@export var ant_count: int = 500
@export var ant_max_speed: float = 60.0
@export var ant_colony_radius: int = 200
@export var ant_colony_offset: int = 10
@export var ant_steer_strength: float = 3.0
@export var ant_wander_strength: float = 3.0

@export var patches_of_food: int = 3
@export var food_multiplier: int = 43
@export var food_radius: int = 120
@export var food_patch_offset: int = 10

@onready var viewport_size: Vector2 = get_viewport_rect().size
var target: Vector2
var ants = Array()
var food = Array()
var score: int = 0

var _ant = preload("res://ant.tscn")
var _bite = preload("res://bite.tscn")
@onready var _background = $"../Background"
@onready var _home = $"../Home"
@onready var _homesprite = $"../Home/Homesprite"
@onready var _homearea = $"../Home/CollisionHome"
@onready var _score = $"../Score"

var current_process_group: int = 0
@export var max_process_groups: int = 3

func new_direction() -> Vector2:
	var new_dir: = Vector2()
	new_dir.x = randf_range(-1, 1)
	new_dir.y = randf_range(-1, 1)
	return new_dir.normalized()

func _pressed():
	var rng = RandomNumberGenerator.new()
	viewport_size = get_viewport_rect().size
	print(viewport_size)
	
	for ant in ants:
		ant.queue_free()
	for bite in food:
		bite.queue_free()
	
	ants.clear()
	food.clear()
	_background.trail_searching.clear()
	_background.trail_found.clear()
	_score.text = "0"
	score = 0
	
	# Generate new colony location
	var colony_center = Vector2(rng.randi_range(ant_colony_offset, viewport_size.x - ant_colony_offset),
							  	rng.randi_range(ant_colony_offset, viewport_size.y - ant_colony_offset))
	
	# Update colony nodes
	_home.position = colony_center
	_homearea.position = colony_center
	_homesprite.visible = true
	
	for i in range(ant_count):
		var new_ant = _ant.instantiate()
		
		var angle = rng.randi_range(0, 360)
		new_ant.position = colony_center + Vector2(cos(angle), sin(angle)) * rng.randi_range(0, ant_colony_radius)

		new_ant.max_speed = ant_max_speed
		new_ant.steer_strength = ant_steer_strength
		new_ant.wander_strength = ant_wander_strength
		new_ant.desired_direction = new_direction()
		new_ant.viewport_size = viewport_size
		new_ant.colony_center = colony_center
		new_ant.process_group = randi_range(1, max_process_groups)
		ants.append(new_ant)
		add_child(new_ant)
	
	for i in range(patches_of_food):
		var center = Vector2(rng.randi_range(food_patch_offset + food_radius, viewport_size.x - food_patch_offset - food_radius),
							 rng.randi_range(food_patch_offset + food_radius, viewport_size.y - food_patch_offset - food_radius))
		
		for j in range(rng.randi_range(8,12) * food_multiplier):
			var new_bite = _bite.instantiate()
			
			var angle = rng.randi_range(0, 360)
			new_bite.position = center + Vector2(cos(angle), sin(angle)) * rng.randi_range(0, food_radius)
		
			food.append(new_bite)
			add_child(new_bite)

func _process(delta):
	current_process_group += 1
	if current_process_group >= max_process_groups:
		current_process_group = 1

func inc_score():
	score += 1
	_score.text = str(score)
