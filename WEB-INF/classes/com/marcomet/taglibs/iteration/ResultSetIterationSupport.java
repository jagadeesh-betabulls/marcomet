package com.marcomet.taglibs.iteration;

import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;

class ResultSetIterationSupport implements IterationSupport {

	protected ResultSet rs = null;
	protected boolean nextAvailable = false;
	protected boolean nextAvailableValid = false;

	ResultSetIterationSupport(ResultSet rs) {
		this.rs = rs;
	}

	public boolean hasNext() throws JspException {

		if(nextAvailableValid) {
			return nextAvailable;
		}

		try {
			nextAvailable = rs.next();
			nextAvailableValid = true;
			return nextAvailable;
		} catch(SQLException ex) {
			throw new JspTagException("hasNext SQL Exception: " + ex.getMessage());
		}
	}

	public Object getNext() throws JspException {

		if(hasNext()) {
			nextAvailableValid = false;
			return rs;
		}

		throw new JspTagException("getNext error: no more rows");

	}

}
