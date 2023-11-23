package org.example.xbase.expressions.smoke.tests

import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.smoketest.ProcessedBy
import org.eclipse.xtext.xbase.testing.typesystem.TypeSystemSmokeTester
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.junit.platform.suite.api.IncludeClassNamePatterns
import org.junit.platform.suite.api.SelectPackages
import org.junit.platform.suite.api.Suite
import org.junit.platform.suite.api.SuiteDisplayName

@ExtendWith(InjectionExtension)
@ProcessedBy(value=TypeSystemSmokeTester, processInParallel=true)

@Suite
@SuiteDisplayName("All Tests of Xbase Espressions")
@SelectPackages("org.example.xbase.expressions.tests")
@IncludeClassNamePatterns(".*Test")
class ExpressionsSmokeTest {

	@Test def void testFoo() {}

}
