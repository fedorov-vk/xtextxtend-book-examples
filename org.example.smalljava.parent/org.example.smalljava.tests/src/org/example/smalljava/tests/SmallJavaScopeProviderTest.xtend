package org.example.smalljava.tests

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.IScopeProvider
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.example.smalljava.SmallJavaModelUtil
import org.example.smalljava.smallJava.SJProgram
import org.example.smalljava.smallJava.SmallJavaPackage
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(SmallJavaInjectorProvider)
class SmallJavaScopeProviderTest {

	@Inject extension ParseHelper<SJProgram>
	@Inject extension IScopeProvider
	@Inject extension SmallJavaModelUtil

	@Test def void testScopeProvider() {
		'''
			class C {
			  A f;
			  A m(A p) {
			    A v = null;
			    return null; // return's expression is the context
			  }
			}
			class A {}
		'''.parse.classes.head.methods.last.returnStatement.expression => [
			// THIS WILL FAIL when we customize scoping in the next sections
			assertScope(SmallJavaPackage.eINSTANCE.SJMemberSelection_Member, "f, m, C.f, C.m")
			assertScope(SmallJavaPackage.eINSTANCE.SJSymbolRef_Symbol, "p, v, m.p, m.v, C.m.p, C.m.v")
		]
	}

	def private assertScope(EObject context, EReference reference, CharSequence expected) {
		expected.toString.assertEquals(context.getScope(reference).allElements.map[name].join(", "))
	}

}
