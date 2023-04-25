/*
 * generated by Xtext 2.29.0
 */
package org.example.smalljava.ui.contentassist

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.viewers.StyledString
import org.example.smalljava.SmallJavaModelUtil
import org.example.smalljava.smallJava.SJClass
import org.example.smalljava.smallJava.SJMember

/**
 * See https://www.eclipse.org/Xtext/documentation/310_eclipse_support.html#content-assist
 * on how to customize the content assistant.
 */
class SmallJavaProposalProvider extends AbstractSmallJavaProposalProvider {

	@Inject extension SmallJavaModelUtil

	override getStyledDisplayString(EObject element, String qualifiedNameAsString, String shortName) {
		if (element instanceof SJMember) {
			new StyledString(element.memberAsStringWithType).append(
				new StyledString(" - " + (element.eContainer as SJClass).name, StyledString.QUALIFIER_STYLER))
		} else
			super.getStyledDisplayString(element, qualifiedNameAsString, shortName)
	}

}
