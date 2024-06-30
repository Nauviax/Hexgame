extends Control

# Parent controls visibility, so get reference
@onready var parent_container: Control = get_parent()

@export var tree: Tree
@export var graphic_parent: Control
@export var title_label: Label
@export var middle_container: Control
@export var code_label: Label
@export var is_spell_label: Label
@export var iota_count_label: Label
@export var description_label: Label

@export var popup_holder: Control # All popups should be children of this (Set in main_scene not in hexbook scene)

@onready var static_pattern_dict: Dictionary = Valid_Patterns.static_patterns

# If true, follow mouse
var follow_mouse: bool = false

# Pattern being displayed. Can be null
var current_pattern: Pattern = null

# Default description to show when no pattern is selected
const default_description = "This is the Hexbook. It contains all available patterns, but will not be enough to teach hexcasting from zero.\n
There are some changes from original hexcasting, mainly related to vectors being 2D and most spells being removed or significantly changed."

func _process(_delta: float) -> void:
	if follow_mouse:
		position = get_global_mouse_position() - Vector2(35, 25)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Clear hexbook text
	title_label.text = ""
	middle_container.visible = false
	description_label.text = default_description

	# Create tree
	tree.create_item() # Initial root item
	var top_item: TreeItem = make_item("Hexbook", true) # Title page
	tree.set_selected(top_item, 0) # Select the first item
	add_category("Basic Patterns", [
		"1lLl", # Mind's Reflection
		"1Rr", # Reveal
		"2LL", # Compass' Purification
		"2sL", # Alidade's Purification
		"2srLlL", # Scout's Distillation
		"2slLLsRR", # Archer's Distillation
		"2srRRsLL", # Architect's Distillation
		"2sl", # Pace Purification
		"6llL", # Enter
		"6llR", # Exit
	])
	make_item("Number Literals", true, null, "3LlLLssLLsL") # Number Literals standalone
	add_category("Mathematics", [
		"1sLLs", # Additive Distillation
		"6sRRs", # Subtractive Distillation
		"3sLlLs", # Multiplicative Distillation
		"1sRrRs", # Division Distillation
		"2lsr", # Ceiling Purification
		"2rsl", # Floor Purification
		"2rlllll", # Vector Distillation
		"2lrrrrr", # Vector Decomposition
		"1slLls", # Length Purification
		"6lllllLss", # Axial Purification
		"1LRRsLLR", # Modulus Distillation
		"6srRrs", # Power Distillation
		"6rlll", # Entropy Reflection
	])
	add_category("Constants", [
		"3LlLr", # True Reflection
		"1RrRl", # False Reflection
		"2R", # Nullary Reflection
		"6lllll", # Vector Reflection Zero
		"6lllllrL", # Vector Reflection Pos X
		"4rrrrrlL", # Vector Reflection Neg X
		"6lllllrR", # Vector Reflection Pos Y
		"4rrrrrlR", # Vector Reflection Neg Y
		"1lRsRl", # Arc's Reflection
		"6rLsLr", # Circle's Reflection
		"2LLl", # Euler's Reflection
	])
	make_item("Bookkeeper's Gambit", true, null, "3LrsrLRL") # Bookkeeper's Gambit standalone
	add_category("Stack Manipulation", [
		"2LLsRR", # Jester's Gambit
		"2LLrLL", # Rotation Gambit
		"1RRlRR", # Rotation Gambit II
		"2LLRLL", # Gemini Decomposition
		"2LLrRR", # Prospector's Gambit
		"2RRlLL", # Undertaker's Gambit
		"2LLRLLRLL", # Gemini Gambit
		"2LLRLRLLs", # Dioscuri Gambit
		"6lsLrLslLrLlL", # Flock's Reflection
		"5RRLR", # Fisherman's Gambit
		"2LLRL", # Fisherman's Gambit II
		"3lLLsRRr", # Swindler's Gambit
	])
	add_category("Logical Operators", [
		"1Ls", # Augur's Purification
		"1slLls", # Length Purification
		"6Rs", # Negation Purification
		"3sLs", # Disjunction Distillation
		"1sRs", # Conjunction Distillation
		"6RsL", # Exclusion Distillation
		"3LsRR", # Augur's Exaltation
		"2LR", # Equality Distillation
		"2RL", # Inequality Distillation
		"3r", # Maximus Distillation
		"3rr", # Maximus Distillation II
		"4l", # Minimus Distillation
		"4ll", # Minimus Distillation II
	])
	add_category("Entities", [
		"2srLlL", # Scout's Distillation
		"3lllllRLlL", # Entity Purification
		"3lllllsRrR", # Zone Distillation
	])
	add_category("Spells", [
		"2LLsLLsLL", # Explosion
		"4LslllsLls", # Impulse
		"5lllllLssLsLsR", # Float
		"2sssLllsrrrrrsll", # Teleport
	])
	add_category("Sentinels", [
		"2sLrLsLr", # Summon Sentinel
		"1lRsRlRs", # Banish Sentinel
		"2sLrLsLrRr", # Locate Sentinel
		"2sLrLsLrRsL", # Wayfind Sentinel
	])
	add_category("List Manipulation", [
		"6RrrrR", # Selection Distillation
		"6lLrLlsRrR", # Selection Exaltation
		"4rRlRr", # Integration Distillation
		"6lLrLl", # Derivation Decomposition
		"1sLLs", # Additive Distillation
		"1llLrLLr", # Vacant Reflection
		"2LRrrrR", # Single's Purification
		"1slLls", # Length Purification
		"2lllLrRr", # Retrograde Purification
		"2RrRlRr", # Locator's Distillation
		"4rRlRrsLlL", # Excisor's Distillation
		"6slLrLls", # Surgeon's Exaltation
		"4rsRlRsr", # Flock's Gambit
		"6lsLrLsl", # Flock's Disintegration
		"3RRrsrRR", # Speaker's Distillation
		"4LLlslLL", # Speaker's Decomposition
	])
	add_category("Escaping Patterns", [
		"5lllLs", # Consideration
		"5lll", # Introspection
		"2rrr", # Retrospection
		"2rrrRs", # Evanition
	])
	add_category("Reading and Writing", [
		"2Llllll", # Scribe's Reflection
		"2Rrrrrr", # Scribe's Gambit
		"2Lllllls", # Chronicler's Purification
		"2Rrrrrrs", # Chronicler's Gambit
		"2Llllllsr", # Auditor's Purification
		"2Rrrrrrsl", # Assessor's Purification
		"6rllsLslLLs", # Huginn's Gambit
		"1lrrsRsrRRs", # Muninn's Reflection
		"3RRl", # Verso's Gambit
		"3RRs", # Recto's Gambit
		"3RRr", # Tome's Gambit
	])
	add_category("Advanced Mathematics", [
		"3lllllLL", # Sine Purification
		"3lllllLR", # Cosine Purification
		"4slllllLRl", # Tangent Purification
		"3RRrrrrr", # Inverse Sine Purification
		"1LRrrrrr", # Inverse Cosine Purification
		"1rLRrrrrrs", # Inverse Tangent Purification
		"5RrLRrrrrrsR", # Inverse Tangent Purification II
		"6rlLlr", # Logarithmic Distillation
		"3sLsRrRsLs", # Factorial Purification
		"5LrL", # Running Sum Purification
		"1lLLsLLl", # Running Product Purification
	])
	add_category("Sets and Bits", [
		"3sLs", # Disjunction Distillation
		"1sRs", # Conjunction Distillation
		"6RsL", # Exclusion Distillation
		"6Rs", # Negation Purification
		"1LsrLlL", # Uniqueness Purification
	])
	add_category("Meta-Evaluation", [
		"3RrLll", # Hermes' Gambit
		"1RLRLR", # Thoth's Gambit
		"4LlRrr", # Charon's Gambit
	])

