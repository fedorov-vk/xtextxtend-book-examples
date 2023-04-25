package org.example.smalljava.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.example.smalljava.SmallJavaModelUtil
import org.example.smalljava.smallJava.SJExpression
import org.example.smalljava.smallJava.SJProgram
import org.example.smalljava.smallJava.SJStatement
import org.example.smalljava.typing.SmallJavaTypeComputer
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(SmallJavaInjectorProvider)
class SmallJavaTypeComputerTest {

	@Inject extension ParseHelper<SJProgram>
	@Inject extension SmallJavaTypeComputer
	@Inject extension SmallJavaModelUtil

	@Test def void thisType() {
		"this".assertType("C")
	}

	@Test def void paramRefType() {
		"p".assertType("P")
	}

	@Test def void varRefType() {
		"v".assertType("V")
	}

	@Test def void newType() {
		"new N()".assertType("N")
	}

	@Test def void fieldSelectionType() {
		"this.f".assertType("F")
	}

	@Test def void methodInvocationType() {
		"this.m(new P())".assertType("R")
	}

	@Test def void assignmentType() {
		"v = new P()".assertType("V")
	}

	@Test def void stringConstantType() {
		'"foo"'.assertType("stringType")
	}

	@Test def void intConstantType() {
		'10'.assertType("intType")
	}

	@Test def void boolConstantType() {
		'true'.assertType("booleanType")
	}

	@Test def void nullType() {
		'null'.assertType("nullType")
	}

	@Test def void testTypeForUnresolvedReferences() {
		'''
			class C {
				U m() {
					f ; // unresolved symbol
					this.n(); // unresolved method 
					this.f; // unresolved field
					return null;
				}
			}
		'''.parse => [
			classes.head.methods.head.body.statements => [
				get(0).statementExpressionType.assertNull
				get(1).statementExpressionType.assertNull
				get(2).statementExpressionType.assertNull
			]
		]
	}

	@Test def void testIsPrimitiveType() {
		'''
			class C {
				C m() {
					return true;
				}
			}
		'''.parse.classes.head => [
			it.isPrimitive.assertFalse
			methods.head.returnStatement.expression.typeFor.isPrimitive.assertTrue
		]
	}

	def private assertType(CharSequence testExp, String expectedClassName) {
		'''
			class R { }
			class P { }
			class V { }
			class N { }
			class F { }
			
			class C {
			  F f;
			
			  R m(P p) {
			    V v = null;
			    «testExp»;
			    return null;
			  }
			}
		'''.parse => [
			expectedClassName.assertEquals(
				classes.last.methods.last.body.statements.get(1).statementExpressionType.name
			)
		]
	}

	def private statementExpressionType(SJStatement s) {
		(s as SJExpression).typeFor
	}

}
