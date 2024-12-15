extends CharacterBody3D

@export var inventory_data: InventoryData

@export var joystick_touch_pad:Control

@onready var animation_tree = get_node("AnimationTree")
@onready var playback = animation_tree.get("parameters/playback")
@onready var knight: Node3D = $Knight
@onready var PlayerInteractor: Area3D = $PlayerInteractor

signal toggle_inventory()

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const LOOKS_SENS = 2.0

#animation node names
var idle_node_name:String = "Idle"
var walk_node_name: String = "Walking"
var run_node_name:String = "Run"
var jump_node_full_long:String = "Jump_Full_Long"
var attack1_node_name:String = "Attack1"
var death_node_name:String = "Death"


var isMoving: bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var movement_input_vector = Vector2.ZERO

var jump_just_pressed = false

var spell_a = preload("res://scenes/demos/top_down_spells/spell_a.tscn")
var spell_b = preload("res://scenes/demos/top_down_spells/spell_b.tscn")

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if jump_just_pressed and is_on_floor():
		jump_just_pressed = false
		velocity.y = JUMP_VELOCITY
		
	# Handle collision
	#if interact_ray.is_colliding():
		#print("interact with ", interact_ray.get_collider())
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = joystick_touch_pad.get_joystick()
	
	if input_dir != Vector2.ZERO:
		knight.rotation.y = -input_dir.angle()
		
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		IsMoving()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		IsIdle()
	
	move_and_slide()
	
func IsMoving():
	isMoving = true
	$PlayerState.send_event("player_moving")
	playback.travel(walk_node_name)

func IsIdle():
	isMoving = false
	playback.travel(idle_node_name)
	$PlayerState.send_event("player_idle")
	
func on_item_picked_up(item_id: String):
	print("I got a ", Items.Database[item_id].name)
	
func on_chest_interact(chest_id: String):
	print("On Item chest")


func on_jump_button_pressed():
	jump_just_pressed = true


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
	print("click jump")
	#knight.get_surface_override_material(0).set_albedo(Color(randf_range(0,1),randf_range(0,1),randf_range(0,1)))


func _on_attack_button_pressed() -> void:
	print("is attacking")
	# Replace with function body.


func _on_inventory_pressed() -> void:
	toggle_inventory.emit() # Replace with function body.


func _on_interactable_pressed() -> void:
	PlayerInteractor.input() # Replace with function body.