# TreeItem maker, to simplify rest of code
# Parent can be null to use root item
func make_item(text: String, selectable: bool, parent: TreeItem = null, code: String = "") -> TreeItem:
	var item: TreeItem = tree.create_item(parent)
	item.set_text(0, text)
	item.set_metadata(0, code)
	if selectable:
		item.set_custom_color(0, Color(1.0, 1.0, 1.0))
	else:
		item.set_custom_color(0, Color(0.7, 0.7, 0.7))
		item.set_selectable(0, false)
	return item

# Used to add a category of static patterns
func add_category(cat_name: String, patterns: Array) -> void:
	var category: TreeItem = make_item(cat_name, false)
	for pattern: String in patterns:
		make_item (
			static_pattern_dict[pattern.substr(1)][1], # Second item should be display name
			true, category, pattern
		)
	category.collapsed = true # To fit all categories in the tree view
	
# Handle display of given pattern or category
func _on_pattern_select_item_selected() -> void:
	if graphic_parent.get_child_count() != 0: # Remove old graphic if exists
		graphic_parent.get_child(0).queue_free()
	var item: TreeItem = tree.get_selected()
	if item:
		var metadata: String = item.get_metadata(0)
		if metadata != "": # Item has a pattern tied to it
			current_pattern = Pattern.new(metadata) # Create a new pattern with the given code

			# Display pattern line
			var p_line: Line2D = Pattern.create_line(current_pattern.p_code) 
			p_line.scale *= 1.3 # Make slightly larger, as more area than a popup
			p_line.position *= 1.3
			graphic_parent.add_child(p_line)
			
			# Set title
			title_label.text = current_pattern.name_display

			# Set misc labels
			middle_container.visible = true
			code_label.text = current_pattern.p_code
			is_spell_label.text = "Spell" if current_pattern.is_spell else "Pattern"
			iota_count_label.text = "Iotas In: " + str(current_pattern.p_exe_iota_count)
			
			# Set description
			var desc_text: String = ""
			if current_pattern.name_internal == Valid_Patterns.Pattern_Enum.numerical_reflection or current_pattern.name_internal == Valid_Patterns.Pattern_Enum.bookkeepers_gambit:
				desc_text = "THIS IS A DYNAMIC PATTERN. The example shown above is just one of many possible patterns.\n\n"
			for desc: String in current_pattern.descs:
				desc_text += desc + "\n\n"
			description_label.text = desc_text

		else: # Item is not tied to a pattern
			title_label.text = ""
			middle_container.visible = false
			description_label.text = default_description

# On click, toggle collapse of category. Works even if already selected.
func _on_pattern_select_item_mouse_selected(_position: Vector2, _mouse_button_index: int) -> void:
	var item: TreeItem = tree.get_selected()
	item.collapsed = not item.collapsed # Toggle collapse

# Drag functionality allows the window to be moved around
func _on_drag_button_down() -> void:
	follow_mouse = true # Unlock movement temporarily

func _on_drag_button_up() -> void:
	follow_mouse = false # Lock movement again

# Close button, to hide hexbook
func _on_close_pressed() -> void:
	parent_container.hide()

# Popup button, to show and auto-lock a pattern popup
func _on_popup_prompt_pressed() -> void:
	var popup: Hex_Popup = Hex_Popup.make_new(popup_holder)
	popup.display("P" + current_pattern.p_code, false) # Show pattern
	popup.lock() # Lock popup in place immediately
	
