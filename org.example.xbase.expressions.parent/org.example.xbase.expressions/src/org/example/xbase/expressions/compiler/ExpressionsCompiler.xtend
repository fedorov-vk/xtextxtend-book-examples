package org.example.xbase.expressions.compiler

import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.compiler.XbaseCompiler
import org.eclipse.xtext.xbase.compiler.output.ITreeAppendable
import org.example.xbase.expressions.expressions.EvalExpression

class ExpressionsCompiler extends XbaseCompiler {

	override protected doInternalToJavaStatement(XExpression obj, ITreeAppendable a, boolean isReferenced) {
		if (obj instanceof EvalExpression) {
			obj.expression.internalToJavaStatement(a, true)
			a.newLine
			if (isReferenced) {
				val name = a.declareSyntheticVariable(obj, "_eval")
				a.append('''String «name» = "" + ''')
				obj.expression.internalToJavaExpression(a)
				a.append(";")
			} else {
				a.append('''System.out.println(''')
				obj.expression.internalToJavaExpression(a)
				a.append(");")
			}
		} else
			super.doInternalToJavaStatement(obj, a, isReferenced)
	}

	override protected internalToConvertedExpression(XExpression obj, ITreeAppendable a) {
		if (obj instanceof EvalExpression)
			a.append(getVarName(obj, a))
		else
			super.internalToConvertedExpression(obj, a)
	}

	override protected internalCanCompileToJavaExpression(XExpression e, ITreeAppendable a) {
		if (e instanceof EvalExpression)
			return false
		else
			super.internalCanCompileToJavaExpression(e, a)
	}

}
