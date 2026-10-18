extends RefCounted
class_name JUnitReport

static func build(results: Array[TestRunner.TestResult], suite_name := "core") -> String:
	var failures := 0
	var errors := 0
	var total_time := 0.0
	var cases := ""
	
	for r in results:
		total_time += r.duration
		cases += '\t\t<testcase classname="%s" name="%s" time="%.4f"' % [_esc(r.long_classname), _esc(r.name), r.duration]
		
		if not r.failures.is_empty():
			failures += 1
			cases += ">\n"
			cases += '\t\t\t<failure message="%s">%s</failure>\n' % [_esc(r.failures[0]), _esc("\n".join(r.failures))]
			cases += "\t\t</testcase>\n"
		elif r.no_assertion:
			errors += 1
			cases += ">\n"
			cases += '\t\t\t<error message="Test ran no assertion"/>\n'
			cases += "\t\t</testcase>\n"
		else:
			cases += "/>\n"
	
	var xml := '<?xml version="1.0" encoding="UTF-8"?>\n'
	xml += '<testsuites>\n'
	xml += '\t<testsuite name="%s" tests="%d" failures="%d" errors="%d" skipped="0" time="%.4f">\n' % [
		_esc(suite_name), results.size(), failures, errors, total_time]
	xml += cases
	xml += "\t</testsuite>\n</testsuites>\n"
	return xml


static func _esc(text: String) -> String:
	# XML 1.0 forbids most control chars (e.g. ANSI escapes): strip them.
	var clean := ""
	for i in text.length():
		var c := text.unicode_at(i)
		if c == 9 or c == 10 or c == 13 or c >= 32:
			clean += text[i]
	return clean.xml_escape(true)
