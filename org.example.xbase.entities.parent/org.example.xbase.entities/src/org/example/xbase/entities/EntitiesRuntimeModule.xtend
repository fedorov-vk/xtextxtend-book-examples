/*
 * generated by Xtext 2.29.0
 */
package org.example.xbase.entities

import org.example.xbase.entities.validation.EntitiesConfigurableIssueCodes

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class EntitiesRuntimeModule extends AbstractEntitiesRuntimeModule {

	override bindConfigurableIssueCodesProvider() {
		EntitiesConfigurableIssueCodes
	}

}
