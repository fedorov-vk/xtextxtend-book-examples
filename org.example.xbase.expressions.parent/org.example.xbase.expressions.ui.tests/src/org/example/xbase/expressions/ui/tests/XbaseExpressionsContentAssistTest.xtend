package org.example.xbase.expressions.ui.tests

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.ui.testing.AbstractContentAssistTest
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

@ExtendWith(InjectionExtension)
@InjectWith(ExpressionsUiInjectorProvider)
class XbaseExpressionsContentAssistTest extends AbstractContentAssistTest {

	@Test
	def void testEmptyProgram() {
		newBuilder.assertProposal("val")
	}

	@Test
	def void testEvalArgument() {
		newBuilder.append("val myVar = 0; eval ").assertProposal("myVar")
	}

}
