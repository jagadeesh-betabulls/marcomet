package com.marcomet.taglibs.iteration;

import java.util.Iterator;
import javax.servlet.jsp.JspException;

class IteratorIterationSupport implements IterationSupport {

	Iterator i = null;

	IteratorIterationSupport(Iterator i) {
		this.i = i;
	}

	public boolean hasNext() throws JspException {
		return i.hasNext();
	}

	public Object getNext() throws JspException {
		return i.next();
	}

}
