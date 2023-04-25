package org.example.smalljava.typing

import com.google.inject.Inject
import org.example.smalljava.SmallJavaModelUtil
import org.example.smalljava.smallJava.SJClass

import static org.example.smalljava.typing.SmallJavaTypeComputer.*

class SmallJavaTypeConformance {

	@Inject extension SmallJavaModelUtil

	def isConformant(SJClass c1, SJClass c2) {
		c1 === NULL_TYPE || // null can be assigned to everything
		c1 === c2 || c1.isSubclassOf(c2)
	}

	def isSubclassOf(SJClass c1, SJClass c2) {
		c1.classHierarchy.contains(c2)
	}

}
