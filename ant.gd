extends CharacterBody2D

var max_speed: float = 10.0
var steer_strength: float = 2.0
var wander_strength: float = 1.0
var bite_pickup_radius: float = 5.0
var pheromone_interval: float = 0.9

var desired_direction:Vector2
var viewport_size: Vector2
var targeted_bite = null
var has_bite:bool = false
var colony_center: Vector2
var colony_radius: int = 60

var t_since_last_place: float = 0.0

var process_group: int = 0
var current_process_group: int = 0

var prev_pos: Vector2
var prev_left_pos: Vector2
var prev_front_pos: Vector2
var prev_right_pos: Vector2
var has_ran: bool = false

# Sensor var
var sense_distance_to_front: int = 30
var sense_angle_offset: int = 30
var sense_radius: int = 10

@onready var _animated_sprite = $Animation
@onready var _sensor_left  = $Sensor_left
@onready var _sensor_front = $Sensor_front
@onready var _sensor_right = $Sensor_right
@onready var _food_sensor = $Sensor_food
@onready var _background  = $"../../Background"
@onready var _button = $"../../Button"

func new_direction() -> Vector2:
	var new_dir: = Vector2()
	new_dir.x = randf_range(-1, 1)
	new_dir.y = randf_range(-1, 1)
	return new_dir.normalized()	

func handle_food():
	if has_bite == false:
		if targeted_bite == null:
			#if current_process_group == process_group:
			var allFood:Array
			
			for item in _food_sensor.get_overlapping_areas():
				if item.is_in_group("Food"):
					allFood.append(item)
				
			if allFood.size() > 0:
				randomize()
				targeted_bite = allFood[randi() % allFood.size()]
				targeted_bite.remove_from_group("Food")
				desired_direction = Vector2(targeted_bite.position - position).normalized()
		else:
			desired_direction = Vector2(targeted_bite.position - position).normalized()
			
			if targeted_bite.position.distance_to(position) < bite_pickup_radius:
				has_bite = true
				targeted_bite.position = position
				velocity = -velocity
				desired_direction = -desired_direction
	else:
		targeted_bite.position = position
		#if current_process_group == process_group:
			#for target in _food_sensor.get_overlapping_areas():
				#if target.is_in_group("Home"):
					#print("Found home!")
					#desired_direction = Vector2(target.position - position).normalized()
			
		if targeted_bite.position.distance_to(colony_center) < colony_radius + 10:
			_button.food.erase(targeted_bite)
			targeted_bite.queue_free()
			targeted_bite = null
			has_bite = false
			velocity = -velocity
			desired_direction = -desired_direction
			_button.inc_score()

func handle_sensors():
	#if has_ran:
		#_background.dots_left.erase(prev_left_pos)
		#_background.dots_front.erase(prev_front_pos)
		#_background.dots_right.erase(prev_right_pos)
		#_background.ants.erase(prev_pos)
	
	var left_sense_pos = position + desired_direction.rotated(-PI/6) * sense_distance_to_front
	var front_sense_pos = position + desired_direction * sense_distance_to_front
	var right_sense_pos = position + desired_direction.rotated(PI/6) * sense_distance_to_front
	
	var near_left: int = 0
	var near_front: int = 0
	var near_right: int = 0
	
	if has_bite:
		for trail in _background.trail_searching:
			if left_sense_pos.distance_to(trail[0]) <= sense_radius:
				near_left += 1
			elif front_sense_pos.distance_to(trail[0]) <= sense_radius:
				near_front += 1
			elif right_sense_pos.distance_to(trail[0]) <= sense_radius:
				near_right += 1
	else: 
		for trail in _background.trail_found:
			if left_sense_pos.distance_to(trail[0]) <= sense_radius:
				near_left += 1
			elif front_sense_pos.distance_to(trail[0]) <= sense_radius:
				near_front += 1
			elif right_sense_pos.distance_to(trail[0]) <= sense_radius:
				near_right += 1
	
	if near_left >= near_front and near_left >= near_right:
		desired_direction = (position + left_sense_pos).normalized()
	elif near_right >= near_left and near_right >= near_front:
		desired_direction = (position + right_sense_pos).normalized()
	
	
	#_background.dots_left.append(left_sense_pos)
	#_background.dots_front.append(front_sense_pos)
	#_background.dots_right.append(right_sense_pos)
	#_background.ants.append(position)
	#prev_pos = position
	#prev_left_pos = left_sense_pos
	#prev_front_pos = front_sense_pos
	#prev_right_pos = right_sense_pos
	#has_ran = true

func _physics_process(delta):
	# Update process group
	current_process_group = _button.current_process_group
	
	handle_food()
	
	handle_sensors()
	
	# Add a bit of randomness to direction
	desired_direction = (desired_direction + (new_direction() * wander_strength)).normalized()
	
	var desired_velocity: Vector2 = desired_direction * max_speed
	var desired_steering_force: Vector2 = Vector2(desired_velocity - velocity) * steer_strength
	var acceleration: Vector2 = desired_steering_force.limit_length(steer_strength)
	
	# Update velocity of ant
	velocity = Vector2(velocity + acceleration * delta).limit_length(max_speed)
	
	# Bound ant to viewport and invert when hit
	if 0 > position.x or position.x > viewport_size.x:
		velocity = -velocity
		desired_direction = -desired_direction
	if 0 > position.y or position.y > viewport_size.y:
		velocity = -velocity
		desired_direction = -desired_direction
	
	# Update position of ant
	position += velocity * delta
	rotation = desired_direction.angle()
	
	# Emmit trailing pheromone
	t_since_last_place += delta
	if t_since_last_place > pheromone_interval:
		t_since_last_place = 0.0
		if has_bite:
			_background.trail_found.append([position, 1.0])
		else:
			_background.trail_searching.append([position, 1.0])
