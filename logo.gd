extends Sprite2D

const speed: Vector2 = Vector2(200,200)

var viewport: Vector2

func _process(delta):
	viewport = get_viewport().get_visible_rect().size
	
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction.x < 0 && position.x <= 0:
		direction.x = 0
	if direction.x > 0 && position.x >= viewport.x:
		direction.x = 0
	if direction.y < 0 && position.y <= 0:
		direction.y = 0
	if direction.y > 0 && position.y >= viewport.y:
		direction.y = 0	
	position += direction * delta * speed

#func _input(event):
	## Mouse in viewport coordinates.
	#if event is InputEventMouseButton:
		#print("Mouse Click/Unclick at: ", event.position)
	#elif event is InputEventMouseMotion:
		#print("Mouse Motion at: ", event.position)
#
	## Print the size of the viewport.
	#print("Viewport Resolution is: ", viewport)
