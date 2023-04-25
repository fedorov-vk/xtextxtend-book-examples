package org.example.smalljava.tests

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.example.smalljava.scoping.SmallJavaIndex
import org.example.smalljava.smallJava.SJProgram
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(SmallJavaInjectorProvider)
class SmallJavaIndexTest {

	@Inject extension ParseHelper<SJProgram>
	@Inject extension SmallJavaIndex

	@Test def void testExportedEObjectDescriptions() {
		'''
			class C {
			  A f;
			  A m(A p) {
			    A v = null;
			    return null;
			  }
			}
			class A {}
		'''.parse.assertExportedEObjectDescriptions("C, C.f, C.m, C.m.p, C.m.v, A")
		// before SmallJavaResourceDescriptionsStrategy the output was
		// "C, C.f, C.m, C.m.p, C.m.v, A"
	}

	def private assertExportedEObjectDescriptions(EObject o, CharSequence expected) {
		expected.toString.assertEquals(
			o.getExportedEObjectDescriptions.map[qualifiedName].join(", ")
		)
	}

}
