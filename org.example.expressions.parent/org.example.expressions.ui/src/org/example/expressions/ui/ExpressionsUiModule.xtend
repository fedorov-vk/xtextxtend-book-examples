/*
 * generated by Xtext 2.29.0
 */
package org.example.expressions.ui

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.ui.editor.hover.IEObjectHoverProvider
import org.example.expressions.ui.hover.ExpressionsEObjectHoverProvider

/**
 * Use this class to register components to be used within the Eclipse IDE.
 */
@FinalFieldsConstructor
class ExpressionsUiModule extends AbstractExpressionsUiModule {
	def Class<? extends IEObjectHoverProvider> bindIEObjectHoverProvider() {
		return ExpressionsEObjectHoverProvider
	}
}
