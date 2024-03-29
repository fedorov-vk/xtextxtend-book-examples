/*
 * generated by Xtext 2.29.0
 */
package org.example.school.validation

import com.google.common.collect.HashMultimap
import org.eclipse.xtext.validation.Check
import org.example.school.school.Named
import org.example.school.school.School
import org.example.school.school.SchoolModel
import org.example.school.school.SchoolPackage

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class SchoolValidator extends AbstractSchoolValidator {

	protected static val ISSUE_CODE_PREFIX = "org.example.school."
	public static val DUPLICATE_ELEMENT = ISSUE_CODE_PREFIX + "DuplicateElement"
	public static val STUDENT_WITH_NO_TEACHER = ISSUE_CODE_PREFIX + "StudentWithNoTeacher"

	@Check def void checkNoDuplicateSchools(SchoolModel e) {
		checkNoDuplicateElements(e.schools, "school")
	}

	@Check def void checkNoDuplicatePersons(School e) {
		checkNoDuplicateElements(e.teachers, "teacher")
		checkNoDuplicateElements(e.students, "student")
	}

	@Check def void checkStudentsWithNoTeachers(School e) {
		val statistics = e.statistics
		if (statistics.teachersNumber > 0) {
			for (s : statistics.studentsWithNoTeacher) {
				warning("Student " + s.name + " has no teacher", s, SchoolPackage.eINSTANCE.named_Name,
					STUDENT_WITH_NO_TEACHER)
			}
		}
	}

	def private void checkNoDuplicateElements(Iterable<? extends Named> elements, String desc) {
		val multiMap = HashMultimap.create()

		for (e : elements)
			multiMap.put(e.name, e)

		for (entry : multiMap.asMap.entrySet) {
			val duplicates = entry.value
			if (duplicates.size > 1) {
				for (d : duplicates)
					error(
						"Duplicate " + desc + " '" + d.name + "'",
						d,
						SchoolPackage.eINSTANCE.named_Name,
						DUPLICATE_ELEMENT
					)
			}
		}
	}

}
