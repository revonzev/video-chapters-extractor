extends Control


@export var text_edit: TextEdit
@export var video_name: LineEdit
@export var file_selector_dialog: FileDialog
@export var save_file_dialog: FileDialog


var converter_result: String
var to_convert_file_path: String


func _ready() -> void:
	log_os_version()
	log_computer_spec()
	log_ffprobe_version()
	get_window().files_dropped.connect(_on_files_dropped)


func convert_file_to_text_chapters(file_to_convert: String) -> void:
	text_edit.text = ""
	video_name.text = file_to_convert.get_file()
	to_convert_file_path = file_to_convert

	var output: Array = []
	R_Log.info("converting %s" % file_to_convert, R_Log.Category.APP)
	OS.execute("ffprobe", ["-show_chapters", file_to_convert], output)
	
	if not str(output[0]).contains("[CHAPTER]"):
		text_edit.text = (
			"Error \"[CHAPTER]\" not found, please make sure "
			+"ffprobe package is installed and the video file has chapters "
			+"and the file is a video file."
		)
		return

	var sanitized: String = output[0].replace("\\n", "\n")
	sanitized = sanitized.replace("[CHAPTER]\n", "")
	sanitized = sanitized.replace("[/CHAPTER]\n", "---SPLIT---")
	var chapters: Array[Chapter] = []
	var raw_chapters: PackedStringArray = sanitized.split("---SPLIT---", false)

	for raw_chapter: String in raw_chapters:
		chapters.append(string_to_chapter(raw_chapter))
	R_Log.info("chapter count: %s" % str(chapters.size()), R_Log.Category.APP)

	for chapter: Chapter in chapters:
		var hours: int = int(chapter.start_time / 3600)
		var minutes: int = int((chapter.start_time - hours * 3600) / 60)
		var seconds: int = int(chapter.start_time - minutes * 60 - hours * 3600)

		var text: String = int_to_string_with_zero_prefix(hours)
		text += ":"
		text += int_to_string_with_zero_prefix(minutes)
		text += ":"
		text += int_to_string_with_zero_prefix(seconds)
		text += " "
		text += chapter.tag_title
		text += "\n"

		text_edit.text += text

		print(str(chapter)+"\n")
	
	converter_result = text_edit.text
	R_Log.info("file converted", R_Log.Category.APP)


func int_to_string_with_zero_prefix(value: int) -> String:
	if value <= 9:
		return "0"+str(value)
	return str(value)


func string_to_chapter(raw: String) -> Chapter:
	var chapter: Chapter = Chapter.new()
	
	chapter.id = int(search_pattern(r"id=([0-9]+)", raw))
	chapter.time_base = String(search_pattern(r"time_base=([0-9]+\/[0-9]+)", raw))
	chapter.start = int(search_pattern(r"start=([0-9]+)", raw))
	chapter.start_time = float(search_pattern(r"start_time=([0-9]+.[0-9]+)", raw))
	chapter.end = int(search_pattern(r"end=([0-9]+)", raw))
	chapter.end_time = float(search_pattern(r"end_time=([0-9]+.[0-9]+)", raw))
	chapter.tag_title = String(search_pattern(r"TAG:title=(.+)\n", raw))

	return chapter


func search_pattern(pattern: String, raw: String) -> Variant:
	var re: RegEx = RegEx.new()
	re.compile(pattern)
	var result: RegExMatch = re.search(raw)

	return result.strings[-1]


func save_result(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(converter_result)
	file.close()


func log_ffprobe_version() -> void:
	var output: Array = []
	OS.execute("ffprobe", ["-version"], output)
	R_Log.info(str(output[0]), R_Log.Category.DEVICE)


func log_os_version() -> void:
	R_Log.info("OS name: %s" % OS.get_name(), R_Log.Category.DEVICE)
	R_Log.info("OS version: %s" % OS.get_version(), R_Log.Category.DEVICE)
	R_Log.info("OS version alias: %s" % OS.get_version_alias(), R_Log.Category.DEVICE)
	R_Log.info("OS distribution name: %s" % OS.get_distribution_name(), R_Log.Category.DEVICE)
	R_Log.info("model name: %s" % OS.get_model_name(), R_Log.Category.DEVICE)


func log_computer_spec() -> void:
	R_Log.info("processor count: %s" % str(OS.get_processor_count()), R_Log.Category.DEVICE)
	R_Log.info("processor name: %s" % OS.get_processor_name(), R_Log.Category.DEVICE)
	R_Log.info("rendering driver name: %s" % RenderingServer.get_current_rendering_driver_name(), R_Log.Category.DEVICE)
	R_Log.info("rendering method: %s" % RenderingServer.get_current_rendering_method(), R_Log.Category.DEVICE)
	R_Log.info("video adapter name: %s" % RenderingServer.get_video_adapter_name(), R_Log.Category.DEVICE)
	R_Log.info("video adapter type: %s" % RenderingServer.get_video_adapter_type(), R_Log.Category.DEVICE)
	R_Log.info("video adapter type: %s" % RenderingServer.get_video_adapter_vendor(), R_Log.Category.DEVICE)

	var rendering_device: RenderingDevice = RenderingServer.get_rendering_device()
	if rendering_device == null: return
	R_Log.info("rendering device name: %s" % str(rendering_device.get_device_name()), R_Log.Category.DEVICE)
	R_Log.info("rendering device vendor name: %s" % str(rendering_device.get_device_vendor_name()), R_Log.Category.DEVICE)
	R_Log.info("rendering device vendor name: %s" % str(rendering_device.get_), R_Log.Category.DEVICE)


func _on_open_file_manager_pressed() -> void:
	file_selector_dialog.popup()


func _on_save_file_manager_pressed() -> void:
	save_file_dialog.popup()


func _on_select_file_file_selected(path: String) -> void:
	convert_file_to_text_chapters(path)


func _on_files_dropped(files: PackedStringArray):
	convert_file_to_text_chapters(files[0])


func _on_save_file_file_selected(path: String) -> void:
	save_result(path)


class Chapter:
	var id: int = -1
	var time_base: String = ""
	var start: int = -1
	var start_time: float = -1
	var end: int = -1
	var end_time: float = -1
	var tag_title: String = ""

	func _to_string() -> String:
		return (
			"id=%s\n"
			+"time_base=%s\n"
			+"start=%s\n"
			+"start_time=%s\n"
			+"end=%s\n"
			+"end_time=%s\n"
			+"tag_title=%s"
		) % [
			str(id),
			time_base,
			str(start),
			str(start_time),
			str(end),
			str(end_time),
			tag_title,
		]
