extends HBoxContainer

const ORE_LIST = [
	["Silver", Color.RED],
	["Gold", Color.ORANGE],
	["Platinum", Color.YELLOW],
	["Tungsten", Color.GREEN],
	["Palladium", Color.BLUE],
	["Rhodium", Color.INDIGO],
	["Iridium", Color.VIOLET],
	["Osmium", Color.GRAY],
]

var res_type : int = 0:
	set(val):
		res_type = clamp(val, 0, ORE_LIST.size()-1)
		$Name.text = ORE_LIST[res_type][0]
		$Icon.modulate = ORE_LIST[res_type][1]

var amount : int = 0:
	set(val):
		amount = max(0, val)
		$Amount.text = str(amount)
