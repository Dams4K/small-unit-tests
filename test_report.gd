@abstract
extends Object
class_name TestReport

static var bbcode_mode := "--bbcode" in OS.get_cmdline_user_args()

const C_PASS := "#6cc38a"
const C_FAIL := "#e5747a"
const C_WARN := "#e0c068"
const C_DIM := "#8b8b8b"

static func report(text: String) -> void:
	if bbcode_mode:
		print(text)
	else:
		print_rich(text)

static func report_fail(text: String) -> void:
	if bbcode_mode:
		print("[color=%s]%s[/color]" % [C_FAIL, text])
	else:
		print_rich("[color=%s]%s[/color]" % [C_FAIL, text])
