package org.example.smalljava.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.example.smalljava.smallJava.SJProgram
import org.example.smalljava.typing.SmallJavaTypeConformance
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static org.example.smalljava.typing.SmallJavaTypeComputer.*

import static extension org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(SmallJavaInjectorProvider)
class SmallJavaTypeConformanceTest {

	@Inject extension ParseHelper<SJProgram>
	@Inject extension SmallJavaTypeConformance

	@Test def void testClassConformance() {
		'''
			class A {}
			class B extends A {}
			class C {}
			class D extends B {}
		'''.parse.classes => [
			// A subclass of A
			get(0).isConformant(get(0)).assertTrue
			// B subclass of A
			get(1).isConformant(get(0)).assertTrue
			// C not subclass of A
			get(2).isConformant(get(0)).assertFalse
			// D subclass of A
			get(3).isConformant(get(0)).assertTrue
			// null's type is conformant to any type
			NULL_TYPE.isConformant(get(0)).assertTrue
		]
	}

}