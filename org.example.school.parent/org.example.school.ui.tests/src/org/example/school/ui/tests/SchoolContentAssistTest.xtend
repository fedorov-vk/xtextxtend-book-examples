package org.example.school.ui.tests

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.ui.testing.AbstractContentAssistTest
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

@ExtendWith(InjectionExtension)
@InjectWith(SchoolUiInjectorProvider)
class SchoolContentAssistTest extends AbstractContentAssistTest {

	@Test
	def void testEmptyProgram() {
		newBuilder.assertProposal("school")
	}

	@Test
	def void testTeacherProposal() {
		newBuilder.append(
			'''
				school "A school" {
					teacher "A teacher"
					student "A student" registrationNum 100 {
				'''
		).assertProposal('"A teacher"')
	}

}
