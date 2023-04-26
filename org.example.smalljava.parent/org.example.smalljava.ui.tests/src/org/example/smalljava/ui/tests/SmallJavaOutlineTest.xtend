package org.example.smalljava.ui.tests

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.ui.testing.AbstractOutlineTest
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

@ExtendWith(InjectionExtension)
@InjectWith(SmallJavaUiInjectorProvider)
class SmallJavaOutlineTest extends AbstractOutlineTest {

	override protected getEditorId() {
		"org.example.smalljava.SmallJava"
	}

	@Test
	def void testOutline() {
		'''
			class A {}
			class B {}
			
			class C {
				A f;
				A g;
				C n(A a, B b) { return null; }
				C m(C c) { return null; }
			}
		'''.assertAllLabels(
			'''
				A
				B
				C
				  f : A
				  g : A
				  n(A, B) : C
				  m(C) : C
			'''
		)
	}

}
