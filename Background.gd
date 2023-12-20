extends Node2D

var trail_searching = Array()
var trail_found = Array()
var dots_left = Array()
var dots_front = Array()
var dots_right = Array()
var ants = Array()

var t_since_last_place: float = 0.0
var draw_interval: float = 1.0

func _ready():
	trail_found.append([Vector2(0,0), 0.0])
	trail_searching.append([Vector2(0,0), 0.0])
	#dots_left.append(Vector2(0,0))
	#dots_front.append(Vector2(0,0))
	#dots_right.append(Vector2(0,0))
	#ants.append(Vector2(0,0))

func _draw():
	for trail in trail_searching:
		draw_circle(trail[0], 1.2, Color(0.0, trail[1], 0.0))
	
	for trail in trail_found:
		draw_circle(trail[0], 1.2, Color(0,0,trail[1]))
	
	#for i in range(dots_left.size()):
		##draw_circle(dots[i], 3, Color(1.0, 1.0, 1.0))
		#draw_line(ants[i], dots_left[i], Color(1.0,1.0,1.0))
		#draw_line(ants[i], dots_front[i], Color(1.0,1.0,1.0))
		#draw_line(ants[i], dots_right[i], Color(1.0,1.0,1.0))

func _process(delta):
	t_since_last_place += delta
	if t_since_last_place > draw_interval:
		t_since_last_place = 0.0
		print("Trail Searching: " + str(trail_searching.size()) + " | Trail Found: " + str(trail_found.size()))
		print("Total: " + str(trail_searching.size() + trail_found.size()))
		queue_redraw()
	
	for trail in trail_searching:
		trail[1] -= 0.0009
		if trail[1] <= 0.1:
			trail_searching.erase(trail)
	
	for trail in trail_found:
		trail[1] -= 0.0007
		if trail[1] <= 0.1:
			trail_found.erase(trail)
