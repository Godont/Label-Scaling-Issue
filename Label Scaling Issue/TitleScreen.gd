extends Control


# Variables to track the current menu mode
enum modes {TITLE_SCREEN, FILE_SELECT, CONFIRM_CHOICE}
var mode = modes.TITLE_SCREEN

## Input variables
var right_pressed : bool = false
var left_pressed : bool = false
var up_pressed : bool = false
var down_pressed : bool = false
var select_pressed : bool = false
var cancel_pressed : bool = false

# An indicator of whether to accept navigation input
var navigation_free : bool = true
# A timer which, when finished, resets navigation_free to true
onready var navigation_timer : Timer = get_node("NavigationTimer")
# An indicator of whether to accept selection input
var select_free : bool = true
# A timer which, when finished, resets select_free to true
onready var select_timer : Timer = get_node("SelectTimer")


# References to nodes
onready var title_box = get_node("CenterContainer/TitleBox")
onready var file_select_box = get_node("CenterContainer/FileSelectBox")
onready var save_slots_box = get_node("CenterContainer/FileSelectBox/CenterContainer/SaveSlotsBox")
onready var confirm_box = get_node("CenterContainer/FileSelectBox/CenterContainer/ConfirmBox")
onready var choices_box = get_node("CenterContainer/FileSelectBox/CenterContainer/ConfirmBox/ChoicesBox")


# Variables to track the currently selected save file
var selections : Array
var num_selections : int
var current_selection : Label
var current_selection_index = 0

# Variables to track the currently selected confirmation choice
var current_choice : Label

## The scale to apply to focused selections
export(Vector2) var focus_scale : Vector2 = Vector2(1.6,1.6)



func _ready():
	
	## Initialize the selections array by adding all save slots
	for i in range(save_slots_box.get_child_count()):
		if save_slots_box.get_child(i).get_name().left(8) == "SaveFile":
			selections.push_back(save_slots_box.get_child(i))
	num_selections = selections.size()
	current_selection = selections[current_selection_index]
	current_choice = choices_box.get_node("Cancel")
	
	## Transition to the current mode
	mode_transition(mode)


func _input(event):
	
	up_pressed = Input.is_action_pressed("ui_up")
	down_pressed = Input.is_action_pressed("ui_down")
	right_pressed = Input.is_action_pressed("ui_right")
	left_pressed = Input.is_action_pressed("ui_left")
	select_pressed = event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept")
	cancel_pressed = event.is_action_pressed("ui_cancel")
	
	if select_pressed and select_free:
		select_free = false
		select_timer.start()
		match mode:
			modes.TITLE_SCREEN:
				mode_transition(modes.FILE_SELECT)
			modes.FILE_SELECT:
				mode_transition(modes.CONFIRM_CHOICE)
			modes.CONFIRM_CHOICE:
				if current_choice.text == "Cancel":
					mode_transition(modes.FILE_SELECT)
				elif current_choice.text == "Ok":
					#start new game
					pass

	if (down_pressed or up_pressed) and navigation_free and mode == modes.FILE_SELECT:
		unfocus_cursor(current_selection)
		navigation_free = false
		navigation_timer.start()
		var nav_delta = int(down_pressed) - int(up_pressed)
		current_selection_index = posmod(current_selection_index + nav_delta,num_selections)
		current_selection = selections[current_selection_index]
		focus_cursor(current_selection)
		
	if (left_pressed or right_pressed) and navigation_free and mode == modes.CONFIRM_CHOICE:
		unfocus_cursor(current_choice)
		navigation_free = false
		navigation_timer.start()
		if current_choice.text == "Cancel":
			current_choice = choices_box.get_node("Ok")
		elif current_choice.text == "Ok":
			current_choice = choices_box.get_node("Cancel")
			
		focus_cursor(current_choice)
	
	if cancel_pressed:
		match mode:
			modes.CONFIRM_CHOICE:
				mode_transition(modes.FILE_SELECT)
			modes.FILE_SELECT:
				mode_transition(modes.TITLE_SCREEN)




func mode_transition(new_mode : int):
	assert( new_mode in modes.values())
	mode = new_mode
	
	match mode:
		modes.TITLE_SCREEN:
			title_box.visible = true
			file_select_box.visible = false
		modes.FILE_SELECT:
			title_box.visible = false
			file_select_box.visible = true
			save_slots_box.visible = true
			confirm_box.visible = false
			call_deferred("focus_cursor",current_selection)
		modes.CONFIRM_CHOICE:
			title_box.visible = false
			file_select_box.visible = true
			save_slots_box.visible = false
			confirm_box.visible = true
			focus_cursor(current_choice)


func focus_cursor(selection):
	selection.rect_scale = focus_scale			
	
func unfocus_cursor(selection):
	selection.rect_scale = Vector2(1,1)


func _on_NavigationTimer_timeout():
	navigation_free = true


func _on_SelectTimer_timeout():
	select_free = true
