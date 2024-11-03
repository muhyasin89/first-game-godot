extends CharacterBody3D

@export var inventory_data: InventoryData

@export var joystick_touch_pad:Control

@onready var animation_tree= get_node("AnimationTree")
@onready var playback = animation_tree.get("parameters/playback")
@onready var knight: Node3D = $Knight
@onready var player: CharacterBody3D = $"."

signal toggle_inventory()

var SPEED = 5.0
const JUMP_VELOCITY = 4.5

const LOOKS_SENS = 2.0

#animation node names
var idle_node_name:String = "Idle"
var walk_node_name: String = "Walk"
var run_node_name:String = "Run"
var jump_node_full_long:String = "Jump_Full_Long"
var jump_idle:String = "Jump_Idle"
var jump_land:String = "Jump_Land"
var attack1_node_name:String = "Attack1"
var death_node_name:String = "Death"

#State Machine Condition
var is_walking :bool
var is_attacking:bool= false
var is_dying: bool
var is_running: bool = false
var is_jumping: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var movement_input_vector = Vector2.ZERO


var spell_a = preload("res://scenes/demos/top_down_spells/spell_a.tscn")
var spell_b = preload("res://scenes/demos/top_down_spells/spell_b.tscn")

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if is_jumping and is_on_floor():
		is_jumping = false
		velocity.y = JUMP_VELOCITY
		$StateChart.set_expression_property("is_jumping", is_jumping)
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = joystick_touch_pad.get_joystick()
	
	if input_dir != Vector2.ZERO:
		knight.rotation.y = -input_dir.angle()
		
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		is_walking = true
		$StateChart.set_expression_property("is_walking", is_walking)
	else:
		is_walking = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	
	move_and_slide()


func _on_action_a_button_pressed():
	var new_spell_a = spell_a.instantiate()
	new_spell_a.rotation.y = knight.rotation.y - deg_to_rad(45)
	new_spell_a.position = position + Vector3.UP
	get_parent().add_child(new_spell_a)


func _on_action_b_button_pressed():
	var new_spell_b = spell_b.instantiate()
	new_spell_b.position = position
	get_parent().add_child(new_spell_b)

func _on_jumped_pressed():
	is_jumping = true
	$StateChart.set_expression_property("is_jumping", is_jumping)
	#knight.get_surface_override_material(0).set_albedo(Color(randf_range(0,1),randf_range(0,1),randf_range(0,1)))


func _on_attack_button_pressed() -> void: 
	is_attacking = true # Replace with function body.
	$StateChart.set_expression_property("is_attacking", is_attacking)


func _on_inventory_pressed() -> void:
	toggle_inventory.emit() # Replace with function body.


func _on_is_running_button_pressed() -> void:
	is_running = !is_running
	if is_running:
		SPEED = 10.0
	else:
		SPEED = 5.0
	$StateChart.set_expression_property("is_running", is_running)


func _on_idle_state_entered() -> void:
	playback.travel(idle_node_name)


func _on_walking_state_entered() -> void:
	playback.travel(walk_node_name)

func _on_running_state_entered() -> void:
	playback.travel(run_node_name) 


func _on_jump_state_entered() -> void:
	$StateChart.set_expression_property("is_running", is_running)
	$StateChart.set_expression_property("is_walking", is_walking)
	
	if !is_running && !is_walking:
		playback.travel(jump_idle)
	elif is_walking:
		playback.travel(jump_land)
	elif is_running:
		playback.travel(jump_node_full_long)
		


func _on_attacking_state_entered() -> void:
	playback.travel(attack1_node_name)
	await player.get_node("AnimationPlayer").animation_finished
	is_attacking = false
	$StateChart.set_expression_property("is_attacking", is_attacking)
