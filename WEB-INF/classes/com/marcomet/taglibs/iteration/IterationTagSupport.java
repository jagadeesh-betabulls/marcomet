package com.marcomet.taglibs.iteration;

import java.io.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public abstract class IterationTagSupport extends BodyTagSupport {

	protected FieldGetter fg = null;
	protected IterationSupport elementsList = null;
	protected Object current;

	public int doStartTag() throws JspException {

		fetchIterationSupport();

		if (elementsList.hasNext()) {
			
			//return EVAL_BODY_TAG;  //JSP 1.2 
			return	EVAL_BODY_BUFFERED;
		}

		return SKIP_BODY;

	}

	public void doInitBody() throws JspException {
		exportVariables();
	}

	public int doAfterBody() throws JspException {

		try {

			if (fg == null) {
				getBodyContent().writeOut(getPreviousOut());
			} else {
				populateFields();
			}

			getBodyContent().clear();

		} catch (IOException ex) {
			throw new JspException("doAfterBody error: " + ex.getMessage());
		}

		if (elementsList.hasNext()) {
			exportVariables();
			//return EVAL_BODY_TAG; //JSP 1.2 
			return EVAL_BODY_AGAIN;
		}

		return SKIP_BODY;

	}

	protected void populateFields() throws JspException {

		String field = null;
		try {

			Reader r = getBodyContent().getReader();
			JspWriter w = getPreviousOut();

			fg.setObject(current);

			int ch = r.read();
			while(-1 != ch) {

				if('<' == ch) {

					ch = r.read();
					if('$' == ch) {
						/* found a field reference */
						field = readFieldName(r);
						String p = fg.getField(field).toString();
						w.print(this.escapeHTML(p));
						ch = r.read();
					} else {
						w.write('<');
					}

				} else {

					w.write(ch);
					ch = r.read();
				}

			}

		} catch(IllegalAccessException ex) {
			throw new JspException("populateFields IllegalAccessException: " + ex.getMessage());
		} catch(IOException ex) {
			throw new JspException("populateFields IOException: " + ex.getMessage());
		}
	}

	protected String readFieldName(Reader r) throws JspException, IOException {

		StringBuffer sb = new StringBuffer();
		int ch = r.read();
		while (-1 != ch) {
			if ('$' == ch) {
				ch = r.read();
				if ('>' == ch) {
					/* found a field ending mark */
					return sb.toString().trim();
				} else {
					sb.append((char)ch);
				}
			} else {
				sb.append((char)ch);
				ch = r.read();
			}

		}

		throw new JspException("readFieldName field not terminated error");

	}

	protected abstract void fetchIterationSupport() throws JspException;

	protected void exportVariables() throws JspException {

		current = elementsList.getNext();
		pageContext.setAttribute(id, current);

	}

	protected void clearProperties() {

		id = null;

	}

	protected void clearServiceState() {

		elementsList = null;
		current = null;
		fg = null;

	}

	protected String escapeHTML(String html) {

		if ((html.indexOf('<') == -1) && (html.indexOf('>') == -1) && (html.indexOf('&') == -1)) {
			return html;
		}

		int length = html.length();
		StringBuffer sb = new StringBuffer(length);
		for (int i=0; i<length; i++) {
			char c = html.charAt(i);
			if (c == '<') {
				sb.append("&lt;");
			} else if (c == '>') {
				sb.append("&gt;");
			} else if (c == '&') {
				sb.append("&amp;");
			} else {
				sb.append(c);
			}
		}

		return sb.toString();

	}
}
