package org.example.smalljava.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.example.smalljava.smallJava.SJProgram
import org.example.smalljava.smallJava.SmallJavaPackage
import org.example.smalljava.validation.SmallJavaValidator
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(SmallJavaInjectorProvider)
class SmallJavaValidatorTest {

	@Inject extension ParseHelper<SJProgram>
	@Inject extension ValidationTestHelper

	@Test def void testClassHierarchyCycle() {
		'''
			class A extends C {}
			class C extends B {}
			class B extends A {}
		'''.parse => [
			assertHierarchyCycle("A")
			assertHierarchyCycle("B")
			assertHierarchyCycle("C")
		]
	}

	@Test def void testNoHierarchyCycle() {
		'''
			class A extends C {}
			class C extends B {}
			class B {}
		'''.parse.assertNoErrors
	}

	@Test def void testInvocationOnField() {
		'''
			class A {
			  A f;
			  A m() {
			    return this.f();
			  }
			}
		''' => [
			parse.assertError(
				SmallJavaPackage.eINSTANCE.SJMemberSelection,
				SmallJavaValidator.METHOD_INVOCATION_ON_FIELD,
				lastIndexOf("("),
				1, // check error position
				"Method invocation on a field"
			)
		]
	}

	@Test def void testFieldSelectionOnMethod() {
		'''
			class A {
			  A m() {
			    return this.m;
			  }
			}
		''' => [
			parse.assertError(
				SmallJavaPackage.eINSTANCE.SJMemberSelection,
				SmallJavaValidator.FIELD_SELECTION_ON_METHOD,
				lastIndexOf("m"),
				1, // check error position
				"Field selection on a method"
			)
		]
	}

	@Test def void testCorrectMemberSelection() {
		'''
			class A {
			  A f;
			  A m() {
			    A v = this.f;
			      return this.m();
			  }
			}
		'''.parse.assertNoErrors
	}

	@Test def void testUnreachableCode() {
		'''
			class C {
			  C m() {
			    return null;
			    this.m(); // the error should be placed here
			  }
			}
		'''.parse.assertError(
			SmallJavaPackage.eINSTANCE.SJMemberSelection,
			SmallJavaValidator.UNREACHABLE_CODE,
			"Unreachable code"
		)
	}

	@Test def void testUnreachableCode2() {
		'''
			class C {
			  C m() {
			    return null;
			    C i = null;
			    this.m();
			  }
			}
		'''.parse.assertError(
			SmallJavaPackage.eINSTANCE.SJVariableDeclaration,
			SmallJavaValidator.UNREACHABLE_CODE,
			"Unreachable code"
		)
	}

	@Test def void testUnreachableCodeOnlyOnce() {
		'''
			class C {
			  C m() {
			    return null;
			    C i = null; // error only here
			    return null;
			    return null; // no error here
			  }
			}
		'''.parse => [
			assertError(
				SmallJavaPackage.eINSTANCE.SJVariableDeclaration,
				SmallJavaValidator.UNREACHABLE_CODE,
				"Unreachable code"
			)
			1.assertEquals(validate.size)
		]
	}

	@Test def void testUnreachableCodeInsideIf() {
		'''
			class C {
			  C m() {
			    if (true) {
			      return null;
			      C i = null;
			      this.m();
			    }
			  }
			}
		'''.parse.assertError(
			SmallJavaPackage.eINSTANCE.SJVariableDeclaration,
			SmallJavaValidator.UNREACHABLE_CODE,
			"Unreachable code"
		)
	}

	@Test def void testNoUnreachableCode() {
		'''
			class C {
			  C m() {
			    this.m();
			    return null;
			  }
			}
		'''.parse.assertNoErrors
	}

	def private void assertHierarchyCycle(SJProgram p, String expectedClassName) {
		p.assertError(
			SmallJavaPackage.eINSTANCE.SJClass,
			SmallJavaValidator.HIERARCHY_CYCLE,
			"cycle in hierarchy of class '" + expectedClassName + "'"
		)
	}

}
