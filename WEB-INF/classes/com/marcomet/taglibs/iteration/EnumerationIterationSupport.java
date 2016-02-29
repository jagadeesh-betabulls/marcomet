package com.marcomet.taglibs.iteration;

import java.util.Enumeration;
import javax.servlet.jsp.JspException;

class EnumerationIterationSupport implements IterationSupport {

	Enumeration e = null;

	EnumerationIterationSupport(Enumeration e) {
		this.e = e;
	}

	public boolean hasNext() throws JspException {
		return e.hasMoreElements();
	}

	public Object getNext() throws JspException {
		return e.nextElement();
	}

}
