@abstract
extends Object
class_name SutTestColor

static func success() -> Color:
	return EditorInterface.get_editor_theme().get_color("success_color", "Editor")

static func error() -> Color:
	return EditorInterface.get_editor_theme().get_color("error_color", "Editor")

static func warning() -> Color:
	return EditorInterface.get_editor_theme().get_color("warning_color", "Editor")
