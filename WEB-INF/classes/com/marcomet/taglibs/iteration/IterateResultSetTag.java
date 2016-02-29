package com.marcomet.taglibs.iteration;

import java.sql.ResultSet;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.JspException;

public class IterateResultSetTag extends IterateTag {

	protected void fetchIterationSupport() throws JspException {
		Object o = getPointed();

		elementsList = new ResultSetIterationSupport((ResultSet)o);
		fg = new JDBCFieldGetter();

	}

}
