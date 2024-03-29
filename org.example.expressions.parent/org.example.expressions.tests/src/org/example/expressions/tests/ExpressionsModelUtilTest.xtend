package org.example.expressions.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.example.expressions.ExpressionsModelUtil
import org.example.expressions.expressions.ExpressionsModel
import org.example.expressions.expressions.VariableRef
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(ExpressionsInjectorProvider)
class ExpressionsModelUtilTest {

	@Inject extension ParseHelper<ExpressionsModel>
	@Inject extension ExpressionsModelUtil

	@Test def void variablesBeforeVariable() {
		'''
			eval true    // (0)
			var i = 0    // (1)
			eval i + 10  // (2)
			var j = i    // (3)
			eval i + j   // (4)
		'''.parse => [
			assertVariablesDefinedBefore(0, "")
			assertVariablesDefinedBefore(1, "")
			assertVariablesDefinedBefore(2, "i")
			assertVariablesDefinedBefore(3, "i")
			assertVariablesDefinedBefore(4, "i,j")
		]
	}

	@Test def testIsVariableDefinedBeforeTrue() {
		'''
			var i = 0
			eval i
		'''.assertVariableDefinedBefore(true)
	}

	@Test def testIsVariableDefinedBeforeFalse() {
		'''
			var i = i
		'''.assertVariableDefinedBefore(false)
	}

	@Test def testIsVariableDefinedBeforeWhenVariableUndefined() {
		'''
			eval i
		'''.assertVariableDefinedBefore(false)
	}

	def private void assertVariablesDefinedBefore(ExpressionsModel model, int elemIndex, CharSequence expectedVars) {
		expectedVars.assertEquals(
			model.elements.get(elemIndex).variablesDefinedBefore.map[name].join(",")
		)
	}

	def private void assertVariableDefinedBefore(CharSequence input, boolean expected) {
		expected.assertEquals(
			(input.parse.elements.last.expression as VariableRef).isVariableDefinedBefore
		)
	}

}
