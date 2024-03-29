/*
 * generated by Xtext 2.29.0
 */
package org.example.entities.formatting2

import com.google.inject.Inject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.example.entities.entities.AttributeType
import org.example.entities.entities.Entity
import org.example.entities.entities.Model
import org.example.entities.services.EntitiesGrammarAccess

import static org.example.entities.entities.EntitiesPackage.Literals.*

class EntitiesFormatter extends AbstractFormatter2 {

	@Inject extension EntitiesGrammarAccess

	def dispatch void format(Model model, extension IFormattableDocument document) {
		val lastEntity = model.entities.last
		for (entity : model.entities) {
			entity.format
			if (entity === lastEntity)
				entity.append[setNewLines(1)]
			else
				entity.append[setNewLines(2)]
		}
	}

	def dispatch void format(Entity entity, extension IFormattableDocument document) {
		entity.regionFor.keyword("extends").surround[oneSpace]
		entity.regionFor.feature(ENTITY__NAME).surround[oneSpace]
		entity.regionFor.feature(ENTITY__SUPER_TYPE).surround[oneSpace]

		val open = entity.regionFor.keyword("{")
		val close = entity.regionFor.keyword("}")
		open.append[newLine]
		interior(open, close)[indent]

		for (attribute : entity.attributes) {
			attribute.type.format(document)
			attribute.regionFor.keyword(";").surround[noSpace]
			attribute.append[setNewLines(1, 1, 2)]
		}
	}

	def dispatch void format(AttributeType attributeType, extension IFormattableDocument document) {
		if (!attributeType.array) {
			attributeType.elementType.append[oneSpace]
		} else {
			attributeType.regionFor.keyword("[").surround[noSpace]
			attributeType.regionFor.keyword("]").prepend[noSpace].append[oneSpace]
		}
	}

}
