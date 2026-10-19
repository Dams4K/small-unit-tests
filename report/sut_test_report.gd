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


static func report_running(path: String) -> void:
	SutTestReport.report("[color=%s]Running %s[/color]" % [SutTestOptions.get_singleton().dim_color, path])


static func report_results(results: Array[SutTestResult]) -> void:
	var total_time := 0.0
	var total_runs: int = 0
	var total_failures: int = 0
	var classname := "<unknown>"
	for result: SutTestResult in results:
		total_time += result.duration_usec
		total_runs += 1
		if result.failed():
			total_failures += 1
		classname = result.get_classname()
	
	total_time /= 1_000_000
	if total_failures == 0:
		SutTestReport.report("[color=%s]Tests run: %d[/color], Failures: %d, Time elapsed: %.3fs [color=%s]-- in %s[/color]" % [
			SutTestOptions.get_singleton().success_color,
			total_runs,
			total_failures,
			total_time,
			SutTestOptions.get_singleton().dim_color,
			classname
		])
	else:
		SutTestReport.report("Tests run: %d, [color=%s]Failures: %d[/color], Time elapsed: %.3fs [color=%s]-- in %s[/color]" % [
			total_runs,
			SutTestOptions.get_singleton().error_color,
			total_failures,
			total_time,
			SutTestOptions.get_singleton().dim_color,
			classname
		])


static func report_result_if_failed(result: SutTestResult) -> bool:
	if result == null:
		return false
	
	var failed = result.failed()
	for message: String in result.failures:
		SutTestReport.report_fail("[%s.%s] %s" % [result.get_classname(), result.name, message])
	return failed
