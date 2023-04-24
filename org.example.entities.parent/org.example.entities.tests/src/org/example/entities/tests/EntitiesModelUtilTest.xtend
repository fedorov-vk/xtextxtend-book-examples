package org.example.entities.tests

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.example.entities.EntitiesModelUtil
import org.example.entities.entities.EntitiesFactory
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

@ExtendWith(InjectionExtension)
@InjectWith(EntitiesInjectorProvider)
class EntitiesModelUtilTest {
	val factory = EntitiesFactory::eINSTANCE

	@Test
	def void testAddEntityAfter() {
		val e1 = factory.createEntity => [
			name = "First"
		]
		val e2 = factory.createEntity => [
			name = "Second"
		]
		val model = factory.createModel => [
			entities += e1
			entities += e2
		]

		Assertions.assertNotNull(EntitiesModelUtil.addEntityAfter(e1, "Added"))

		Assertions.assertEquals(3, model.entities.size)
		Assertions.assertEquals("First", model.entities.get(0).name)
		Assertions.assertEquals("Added", model.entities.get(1).name)
		Assertions.assertEquals("Second", model.entities.get(2).name)
	}

}
