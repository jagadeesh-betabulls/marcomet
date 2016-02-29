package com.marcomet.taglibs.iteration;

import javax.servlet.jsp.JspException;

public interface IterationSupport  {

	public boolean hasNext() throws JspException;

	public Object getNext() throws JspException;

}
