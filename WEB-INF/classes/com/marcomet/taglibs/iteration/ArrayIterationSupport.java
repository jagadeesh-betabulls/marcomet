package com.marcomet.taglibs.iteration;

import java.lang.reflect.Array;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;

class ArrayIterationSupport implements IterationSupport {

	protected Object a = null;
	protected int    pos = 0;

	ArrayIterationSupport(Object a) {
		this.a = a;
		this.pos = 0;
	}

	public boolean hasNext() throws JspException {
		return (pos < Array.getLength(a));
	}

	public Object getNext() throws JspException {

		if(hasNext()) {
			Object rc = null;
			rc = Array.get(a, pos);
			pos++;
			return rc;
		}

		throw new JspTagException();

	}

}
