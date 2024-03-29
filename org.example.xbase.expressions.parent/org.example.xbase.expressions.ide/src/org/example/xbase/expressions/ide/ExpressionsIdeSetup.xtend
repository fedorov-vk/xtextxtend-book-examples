/*
 * generated by Xtext 2.29.0
 */
package org.example.xbase.expressions.ide

import com.google.inject.Guice
import org.eclipse.xtext.util.Modules2
import org.example.xbase.expressions.ExpressionsRuntimeModule
import org.example.xbase.expressions.ExpressionsStandaloneSetup

/**
 * Initialization support for running Xtext languages as language servers.
 */
class ExpressionsIdeSetup extends ExpressionsStandaloneSetup {

	override createInjector() {
		Guice.createInjector(Modules2.mixin(new ExpressionsRuntimeModule, new ExpressionsIdeModule))
	}
	
}
