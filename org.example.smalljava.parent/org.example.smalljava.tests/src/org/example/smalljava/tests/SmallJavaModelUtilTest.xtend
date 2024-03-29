package org.example.smalljava.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.example.smalljava.SmallJavaLib
import org.example.smalljava.SmallJavaModelUtil
import org.example.smalljava.smallJava.SJClass
import org.example.smalljava.smallJava.SJMemberSelection
import org.example.smalljava.smallJava.SJProgram
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(SmallJavaInjectorProvider)
class SmallJavaModelUtilTest {

	@Inject extension ParseHelper<SJProgram>
	@Inject extension SmallJavaModelUtil
	@Inject extension SmallJavaLib

	@Test
	def void testModelUtilMethodsByType() {
		'''
			class C {
				C f;
				C m() {
					if (true) {
						
					}
					return this.c;
				}
			}
		'''.parse.classes.head => [
			"f".assertEquals(fields.head.name)
			"m".assertEquals(methods.head.name)
			(methods.head.returnStatement.expression instanceof SJMemberSelection).assertTrue
		]
	}

	@Test def void testValidHierarchy() {
		'''
		class C {}
		
		class D extends C {}
		
		class E extends D {}'''.parse.classes => [
			get(0).assertHierarchy("")
			get(1).assertHierarchy("C")
			get(2).assertHierarchy("D, C")
		]
	}

	@Test def void testCyclicHierarchy() {
		'''
		class C extends E {}
		
		class D extends C {}
		
		class E extends D {}'''.parse.classes => [
			get(0).assertHierarchy("E, D, C")
			get(1).assertHierarchy("C, E, D")
			get(2).assertHierarchy("D, C, E")
		]
	}

	@Test def void testHierarchyMethods() {
		'''
			class C1 {
				C1 m() { return null; }
				C1 n() { return null; }
			}
			class C2 extends C1 {
				C1 m() { return null; } // this must override the one in C1
			}
			class C3 extends C2 {
			}
		'''.parse.classes.last => [
			"m -> C2, n -> C1".assertEquals(
				classHierarchyMethods.entrySet.map[key.toString + " -> " + (value.eContainer as SJClass).name].join(
					", ")
			)
		]
	}

	@Test def void testHierarchyMembers() {
		'''
			class C1 {
				C1 m;
				C1 m() { return null; }
				C1 n() { return null; }
				C1 n;
			}
			class C2 extends C1 {
				C1 f;
				C1 m() { return null; } // this must come before the one in C1
			}
			class C3 extends C2 {
			}
		'''.parse.classes.last => [
			"SJField f in C2, SJMethod m in C2, SJField m in C1, SJMethod m in C1, SJMethod n in C1, SJField n in C1".
				assertEquals(
					classHierarchyMembers.map [
						eClass.name + " " + name + " in " + (eContainer as SJClass).name
					].join(", ")
				)
		]
	}

	@Test def void testMemberAsStringWithType() {
		'''
			class A {}
			class B {}
			class C {
				A f;
				A m() { return null; }
				A n(B b, C c) { return null; }
				A p(Foo b, C c) { return null; }
			}
		'''.parse.classes.last => [
			methods => [
				"m() : A".assertEquals(get(0).memberAsStringWithType)
				"n(B, C) : A".assertEquals(get(1).memberAsStringWithType)
				"p(null, C) : A".assertEquals(get(2).memberAsStringWithType)
			]
			"f : A".assertEquals(fields.head.memberAsStringWithType)
		]
	}

	@Test def void testHierarchyMethodsWithLibraryObject() {
		val p = '''
			class C1 {
				C1 m() { return null; }
				// the following overrides the one from Object
				String toString() { return null; }
			}
			
			class C2 extends C1 {
				
			}
		'''.parse
		loadLib(p.eResource.resourceSet)
		p.classes.last => [
			"clone -> Object, toString -> C1, equals -> Object, m -> C1".assertEquals(
				classHierarchyMethods.entrySet.map[key.toString + " -> " + (value.eContainer as SJClass).name].join(
					", ")
			)
		]
	}

	def private assertHierarchy(SJClass c, CharSequence expected) {
		expected.toString.assertEquals(c.classHierarchy.map[name].join(", "))
	}
}
