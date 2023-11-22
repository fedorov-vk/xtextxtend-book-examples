package org.example.xbase.entities.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.xbase.lib.util.ReflectExtensions
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.eclipse.xtext.xbase.testing.TemporaryFolder
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(EntitiesInjectorProvider)
class EntitiesCompilerTest {

	// @TempDir
	@Inject public TemporaryFolder temporaryFolder

	@Inject extension CompilationTestHelper
	@Inject extension ReflectExtensions

	@Test
	def void testGeneratedToStringExecution() {
		'''
		entity C {
			attr l = newArrayList(1, 2, 3);
			attr s = "test";
		}'''.compile [
			val obj = it.compiledClass.getDeclaredConstructor().newInstance
			'''
			entity C {
				l = [1, 2, 3]
				s = test
			}'''.toString.assertEquals(obj.invoke("toString"))
		]
	}

}
