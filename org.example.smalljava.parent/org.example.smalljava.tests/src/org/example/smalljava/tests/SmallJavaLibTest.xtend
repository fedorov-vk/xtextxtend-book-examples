package org.example.smalljava.tests

import org.eclipse.xtext.testing.extensions.InjectionExtension
import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.example.smalljava.SmallJavaLib
import org.example.smalljava.smallJava.SJProgram

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(SmallJavaInjectorProvider)
class SmallJavaLibTest {

	@Inject extension ParseHelper<SJProgram>
	@Inject extension ValidationTestHelper
	@Inject extension SmallJavaLib
	@Inject Provider<ResourceSet> rsp

	@Test def void testImplicitImports() {
		'''
			class C extends Object {
			  String s;
			  Integer i;
			  Object m(Object o) { return null; }
			  }
		'''.loadLibAndParse.assertNoErrors
	}

	def private loadLibAndParse(CharSequence p) {
		val resourceSet = rsp.get
		loadLib(resourceSet)
		p.parse(resourceSet)
	}

}