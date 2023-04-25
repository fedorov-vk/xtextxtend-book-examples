package org.example.smalljava

import com.google.inject.Inject
import org.example.smalljava.smallJava.SJBlock
import org.example.smalljava.smallJava.SJClass
import org.example.smalljava.smallJava.SJField
import org.example.smalljava.smallJava.SJMember
import org.example.smalljava.smallJava.SJMethod
import org.example.smalljava.smallJava.SJReturn

class SmallJavaModelUtil {

	def fields(SJClass c) {
		c.members.filter(SJField)
	}

	def methods(SJClass c) {
		c.members.filter(SJMethod)
	}

	def returnStatement(SJMethod m) {
		m.body.returnStatement
	}

	def returnStatement(SJBlock block) {
		block.statements.filter(SJReturn).head
	}

}
