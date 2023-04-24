package org.example.expressions.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.eclipse.xtext.xbase.testing.TemporaryFolder
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

@ExtendWith(InjectionExtension)
@InjectWith(typeof(ExpressionsInjectorProvider))
class ExpressionsGeneratorTest {

	// @TempDir
	@Inject public TemporaryFolder temporaryFolder

	@Inject extension CompilationTestHelper

	@Test def void testEvaluateExpressions() {
		'''
			var i = 0
			
			var j = (i >0 && 1 < (i+1))
			
			eval j || true
			
			eval (1 + 10) < (2 * (3 + 5))
			
			eval (1 + 10) < (2 / (3 * 2))
		'''.assertCompilesTo(
			'''
			var i = 0 ~> 0
			var j = (i >0 && 1 < (i+1)) ~> false
			eval j || true ~> true
			eval (1 + 10) < (2 * (3 + 5)) ~> true
			eval (1 + 10) < (2 / (3 * 2)) ~> false'''
		)
	}

}
