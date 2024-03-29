package org.example.smalljava.tests

import com.google.inject.Inject
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.xbase.lib.util.ReflectExtensions
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.eclipse.xtext.xbase.testing.CompilationTestHelper.Result
import org.eclipse.xtext.xbase.testing.TemporaryFolder
import org.example.smalljava.SmallJavaLib
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(SmallJavaInjectorProvider)
class SmallJavaGeneratorTest {

	@Inject public TemporaryFolder temporaryFolder
	@Inject extension CompilationTestHelper
	@Inject extension ReflectExtensions
	@Inject SmallJavaLib smallJavaLib

	@Test
	def void testEmptyProgram() {
		'''
		'''.compile[]
	}

	@Test
	def void testGeneratedCodeWithoutPackage() {
		'''
			class C {
				C f;
			}
		'''.assertCompilesTo(
			'''
				public class C {
					private C f;
				}
			'''
		)
	}

	@Test
	def void testGeneratedCodeWithPackage() {
		'''
			package my.pack;
			class C {
				C f;
			}
		'''.assertCompilesTo(
			'''
				package my.pack;
				
				public class C {
					private my.pack.C f;
				}
			'''
		)
	}

	@Test
	def void testGeneratedCodeWithMethods() {
		'''
			package my.pack;
			class C {
				C f;
				C m(C p1, C p2) {
					p1 = p2 = p1;
					C aVar = p1;
					if (true)
						this.f = new C();
					if (false)
						this.m(p2, p1);
					else
						this.f = null;
					return new C();
				}
			}
		'''.compile [
			'''
				package my.pack;
				
				public class C {
					private my.pack.C f;
					private my.pack.C m(my.pack.C p1, my.pack.C p2) {
						p1 = p2 = p1;
						my.pack.C aVar = p1;
						if (true)
							{
								this.f = new my.pack.C();
							}
						if (false)
							{
								this.m(p2, p1);
							}
						else
							{
								this.f = null;
							}
						return new my.pack.C();
					}
				}
			'''.toString.assertEquals(
				getGeneratedCode("my.pack.C")
			)
			getCompiledClass
		]
	}

	@Test
	def void testGeneratedCodeWithLibrary() {
		val rs = resourceSet("My.smalljava" -> '''
			package my.pack;
			class D {}
			class C extends D {
				String aString;
				Integer aInt;
				Boolean aBool;
				Object anObj;
				Object m() {
					this.aString = "foo";
					this.aInt = 0;
					this.aBool = true;
					String s = null;
					Integer i = null;
					if (false)
						this.anObj = s;
					else
						this.anObj = i;
					return this.anObj;
				}
			}
		''')
		smallJavaLib.loadLib(rs)

		compile(rs) [
			'''
				package my.pack;
				
				public class C extends my.pack.D {
					private String aString;
					private Integer aInt;
					private Boolean aBool;
					private Object anObj;
					private Object m() {
						this.aString = "foo";
						this.aInt = 0;
						this.aBool = true;
						String s = null;
						Integer i = null;
						if (false)
							{
								this.anObj = s;
							}
						else
							{
								this.anObj = i;
							}
						return this.anObj;
					}
				}
			'''.toString.assertEquals(
				getGeneratedCode("my.pack.C")
			)
			getCompiledClass
		]
	}

	@Test
	def void testGeneratedCodeWithLibraryAndInheritedObjectMethods() {
		val rs = resourceSet("My.smalljava" -> '''
			package my.pack;
			class C {
				Object m() {
					return this.toString().toString();
				}
			}
		''')
		smallJavaLib.loadLib(rs)

		compile(rs) [
			checkNoValidationErrors
			'''
				package my.pack;
				
				public class C {
					private Object m() {
						return this.toString().toString();
					}
				}
			'''.toString.assertEquals(
				getGeneratedCode("my.pack.C")
			)
			getCompiledClass
		]
	}

	@Test
	def void testGeneratedCodeWithSuper() {
		val rs = resourceSet("My.smalljava" -> '''
			package my.pack;
			class C {
				public String toString() {
					return super.toString();
				}
			}
		''')
		smallJavaLib.loadLib(rs)

		compile(rs) [
			checkNoValidationErrors
			'''
				package my.pack;
				
				public class C {
					public String toString() {
						return super.toString();
					}
				}
			'''.toString.assertEquals(
				getGeneratedCode("my.pack.C")
			)
			getCompiledClass
		]
	}

	@Test
	def void testGeneratedJavaCodeIsValid() {
		'''
			package my.pack;
			
			class C {
				C f;
			}
		'''.compile [
			getCompiledClass
		]
	}

	@Test
	def void testGeneratedJavaCode() {
		'''
			class C {
				C m() {
					return new C();
				}
			}
		'''.compile [
			getCompiledClass.getDeclaredConstructor().newInstance => [
				assertNotNull(it.invoke("m"))
				assertEquals("class C", it.invoke("m").invoke("getClass").toString)
			]
		]
	}

	@Test def void testGeneratedCodeWithTwoClasses() {
		'''
			package my.pack;
			
			class C {
				D m() {
					return new D();
				}
			}
			
			class D {
				
			}
		'''.compile [
			'''
				package my.pack;
				
				public class C {
					private my.pack.D m() {
						return new my.pack.D();
					}
				}
			'''.toString.assertEquals(getGeneratedCode("my.pack.C"))

			'''
				package my.pack;
				
				public class D {
				}
			'''.toString.assertEquals(getGeneratedCode("my.pack.D"))
		]
	}

	@Test def void testGeneratedJavaCodeWithTwoClasses() {
		'''
			package my.pack;
			
			class C {
				D m() {
					return new D();
				}
			}
			
			class D {
				
			}
		'''.compile [
			val C = getCompiledClass("my.pack.C").getDeclaredConstructor().newInstance
			assertEquals("class my.pack.D", C.invoke("m").invoke("getClass").toString)
		]
	}

	@Test def void testClassesInTheSamePackageInDifferentFiles() {
		compile(#['''
			package my.pack;
			
			class B {}
			class C {}
		''', '''
			package my.pack;
			
			class D {
			  C c;
			}
		''']) [
			'''
				package my.pack;
				
				public class D {
					private my.pack.C c;
				}
			'''.toString.assertEquals(getGeneratedCode("my.pack.D"))
			getCompiledClass
		]
	}

	@Test
	def void testInputWithValidationError() {
		Assertions.assertThrows(IllegalStateException, [
			'''
				class MyEntity {
					// missing ;
					string myAttribute
				}
			'''.compile [
				checkNoValidationErrors(it)
			]
		], "Missed expected the IllegalStateException exception.");
	}

	protected def void checkNoValidationErrors(Result it) {
		val allErrors = getErrorsAndWarnings.filter[severity == Severity.ERROR]
		if (!allErrors.empty) {
			throw new IllegalStateException(
				"One or more resources contained errors : " + allErrors.map[toString].join(", ")
			);
		}
	}

}
