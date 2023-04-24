package org.example.expressions.ui.tests

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.ui.testing.AbstractContentAssistTest
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

@ExtendWith(InjectionExtension)
@InjectWith(ExpressionsUiInjectorProvider)
class ExpressionsContentAssistTest extends AbstractContentAssistTest {

	@Test def void testVariableReference() {
		newBuilder.append("var i = 10 eval 1+") //
		.assertText('!', '"Value"', '(', '+', '1', 'false', 'i', 'true')
	}

	@Test def void testForwardVariableReference() {
		newBuilder.append("eval var i = 10 ") //
		.assertTextAtCursorPosition(" ", '!', '"Value"', '(', 'eval')
		// i must not be present in proposals, before its definition
	}

	@Test def void testForwardVariableReference2() {
		newBuilder.append("var k = 0 var j=1 eval 1+  var i = 10") //
		//                                         ^
		.assertTextAtCursorPosition("+", 1, '!', '"Value"', '(', '+', '1', 'false', 'j', 'k', 'true')
		// i must not be present in proposals, before its definition
		// but j and k must be there
	}

}
