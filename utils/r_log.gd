class_name R_Log extends R_Node


enum Level {ALL, NONE, INFO, WARN, ERROR, RESULT, SUCCESS, FAIL}
enum Category {ALL, NONE, UNDEFINED, APP, DEVICE, SETTINGS, INTERFACE}

static var debuger_level_filter: Level = Level.ALL
static var debuger_category_filter: Category = Category.ALL


static func info(message: String, category: Category = Category.UNDEFINED) -> void:
	R_Log.print(message, category, Level.INFO)


static func warn(message: String, category: Category = Category.UNDEFINED) -> void:
	R_Log.print(message, category, Level.WARN)


static func error(message: String, category: Category = Category.UNDEFINED) -> void:
	R_Log.print(message, category, Level.ERROR)


static func success(message: String, category: Category = Category.UNDEFINED) -> void:
	R_Log.print(message, category, Level.SUCCESS)


static func fail(message: String, category: Category = Category.UNDEFINED) -> void:
	R_Log.print(message, category, Level.FAIL)


static func print(message: String, category: Category = Category.UNDEFINED, level: Level = Level.INFO) -> void:
	if debuger_level_filter != Level.ALL:
		if debuger_level_filter == Level.RESULT:
			if level not in [Level.SUCCESS, Level.FAIL]:
				return
		elif level != debuger_level_filter:
			return
	
	if debuger_category_filter != Level.ALL:
		if category != debuger_category_filter:
			return
	
	print_rich(&"[color=%s][%s] [%s] [%s] %s[/color]" % [
		debug_level_color(level),
		Time.get_time_string_from_system(),
		debug_level_string(level),
		debug_category_string(category),
		message,
	])


static func debug_level_string(debug_level: Level) -> StringName:
	match debug_level:
		Level.ALL:
			return &"ALL"
		Level.NONE:
			return &"NONE"
		Level.INFO:
			return &"INFO"
		Level.WARN:
			return &"WARN"
		Level.ERROR:
			return &"ERROR"
		Level.RESULT:
			return &"RESULT"
		Level.SUCCESS:
			return &"SUCCESS"
		Level.FAIL:
			return &"FAIL"
	return &"UNDEFINED"


static func debug_level_color(debug_level: Level) -> StringName:
	match debug_level:
		Level.INFO:
			return &"royal_blue"
		Level.WARN:
			return &"orange"
		Level.ERROR:
			return &"red"
		Level.SUCCESS:
			return &"dark_green"
		Level.FAIL:
			return &"dark_red"
	return &"white"


static func debug_category_string(debug_category: Category) -> StringName:
	match debug_category:
		Category.ALL:
			return &"ALL"
		Category.NONE:
			return &"NONE"
		Category.APP:
			return &"APP"
		Category.DEVICE:
			return &"DEVICE"
		Category.SETTINGS:
			return &"SETTINGS"
		Category.INTERFACE:
			return &"INTERFACE"
	return &"UNDEFINED"
