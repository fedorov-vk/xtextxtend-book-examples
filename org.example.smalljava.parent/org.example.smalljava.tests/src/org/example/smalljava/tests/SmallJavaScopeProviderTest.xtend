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
import org.example.smalljava.smallJava.SJVariableDeclaration

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
			assertScope(SmallJavaPackage.eINSTANCE.SJMemberSelection_Member, "f, m, C.f, C.m")
			assertScope(SmallJavaPackage.eINSTANCE.SJSymbolRef_Symbol, "v, p")
		]
	}

	@Test def void testScopeProviderForSymbols() {
		'''
			class C {
			  A m(A p) {
			    A v1 = null;
			    if (true) {
			      A v2 = null;
			      A v3 = null;
			    }
			    A v4 = null;
			    return null;
			  }
			}
			class A {}
		'''.parse.classes.head.methods.last.body.eAllContents.filter(SJVariableDeclaration) => [
			findFirst[name == 'v3'].expression.assertScope(SmallJavaPackage.eINSTANCE.SJSymbolRef_Symbol, "v2, v1, p")
			findFirst[name == 'v4'].expression.assertScope(SmallJavaPackage.eINSTANCE.SJSymbolRef_Symbol, "v1, p")
		]
	}

	def private assertScope(EObject context, EReference reference, CharSequence expected) {
		expected.toString.assertEquals(context.getScope(reference).allElements.map[name].join(", "))
	}

}
