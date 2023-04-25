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
import org.example.smalljava.smallJava.SJMemberSelection
import org.example.smalljava.smallJava.SJMethod

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

	@Test def void testFieldScoping() {
		'''
			class A {
			  D a;
			  D b;
			  D c;
			}
			
			class B extends A {
			  D b;
			}
			
			class C extends B {
			  D a;
			  D m() { return this.a; }
			  D n() { return this.b; }
			  D p() { return this.c; }
			}
			class D {}
		'''.parse.classes => [
			// a in this.a must refer to C.a
			get(2).fields.get(0).assertSame(get(2).methods.get(0).returnExpSel.member)
			// b in this.b must refer to B.b
			get(1).fields.get(0).assertSame(get(2).methods.get(1).returnExpSel.member)
			// c in this.c must refer to A.c
			get(0).fields.get(2).assertSame(get(2).methods.get(2).returnExpSel.member)
		]
	}

	@Test def void testFieldsAndMethodsWithTheSameName() {
		'''
			class C {
			  A f;
			  A f() {
			    return this.f(); // must refer to method f
			  }
			  A m() {
			    return this.m; // must refer to field m
			  }
			  A m;
			}
			class A {}
		'''.parse.classes.head => [
			// must refer to method f()
			methods.head.assertSame(methods.head.returnExpSel.member)
			// must refer to field m
			fields.last.assertSame(methods.last.returnExpSel.member)
		]
	}

	def private returnExpSel(SJMethod m) {
		m.returnStatement.expression as SJMemberSelection
	}

	def private assertScope(EObject context, EReference reference, CharSequence expected) {
		expected.toString.assertEquals(context.getScope(reference).allElements.map[name].join(", "))
	}

}
