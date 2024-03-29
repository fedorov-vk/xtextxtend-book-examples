/*
 * generated by Xtext 2.29.0
 */
package org.example.library

import com.google.inject.Injector
import org.eclipse.emf.ecore.EPackage

/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
class LibraryStandaloneSetup extends LibraryStandaloneSetupGenerated {

	def static void doSetup() {
		new LibraryStandaloneSetup().createInjectorAndDoEMFRegistration()
	}

	override register(Injector injector) {
		if (!EPackage.Registry.INSTANCE.containsKey(LibraryPackage.eNS_URI)) {
			EPackage.Registry.INSTANCE.put(LibraryPackage.eNS_URI, LibraryPackage.eINSTANCE);
		}
		super.register(injector)
	}

}
