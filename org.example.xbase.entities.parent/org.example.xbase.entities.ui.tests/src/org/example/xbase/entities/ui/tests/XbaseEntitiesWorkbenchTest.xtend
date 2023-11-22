package org.example.xbase.entities.ui.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.ui.testing.AbstractWorkbenchTest
import org.example.testutils.EclipseTestUtils
import org.example.testutils.PDETargetPlatformUtils
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static org.eclipse.xtext.ui.testing.util.IResourcesSetupUtil.*
import static org.example.testutils.EclipseTestUtils.*

@ExtendWith(InjectionExtension)
@InjectWith(EntitiesUiInjectorProvider)
class XbaseEntitiesWorkbenchTest extends AbstractWorkbenchTest {

	@Inject extension EclipseTestUtils

	@BeforeAll
	def static void beforeClass() {
		// needed when building with Tycho, otherwise, dependencies
		// in the MANIFEST of the created project will not be visible
		PDETargetPlatformUtils.setTargetPlatform();
	}

	@BeforeEach
	override void setUp() {
		super.setUp
		createJavaPluginProjectWithXtextNature(
			#[
				"org.eclipse.xtext.xbase.lib",
				"com.google.inject"
			]
		)
	}

	@Test
	def void testErrorInGeneratedJavaCode() {
		createFile(
			TEST_PROJECT + "/src/test.xentities",
			'''
				import com.google.inject.Inject
						
				@Inject
				entity MyEntity {
					
				}
			'''
		)

		waitForBuild
		// one error in the generated Java file, and one in the original file
		assertErrors(
			'''
			Java problem: The annotation @Inject is disallowed for this location
			The annotation @Inject is disallowed for this location'''
		)
	}

}
