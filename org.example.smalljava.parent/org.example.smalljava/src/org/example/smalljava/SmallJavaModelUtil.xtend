package org.example.smalljava

import org.example.smalljava.smallJava.SJBlock
import org.example.smalljava.smallJava.SJClass
import org.example.smalljava.smallJava.SJField
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

	def classHierarchy(SJClass c) {
		val visited = newLinkedHashSet()

		var current = c.superclass
		while (current !== null && !visited.contains(current)) {
			visited.add(current)
			current = current.superclass
		}

		visited
	}

}
