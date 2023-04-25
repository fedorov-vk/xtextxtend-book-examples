/*
 * generated by Xtext 2.29.0
 */
package org.example.smalljava.web

import com.google.inject.Guice
import com.google.inject.Injector
import org.eclipse.xtext.util.Modules2
import org.example.smalljava.SmallJavaRuntimeModule
import org.example.smalljava.SmallJavaStandaloneSetup
import org.example.smalljava.ide.SmallJavaIdeModule

/**
 * Initialization support for running Xtext languages in web applications.
 */
class SmallJavaWebSetup extends SmallJavaStandaloneSetup {
	
	override Injector createInjector() {
		return Guice.createInjector(Modules2.mixin(new SmallJavaRuntimeModule, new SmallJavaIdeModule, new SmallJavaWebModule))
	}
	
}
