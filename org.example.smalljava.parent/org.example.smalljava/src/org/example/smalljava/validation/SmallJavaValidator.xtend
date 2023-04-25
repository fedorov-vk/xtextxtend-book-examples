/*
 * generated by Xtext 2.29.0
 */
package org.example.smalljava.validation

import com.google.inject.Inject
import org.eclipse.xtext.validation.Check
import org.example.smalljava.SmallJavaModelUtil
import org.example.smalljava.smallJava.SJClass
import org.example.smalljava.smallJava.SmallJavaPackage

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class SmallJavaValidator extends AbstractSmallJavaValidator {

	protected static val ISSUE_CODE_PREFIX = "org.example.smalljava.";
	public static val HIERARCHY_CYCLE = ISSUE_CODE_PREFIX + "HierarchyCycle";

	@Inject extension SmallJavaModelUtil

	@Check def checkClassHierarchy(SJClass c) {
		if (c.classHierarchy.contains(c)) {
			error(
				"cycle in hierarchy of class '" + c.name + "'",
				SmallJavaPackage.eINSTANCE.SJClass_Superclass,
				HIERARCHY_CYCLE,
				c.superclass.name
			)
		}
	}

}
