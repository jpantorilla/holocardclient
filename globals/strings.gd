extends Node


const STRING_OK = "OK"
const STRING_YES = "Yes"
const STRING_NO = "No"
const STRING_PASS = "Pass"
const STRING_CANCEL = "Cancel"
const STRING_SHOW_CHOICE = "Show Choice"

const DECISION_INSTRUCTIONS_MULLIGAN = "Mulligan all cards?"
const DECISION_INSTRUCTIONS_INITIAL_CHOOSE_CENTER = "Debut your Center!"
const DECISION_INSTRUCTIONS_INITIAL_CHOOSE_BACKSTAGE = "Select 0-5 backup members (debut/spot)"

const DECISION_INSTRUCTIONS_MAIN_STEP = "Main Step - Choose an action"
const DECISION_INSTRUCTIONS_PERFORMANCE_STEP = "Perform an art or end your turn"
const DECISION_INSTRUCTIONS_PLACE_HOLOMEM = "Choose a Holomem to enter the stage"
const DECISION_INSTRUCTIONS_CHOOSE_BLOOM = "Choose a Bloom card to play"
const DECISION_INSTRUCTIONS_CHOOSE_BLOOM_TARGET = "Choose a Holomem to Bloom"
const DECISION_INSTRUCTIONS_COLLAB = "Choose a Holomem to Collab"
const DECISION_INSTRUCTIONS_BATON_PASS = "Choose a Holomem to Baton Pass"
const DECISION_INSTRUCTIONS_SEND_COLLAB_BACK = "Send Collab back?"
const DECISION_INSTRUCTIONS_CHOOSE_NEW_CENTER = "Choose a new Center"
const DECISION_INSTRUCTIONS_SWAP_CENTER = "Choose a Holomem to swap into the Center"
const DECISION_INSTRUCTIONS_CHOOSE_DIE_RESULT = "Choose the next die result ("

const SkillNameMap = {
	# Oshi
	"replacement": "Replacement",
	"soyouretheenemy": "So, you're the enemy?",
	"mapinthelefthand": "Map in the left hand",
	"micintherighthand": "Mic in the right hand",

	# Arts
	"nunnun": "(๑╹ᆺ╹) nun nun",
	"onstage": "On stage!",
	"nunnunshiyo": "nun nun shiyo",
	"yourheartiscloudythenclear": "Your heart is cloudy... then clear!",
	"dreamlive": "Dream Live",
	"sorazsympathy": "SorAZ Sympathy",
	"embodimentofhope": "Embodiment of Hope",
	"keepworkinghard": "Keep working hard!",
	"wherenextwherenext": "Where next, where next!",
	"anaimlessjourneywithyou": "An aimless journey with you",
	"sorazgravity": "SorAZ Gravity",
	"destinysong": "Destiny Song",
	"ihadfundrawing": "I had fun drawing!",
	"brighterfuture": "Brighter Future",
	"hey": "Hey",
	"purepurepure": "Pure Pure Pure~",
}

# Lazy placeholder for loc
func get_string(str_id) -> String:
	return str_id

func get_skill_string(skill_id):
	if skill_id in SkillNameMap:
		return SkillNameMap[skill_id]
	return skill_id

func get_position_string(position):
	match position:
		"center": return "Center"
		"backstage": return "Back"
		"collab": return "Collab"
		_: return "Unknown"

func get_performance_skill(performer_position, art_id, power):
	var skill = get_skill_string(art_id)
	var position_str = get_position_string(performer_position)
	return "%s: %s (%s)" % [position_str, skill, power]

func build_choose_die_result_string(skill_name, cost):
	var skill_name_str = ""
	if skill_name:
		if cost:
			skill_name_str = "Use [b]%s[/b] (%s Holopower)?\n" % [skill_name, cost]
		else:
			skill_name_str = "Use [b]%s[/b]?\n" % skill_name
	return "%sChoose the next die result" % [skill_name_str]

func build_archive_cheer_string(count):
	return "Choose %s Cheer to Archive" % count

func build_place_cheer_string(source:String, color:String):
	var color_str = color.to_upper()
	var source_str = source
	match source:
		"cheer_deck":
			source_str = "your Cheer Deck"
	return "Place 1 %s Cheer from %s" % [color_str, source_str]

func get_action_name(action_type:String):
	match action_type:
		Enums.GameAction_MainStepPlaceHolomem:
			return "Place Holomem"
		Enums.GameAction_MainStepBloom:
			return "Bloom"
		Enums.GameAction_MainStepCollab:
			return "Collab"
		Enums.GameAction_MainStepOshiSkill:
			return "Oshi Skill"
		Enums.GameAction_MainStepPlaySupport:
			return "Play Support"
		Enums.GameAction_MainStepBatonPass:
			return "Baton Pass"
		Enums.GameAction_MainStepBeginPerformance:
			return "Begin Performance"
		Enums.GameAction_MainStepEndTurn, Enums.GameAction_PerformanceStepEndTurn:
			return "End Turn"
		_:
			return "Unknown Action"
