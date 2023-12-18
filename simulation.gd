extends Button

var ant = preload("res://ant.tscn")
var bite = preload("res://bite.tscn")

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

var viewport_size: Vector2
var target: Vector2
var ants = Array()
var food = Array()

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
	
	var colony_center = Vector2(rng.randi_range(ant_colony_offset, viewport_size.x - ant_colony_offset),
							  	rng.randi_range(ant_colony_offset, viewport_size.y - ant_colony_offset))
	
	for i in range(ant_count):
		var new_ant = ant.instantiate()
		
		var angle = rng.randi_range(0, 360)
		new_ant.position = colony_center + Vector2(cos(angle), sin(angle)) * rng.randi_range(0, ant_colony_radius)
		#new_ant.position = Vector2(rng.randi_range(ant_colony_offset, viewport_size.x - ant_colony_offset),
								  #rng.randi_range(ant_colony_offset, viewport_size.y - ant_colony_offset))
		new_ant.max_speed = ant_max_speed
		new_ant.steer_strength = ant_steer_strength
		new_ant.wander_strength = ant_wander_strength
		ants.append(new_ant)
		add_child(new_ant)
	
	for i in range(patches_of_food):
		var center = Vector2(rng.randi_range(food_patch_offset + food_radius, viewport_size.x - food_patch_offset - food_radius),
							  rng.randi_range(food_patch_offset + food_radius, viewport_size.y - food_patch_offset - food_radius))
		
		for j in range(rng.randi_range(8,12) * food_multiplier):
			var new_bite = bite.instantiate()
			
			var angle = rng.randi_range(0, 360)
			new_bite.position = center + Vector2(cos(angle), sin(angle)) * rng.randi_range(0, food_radius)
		
			food.append(new_bite)
			add_child(new_bite)
