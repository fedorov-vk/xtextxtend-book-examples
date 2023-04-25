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
import org.eclipse.emf.ecore.EClass

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

	@Test def void testMissingFinalReturn() {
		'''
			class C {
			  C m() {
			    this.m();
			  }
			}
		'''.parse.assertError(
			SmallJavaPackage.eINSTANCE.SJMethod,
			SmallJavaValidator.MISSING_FINAL_RETURN,
			"Method must end with a return statement"
		)
	}

	@Test def void testDuplicateClasses() {
		'''
			class C {}
			class C {}
		'''.toString.assertDuplicate(SmallJavaPackage.eINSTANCE.SJClass, "class", "C")
	}

	@Test def void testDuplicateFields() {
		'''
			class C {
			  C f;
			  C f;
			}
		'''.toString.assertDuplicate(SmallJavaPackage.eINSTANCE.SJField, "field", "f")
	}

	@Test def void testDuplicateMethods() {
		'''
			class C {
			  C m() { return null; }
			  C m() { return null; }
			}
		'''.toString.assertDuplicate(SmallJavaPackage.eINSTANCE.SJMethod, "method", "m")
	}

	@Test def void testDuplicateParams() {
		'''
			class C {
			  C m(C p, C p) { return null; }
			}
		'''.toString.assertDuplicate(SmallJavaPackage.eINSTANCE.SJParameter, "parameter", "p")
	}

	@Test def void testDuplicateVariables() {
		'''
			class C {
			  C m() {
			    C v = null;
			    if (true)
			      C v = null;
			    return null;
			  }
			}
		'''.toString.assertDuplicate(SmallJavaPackage.eINSTANCE.SJVariableDeclaration, "variable", "v")
	}

	@Test def void testFieldAndMethodWithTheSameNameAreOK() {
		'''
			class C {
			  C f;
			  C f() { return null; }
			}
		'''.parse.assertNoErrors
	}

	@Test def void testVariableDeclExpIncompatibleTypes() {
		"A v = new C();".assertIncompatibleTypes(SmallJavaPackage.eINSTANCE.SJNew, "A", "C")
	}

	@Test def void testReturnExpIncompatibleTypes() {
		"return new C();".assertIncompatibleTypes(SmallJavaPackage.eINSTANCE.SJNew, "A", "C")
	}

	@Test def void testArgExpIncompatibleTypes() {
		"this.m(new C());".assertIncompatibleTypes(SmallJavaPackage.eINSTANCE.SJNew, "A", "C")
	}

	@Test def void testIfExpressionIncompatibleTypes() {
		"if (new C()) { return null; } ".assertIncompatibleTypes(
			SmallJavaPackage.eINSTANCE.SJNew,
			"booleanType",
			"C"
		)
	}

	@Test def void testAssignmentIncompatibleTypes() {
		"A v = null; v = new C();".assertIncompatibleTypes(
			SmallJavaPackage.eINSTANCE.SJNew,
			"A",
			"C"
		)
	}

	@Test def void testInvalidNumberOfArgs() {
		'''
			class A {}
			class B {}
			class C {
				C m(A a, B b) { return this.m(new B()); }
			}
		'''.parse.assertError(
			SmallJavaPackage.eINSTANCE.SJMemberSelection,
			SmallJavaValidator.INVALID_ARGS,
			'''Invalid number of arguments: expected 2 but was 1'''
		)
	}

	def private void assertHierarchyCycle(SJProgram p, String expectedClassName) {
		p.assertError(
			SmallJavaPackage.eINSTANCE.SJClass,
			SmallJavaValidator.HIERARCHY_CYCLE,
			"cycle in hierarchy of class '" + expectedClassName + "'"
		)
	}

	def private void assertDuplicate(String input, EClass type, String desc, String name) {
		input.parse => [
			// check that the error is on both duplicates
			assertError(
				type,
				SmallJavaValidator.DUPLICATE_ELEMENT,
				input.indexOf(name),
				name.length,
				"Duplicate " + desc + " '" + name + "'"
			)
			assertError(
				type,
				SmallJavaValidator.DUPLICATE_ELEMENT,
				input.lastIndexOf(name),
				name.length,
				"Duplicate " + desc + " '" + name + "'"
			)
		]
	}

	def private void assertIncompatibleTypes(CharSequence methodBody, EClass c, String expectedType,
		String actualType) {
		'''
			class A {}
			class B extends A {}
			class C {
			  A f;
			  A m(A p) {
			    «methodBody»
			  }
			}
		'''.parse.assertError(
			c,
			SmallJavaValidator.INCOMPATIBLE_TYPES,
			"Incompatible types. Expected '" + expectedType + "' but was '" + actualType + "'"
		)
	}

}
