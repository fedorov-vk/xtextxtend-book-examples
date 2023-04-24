package org.example.entities.ui.tests

import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.ui.XtextProjectHelper
import org.eclipse.xtext.ui.testing.AbstractEditorTest
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.concurrent.CancelableUnitOfWork
import org.example.entities.EntitiesModelUtil
import org.example.entities.entities.EntitiesFactory
import org.example.entities.entities.Model
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.eclipse.xtext.ui.testing.util.IResourcesSetupUtil.*
import static extension org.eclipse.xtext.ui.testing.util.JavaProjectSetupUtil.*

@ExtendWith(InjectionExtension)
@InjectWith(EntitiesUiInjectorProvider)
class EntitiesEditorTest extends AbstractEditorTest {

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

	override protected getEditorId() {
		"org.example.entities.Entities"
	}

	def createTestFile(String contents) {
		createFile(TEST_PROJECT + "/src/test.entities", contents)
	}

	@Test
	def void testEntitiesEditor() {
		createTestFile("entity E {}").openEditor
	}

	@Test
	def void testEntitiesEditorContents() {
		Assertions.assertEquals(
			"entity E {}",
			createTestFile("entity E {}").openEditor.document.get
		)
	}

	@Test
	def void testEntitiesEditorContentsAsModel() {
		Assertions.assertEquals(
			"E",
			createTestFile("entity E {}").openEditor.document.readOnly [
				// 'it' is an XtextResource
				contents.get(0) as Model
			].entities.get(0).name
		)
	}

	@Test
	def void testChangeContents() {
		val editor = createTestFile("entity E {}").openEditor

		editor.document.modify [
			val model = (contents.get(0) as Model)
			val currentEntity = model.entities.get(0)
			model.entities += EntitiesFactory.eINSTANCE.createEntity => [
				name = "Added"
				superType = currentEntity
			]
		]

		Assertions.assertEquals('''
			entity E {}
			
			entity Added extends E {
			}
		'''.toString, editor.document.get)
	}

	@Test
	def void testChangeContentsWithCancelable() {
		val editor = createTestFile("entity E {}").openEditor

		val unitOfWork = new CancelableUnitOfWork<Boolean, XtextResource>() {
			override exec(XtextResource it, CancelIndicator cancelIndicator) throws Exception {
				if (cancelIndicator.isCanceled)
					return false
				val model = (contents.get(0) as Model)
				val currentEntity = model.entities.get(0)
				model.entities += EntitiesFactory.eINSTANCE.createEntity => [
					name = "Added"
					superType = currentEntity
				]
			}
		}
		// simulate cancel
		unitOfWork.cancelIndicator = [true]
		editor.document.modify(unitOfWork)
		// since the unit of work has been canceled, there should be no change in the model
		Assertions.assertEquals("entity E {}".toString, editor.document.get)
		// simulate cancel false
		unitOfWork.cancelIndicator = [false]
		editor.document.modify(unitOfWork)
		// now there should be no change in the model
		Assertions.assertEquals('''
			entity E {}
			
			entity Added extends E {
			}
		'''.toString, editor.document.get)
	}

	@Test
	def void testAddEntity() {
		val editor = createTestFile(
  		'''
			entity E1 {}
			
			entity E2 {}
		''').openEditor

		editor.document.modify [
			EntitiesModelUtil.addEntityAfter(
				(contents.get(0) as Model).entities.get(0),
				"Added"
			)
		]
		Assertions.assertEquals('''
			entity E1 {}
			
			entity Added {
			}
			
			entity E2 {}
		'''.toString, editor.document.get)
	}

}
