/*
 * generated by Xtext 2.29.0
 */
package org.example.customgreetings.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.example.customgreetings.greetings.Model
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(GreetingsInjectorProvider)
class GreetingsParsingTest {

	@Inject
	ParseHelper<Model> parseHelper

	@Test
	def void loadModel() {
		val result = parseHelper.parse('''
			Hello Xtext!
		''')
		assertNotNull(result)
	}

	@Test
	def void testCustomGreetingToString() {
		val result = parseHelper.parse('''
			Hello Xtext!
		''')
		assertEquals("Hello Xtext", result.greetings.head.toString)
	}

}
