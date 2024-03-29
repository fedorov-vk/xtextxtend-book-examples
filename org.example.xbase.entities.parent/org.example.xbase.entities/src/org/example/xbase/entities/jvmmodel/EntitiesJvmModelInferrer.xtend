/*
 * generated by Xtext 2.29.0
 */
package org.example.xbase.entities.jvmmodel

import com.google.inject.Inject
import java.util.List
import org.eclipse.xtext.common.types.JvmAnnotationTarget
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.common.types.JvmTypeParameter
import org.eclipse.xtext.common.types.JvmTypeParameterDeclarator
import org.eclipse.xtext.xbase.annotations.xAnnotations.XAnnotation
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import org.example.xbase.entities.entities.Entity

/**
 * <p>Infers a JVM model from the source model.</p>
 * 
 * <p>The JVM model should contain all elements that would appear in the Java code
 * which is generated from the source model. Other models link against the JVM model rather than the source model.</p>
 */
class EntitiesJvmModelInferrer extends AbstractModelInferrer {

	/**
	 * convenience API to build and initialize JVM types and their members.
	 */
	@Inject extension JvmTypesBuilder

	/**
	 * The dispatch method {@code infer} is called for each instance of the
	 * given element's type that is contained in a resource.
	 * 
	 * @param entity
	 *            the model to create one or more
	 *            {@link JvmDeclaredType declared
	 *            types} from.
	 * @param acceptor
	 *            each created
	 *            {@link JvmDeclaredType type}
	 *            without a container should be passed to the acceptor in order
	 *            get attached to the current resource. The acceptor's
	 *            {@link IJvmDeclaredTypeAcceptor#accept(org.eclipse.xtext.common.types.JvmDeclaredType)
	 *            accept(..)} method takes the constructed empty type for the
	 *            pre-indexing phase. This one is further initialized in the
	 *            indexing phase using the lambda you pass as the last argument.
	 * @param isPreIndexingPhase
	 *            whether the method is called in a pre-indexing phase, i.e.
	 *            when the global index is not yet fully updated. You must not
	 *            rely on linking using the index if isPreIndexingPhase is
	 *            <code>true</code>.
	 */
	def dispatch void infer(Entity entity, IJvmDeclaredTypeAcceptor acceptor, boolean isPreIndexingPhase) {
		acceptor.accept(entity.toClass("entities." + entity.name)) [
			copyTypeParameters(entity.typeParameters)
			documentation = entity.documentation
			if (entity.superType !== null)
				superTypes += entity.superType.cloneWithProxies
			translateAnnotations(entity.annotations)
			for (a : entity.attributes) {
				val type = a.type ?: a.initexpression?.inferredType
				members += a.toField(a.name, type) [
					if (a.extension) {
						annotations += annotationRef(Extension)
					}
					translateAnnotations(a.annotations)
					documentation = a.documentation
					if (a.initexpression !== null)
						initializer = a.initexpression
				]
				members += a.toGetter(a.name, type)
				members += a.toSetter(a.name, type)
			}
			for (op : entity.operations) {
				members += op.toMethod(op.name, op.type ?: inferredType) [
					documentation = op.documentation
					for (p : op.params) {
						parameters += p.toParameter(p.name, p.parameterType)
					}
					body = op.body
				]
			}
			members += entity.toMethod("toString", typeRef(String)) [
				body = '''
					return
						"entity «entity.name» {\n" +
							«FOR a : entity.attributes»
								"\t«a.name» = " + «a.name».toString() + "\n" +
							«ENDFOR»
						"}";
				'''
			]
		]
	}

	def private void translateAnnotations(JvmAnnotationTarget target, Iterable<XAnnotation> annotations) {
		target.addAnnotations(annotations.filterNull.filter[annotationType !== null])
	}

	def private void copyTypeParameters(JvmTypeParameterDeclarator target, List<JvmTypeParameter> typeParameters) {
		for (typeParameter : typeParameters) {
			target.typeParameters += typeParameter.cloneWithProxies
		}
	}

}
