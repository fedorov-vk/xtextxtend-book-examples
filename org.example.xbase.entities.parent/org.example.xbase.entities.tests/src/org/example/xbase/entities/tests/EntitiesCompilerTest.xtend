package org.example.xbase.entities.tests

import com.google.inject.Inject
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.xbase.lib.util.ReflectExtensions
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.eclipse.xtext.xbase.testing.CompilationTestHelper.Result
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
	def void testAttributeGeneratedCode() {
		'''
			/* my entity */
			entity MyEntity {
				/* my attribute */
				attr e = new MyEntity; // type is inferred
			}
		'''.assertCompilesTo(
		'''
			package entities;
			
			/**
			 * my entity
			 */
			@SuppressWarnings("all")
			public class MyEntity {
			  /**
			   * my attribute
			   */
			  private MyEntity e = new MyEntity();
			  
			  public MyEntity getE() {
			    return this.e;
			  }
			  
			  public void setE(final MyEntity e) {
			    this.e = e;
			  }
			  
			  public String toString() {
			    return
			    	"entity MyEntity {\n" +
			    		"\te = " + e.toString() + "\n" +
			    	"}";
			  }
			}
		''')
	}

	@Test
	def void testGenericSuperType() {
		'''
			entity MyList extends java.util.LinkedList<Iterable<String>>  {
			}
		'''.assertCompilesTo(
		'''
			package entities;
			
			import java.util.LinkedList;
			
			@SuppressWarnings("all")
			public class MyList extends LinkedList<Iterable<String>> {
			  public String toString() {
			    return
			    	"entity MyList {\n" +
			    	"}";
			  }
			}
		''')
	}

	@Test
	def void testValidGeneratedJavaCode() {
		'''
			entity MyEntity {
				attr e = new MyEntity;
			}
		'''.compile[compiledClass]
	}

	@Test
	def void testAnnotations() {
		'''
			import com.google.inject.Inject
			
			@SuppressWarnings("rawtypes")
			entity MyEntity {
				@Inject
				attr MyEntity e;
			}
		'''.compile [
			'''
				package entities;
				
				import com.google.inject.Inject;
				
				@SuppressWarnings("rawtypes")
				public class MyEntity {
				  @Inject
				  private MyEntity e;
				  
				  public MyEntity getE() {
				    return this.e;
				  }
				  
				  public void setE(final MyEntity e) {
				    this.e = e;
				  }
				  
				  public String toString() {
				    return
				    	"entity MyEntity {\n" +
				    		"\te = " + e.toString() + "\n" +
				    	"}";
				  }
				}
			'''.toString.assertEquals(singleGeneratedCode)
			checkValidationErrors
			compiledClass
		]
	}

	@Test
	def void testGeneratedToString() {
		'''
		entity C {
			attr l = newArrayList(1, 2, 3);
			attr s = "test";
		}'''.assertCompilesTo(
			'''
				package entities;
				
				import java.util.ArrayList;
				import org.eclipse.xtext.xbase.lib.CollectionLiterals;
				
				@SuppressWarnings("all")
				public class C {
				  private ArrayList<Integer> l = CollectionLiterals.<Integer>newArrayList(Integer.valueOf(1), Integer.valueOf(2), Integer.valueOf(3));
				  
				  public ArrayList<Integer> getL() {
				    return this.l;
				  }
				  
				  public void setL(final ArrayList<Integer> l) {
				    this.l = l;
				  }
				  
				  private String s = "test";
				  
				  public String getS() {
				    return this.s;
				  }
				  
				  public void setS(final String s) {
				    this.s = s;
				  }
				  
				  public String toString() {
				    return
				    	"entity C {\n" +
				    		"\tl = " + l.toString() + "\n" +
				    		"\ts = " + s.toString() + "\n" +
				    	"}";
				  }
				}
			'''
		)
	}

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

	private def void checkValidationErrors(Result it) {
		val allErrors = getErrorsAndWarnings.filter[severity == Severity.ERROR]
		if (!allErrors.empty) {
			throw new IllegalStateException(
				"One or more resources contained errors : " + allErrors.map[toString].join(", ")
			);
		}
	}

}
