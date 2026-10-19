@abstract
extends Object
class_name SutTestReport

static func report(text: String) -> void:
	if SutTestOptions.get_singleton().bbcode:
		print(text)
	else:
		print_rich(text)

static func report_success(text: String) -> void:
	report("[color=%s]%s[/color]" % [SutTestOptions.get_singleton().success_color, text])

static func report_fail(text: String) -> void:
	report("[color=%s]%s[/color]" % [SutTestOptions.get_singleton().error_color, text])
