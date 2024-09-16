extends StaticBody2D

# Die Class Variables
var index = 0
var intended_position : Vector2
var type = 6
var score = 1
var selected = false
var curr_face = 0
var faces = []

# Drag and Drop Variables
var draggable = false
var is_inside_droppable = false
var body_ref

func _ready():
	randomize()

func _process(_delta):
	# Drag and Drop
	if draggable:
		if Input.is_action_just_pressed("leftClick"):
			Glob.is_dragging = true
			$Die.z_index = 2
			$ClickTimer.start(.1)
		if Input.is_action_pressed("leftClick"):
			global_position = get_global_mouse_position()
		elif Input.is_action_just_released("leftClick"):
			Glob.is_dragging = false
			if $ClickTimer.is_stopped():
				$Die.z_index = 0
				var tween = get_tree().create_tween()
				if is_inside_droppable:
					var tween2 = get_tree().create_tween()
					# Swap Die Indexes
					var new_index = body_ref.index
					body_ref.index = self.index
					self.index = new_index
					# Move Animation
					tween2.tween_property(body_ref, "position", intended_position, 0.2).set_ease(Tween.EASE_OUT)
					tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
				else:
					tween.tween_property(self, "global_position", intended_position, 0.2).set_ease(Tween.EASE_OUT)
				await tween.finished
			else:
				_toggle_select()
				self.position = intended_position
			# Dispatch Dice on Screen
			get_parent()._reorder_dice()

# Get Die Position
func _find_position(dice_count:int):
	if dice_count % 2 == 0:
		intended_position = Vector2(576 + 32 + 64 * (index - dice_count / 2),280)
	else:
		intended_position = Vector2(576 + 64 * (index - dice_count / 2),280)
	return intended_position

# Set Die Type
func _set_type(ref_type):
	_set_texture(load("res://assets/images/dice/d"+str(ref_type)+".png"))
	type = ref_type
	_handle_type()

func _handle_type():
	# Set face values
	for i in range(1,type+1):
		faces.append(i)
	# Set animation frames
	if type < 8:
		$Die.hframes = type
		$Die.vframes = 1
	elif type < 12:
		$Die.hframes = type/2
		$Die.vframes = 2
	elif type <= 20:
		$Die.hframes = ceil(sqrt(type))
		$Die.vframes = floor(sqrt(type))

# Set Die Texture
func _set_texture(file):
	$Die.texture = file

# Drag and Drop
func _on_area_2d_mouse_entered():
	if not Glob.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited():
	if not Glob.is_dragging:
		draggable = false
		scale = Vector2(1.0, 1.0)

func _on_area_2d_body_entered(body):
	if body.is_in_group('droppable') and body != self:
		is_inside_droppable = true
		body_ref = body

func _on_area_2d_body_exited(body):
	if body.is_in_group('droppable') and body == body_ref:
		is_inside_droppable = false
	
# Roll Die Function
func _roll():
	if !selected:
		var value = randi() % type
		curr_face = value
		score = faces[value]
		$RollAnimation.play("roll")

func _animation_finished(anim_name:String):
	if anim_name == "roll":
		$Die.frame = curr_face

# Select Die Function
func _toggle_select():
	if !selected:
		$Die.get_child(0).show()
		selected = true
	else:
		$Die.get_child(0).hide()
		selected = false
