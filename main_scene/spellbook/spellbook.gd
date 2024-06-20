extends PanelContainer

# UI element for selecting tabs. Use tab_bar.current_tab to get and set the current tab.
# !!! Does changing this value in code trigger the tab_changed signal?
@export var tab_bar: TabBar

# Labels for displaying spellbook strings and other info.
@export var sb_top_name: Label
@export var sb_top_item: RichTextLabel
@export var sb_top_selected: Label
@export var sb_middle_name: Label
@export var sb_middle_item: RichTextLabel
@export var sb_middle_selected: Label
@export var sb_bottom_name: Label
@export var sb_bottom_item: RichTextLabel
@export var sb_bottom_selected: Label

# List of strings the spellbook can show. First 9 items are for the three spellbook pages, and last 3 are Ravenmind, Sentinel, and Revealed Iota.
# Code that call functions in this script should ensure the index is within the bounds of this list. No checks are preformed here.
var spellbook_strings = [
	# Page 1
	"", # Iota 0
	"", # Iota 1
	"", # Iota 2
	# Page 2
	"", # Iota 3
	"", # Iota 4
	"", # Iota 5
	# Page 3
	"", # Iota 6
	"", # Iota 7
	"", # Iota 8
	# Page 4 (Misc)
	"", # Ravenmind 
	"", # Sentinel
	""  # Revealed Iota
]

# Currently selected iota index.
var selected_iota = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	update_spellbook_display() # !!! May be redundant soon

# Used to update the selected iota index, and moves to the relevant tab.
func update_selected_iota(index:int):
	selected_iota = index
	tab_bar.current_tab = index / 3
	update_spellbook_display()

# Used to update a specific value in the spellbook_strings list. Also sets the current tab to the given page index (0-3 inclusive).
func update_spellbook_item(index:int, value:String, update:bool, silent:bool):
	spellbook_strings[index] = value
	if update:
		if not silent:
			tab_bar.current_tab = index / 3
		update_spellbook_display()

# Called when a tab selection is made by user.
func _on_tab_bar_tab_clicked(_tab):
	update_spellbook_display()

# Refresh the spellbook display using the provided tab index. (NOT )
func update_spellbook_display():
	var tab = tab_bar.current_tab
	if tab == 3:
		sb_top_name.text = "Ravenmind"
		sb_middle_name.text = "Sentinel"
		sb_bottom_name.text = "Revealed Iota"
		sb_top_item.text = spellbook_strings[9]
		sb_middle_item.text = spellbook_strings[10]
		sb_bottom_item.text = spellbook_strings[11]
		sb_top_selected.text = ""
		sb_middle_selected.text = ""
		sb_bottom_selected.text = ""
	else:
		var index = tab * 3
		sb_top_name.text = "Iota " + str(index)
		sb_middle_name.text = "Iota " + str(index + 1)
		sb_bottom_name.text = "Iota " + str(index + 2)
		sb_top_item.text = spellbook_strings[index]
		sb_middle_item.text = spellbook_strings[index + 1]
		sb_bottom_item.text = spellbook_strings[index + 2]
		sb_top_selected.text = "O" if selected_iota == index else "I"
		sb_middle_selected.text = "O" if selected_iota == index + 1 else "I"
		sb_bottom_selected.text = "O" if selected_iota == index + 2 else "I"


func _on_button_pressed():
	update_selected_iota((selected_iota + 1) % 9)
