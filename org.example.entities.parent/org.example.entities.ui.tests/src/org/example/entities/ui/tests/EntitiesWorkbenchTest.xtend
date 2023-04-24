package org.example.entities.ui.tests

import org.eclipse.core.resources.IResource
import org.eclipse.emf.ecore.EValidator
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.ui.XtextProjectHelper
import org.eclipse.xtext.ui.testing.AbstractWorkbenchTest
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.eclipse.xtext.ui.testing.util.IResourcesSetupUtil.*
import static extension org.eclipse.xtext.ui.testing.util.JavaProjectSetupUtil.*

@ExtendWith(InjectionExtension)
@InjectWith(EntitiesUiInjectorProvider)
class EntitiesWorkbenchTest extends AbstractWorkbenchTest {

	val TEST_PROJECT = "mytestproject"

	@BeforeEach
	override void setUp() {
		super.setUp
		createJavaProjectWithXtextNature
	}

	def void createJavaProjectWithXtextNature() {
		createJavaProject(TEST_PROJECT) => [
			getProject().addNature(XtextProjectHelper.NATURE_ID)
			addSourceFolder("entities-gen")
		]
	}

	def void checkEntityProgram(String contents, int expectedErrors) {
		val file = createFile(TEST_PROJECT + "/src/test.entities", contents)
		waitForBuild();
		Assertions.assertEquals(expectedErrors,
			file.findMarkers(EValidator.MARKER, true, IResource.DEPTH_INFINITE).size);
	}

	@Test
	def void testValidProgram() {
		checkEntityProgram("entity E {}", 0)
	}

	@Test
	def void testNotValidProgram() {
		checkEntityProgram("foo", 1)
	}

}
