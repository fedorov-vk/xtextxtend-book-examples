package org.example.smalljava.typing

import com.google.inject.Inject
import org.example.smalljava.smallJava.SJAssignment
import org.example.smalljava.smallJava.SJBoolConstant
import org.example.smalljava.smallJava.SJClass
import org.example.smalljava.smallJava.SJExpression
import org.example.smalljava.smallJava.SJIntConstant
import org.example.smalljava.smallJava.SJMemberSelection
import org.example.smalljava.smallJava.SJMethod
import org.example.smalljava.smallJava.SJNew
import org.example.smalljava.smallJava.SJNull
import org.example.smalljava.smallJava.SJReturn
import org.example.smalljava.smallJava.SJStringConstant
import org.example.smalljava.smallJava.SJSymbolRef
import org.example.smalljava.smallJava.SJThis
import org.example.smalljava.smallJava.SJVariableDeclaration
import org.example.smalljava.smallJava.SmallJavaFactory
import org.example.smalljava.smallJava.SmallJavaPackage

import static extension org.eclipse.xtext.EcoreUtil2.*

class SmallJavaTypeComputer {

	static val factory = SmallJavaFactory.eINSTANCE
	public static val STRING_TYPE = factory.createSJClass => [name = 'stringType']
	public static val INT_TYPE = factory.createSJClass => [name = 'intType']
	public static val BOOLEAN_TYPE = factory.createSJClass => [name = 'booleanType']
	public static val NULL_TYPE = factory.createSJClass => [name = 'nullType']

	def SJClass typeFor(SJExpression e) {
		switch (e) {
			SJNew: e.type
			SJSymbolRef: e.symbol.type
			SJMemberSelection: e.member.type
			SJAssignment: e.left.typeFor
			SJThis: e.getContainerOfType(SJClass)
			SJNull: NULL_TYPE
			SJStringConstant: STRING_TYPE
			SJIntConstant: INT_TYPE
			SJBoolConstant: BOOLEAN_TYPE
		}
	}

	def isPrimitive(SJClass c) {
		c.eResource === null
	}

}
