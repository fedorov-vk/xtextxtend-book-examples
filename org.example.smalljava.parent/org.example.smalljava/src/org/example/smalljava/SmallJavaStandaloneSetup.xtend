/*
 * generated by Xtext 2.29.0
 */
package org.example.smalljava


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
class SmallJavaStandaloneSetup extends SmallJavaStandaloneSetupGenerated {

	def static void doSetup() {
		new SmallJavaStandaloneSetup().createInjectorAndDoEMFRegistration()
	}
}
