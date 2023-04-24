package org.example.entities.tests

import com.google.inject.Inject
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.xbase.lib.util.ReflectExtensions
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

@ExtendWith(InjectionExtension)
@InjectWith(EntitiesInjectorProvider)
class EntitiesGeneratorTest {

	@Inject extension CompilationTestHelper
	@Inject extension ReflectExtensions

	@Test
	def void testGeneratedCode() {
		'''
			entity MyEntity {
			  string myAttribute;
			}
		'''.assertCompilesTo(
			'''
				package entities;
				
				public class MyEntity {
					private String myAttribute;
				
					public String getMyAttribute() {
						return myAttribute;
					}
				
					public void setMyAttribute(String _arg) {
						this.myAttribute = _arg;
					}
				
				}
			'''
		)
	}

	@Test
	def void testGeneratedJavaCodeIsValid() {
		'''
			entity MyEntity {
			  string myAttribute;
			}
		'''.compile [
			getCompiledClass
		]
	}

	@Test
	def void testGeneratedJavaCode() {
		'''
			entity E {
			  string myAttribute;
			}
		'''.compile [
			getCompiledClass.getDeclaredConstructor().newInstance => [
				Assertions.assertNull(it.invoke("getMyAttribute"))
				it.invoke("setMyAttribute", "value")
				Assertions.assertEquals("value", it.invoke("getMyAttribute"))
			]
		]
	}

	@Test
	def void testGeneratedCodeWithTwoEntites() {
		'''
			entity FirstEntity {
			  SecondEntity myAttribute;
			}
			
			entity SecondEntity { }
		'''.compile [
			Assertions.assertEquals('''
				package entities;
				
				public class FirstEntity {
					private SecondEntity myAttribute;
				
					public SecondEntity getMyAttribute() {
						return myAttribute;
					}
				
					public void setMyAttribute(SecondEntity _arg) {
						this.myAttribute = _arg;
					}
				
				}
			'''.toString, getGeneratedCode("entities.FirstEntity"))
			Assertions.assertEquals('''
				package entities;
				
				public class SecondEntity {
				
				}
			'''.toString, getGeneratedCode("entities.SecondEntity"))
		]
	}

	@Test def void testGeneratedJavaCodeWithTwoClasses() {
		'''
			entity FirstEntity {
			  SecondEntity myAttribute;
			}
			
			entity SecondEntity {
			  string s;
			}
		'''.compile [
			val FirstEntity = getCompiledClass("entities.FirstEntity").getDeclaredConstructor().newInstance
			val SecondEntity = getCompiledClass("entities.SecondEntity").getDeclaredConstructor().newInstance
			SecondEntity.invoke("setS", "testvalue")
			FirstEntity.invoke("setMyAttribute", SecondEntity)
			Assertions.assertSame(SecondEntity, FirstEntity.invoke("getMyAttribute"))
			Assertions.assertEquals("testvalue", FirstEntity.invoke("getMyAttribute").invoke("getS"))
		]
	}

	@Test
	def void testInputWithValidationError() {
		Assertions.assertThrows(IllegalStateException, [
			'''
				entity MyEntity {
					// missing ;
					string myAttribute
				}
			'''.compile [
				val allErrors = getErrorsAndWarnings.filter[severity == Severity.ERROR]
				if (!allErrors.empty) {
					throw new IllegalStateException(
						"One or more resources contained errors : " + allErrors.map[toString].join(", ")
					);
				}
			]
		], "Missed expected the IllegalStateException exception.");
	}

}
