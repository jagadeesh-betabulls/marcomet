package com.marcomet.taglibs.iteration;

import java.util.*;
import javax.servlet.jsp.*;
import java.beans.IntrospectionException;
import java.lang.reflect.InvocationTargetException;

public class IterateTag extends IterationTagSupport {

	protected Object obj = null;
	protected String objName = null;
	protected String objScope = null;
	protected String property = null;
	protected String index = null;

	public void setType(String type) {
		// Unused, needed only for the translation phase
	}

	public void setObject(Object o) {
		this.obj = o;
	}

	public void setName(String name) {
		this.objName = name;
	}

	public void setScope(String scope) {
		this.objScope = scope;
	}

	public void setProperty(String property) {
		this.property = property;
	}

	public void setIndex(String index) {
		this.index = index;
	}

	protected void fetchIterationSupport() throws JspException {

		Object o = getPointed();

		if (o instanceof Iterator) {
			elementsList = new IteratorIterationSupport((Iterator)o);
		} else if (o instanceof Enumeration) {
			elementsList = new EnumerationIterationSupport((Enumeration)o);
		} else if (o.getClass().isArray()) {
			elementsList = new ArrayIterationSupport(o);
		} else {
			throw new JspTagException("fetchIterationSupport can't iterate over object: " + o.getClass());
		}

		fg = new ReflectionFieldGetter();

	}

	protected Object getPointed() throws JspException {

		Object value = (null == obj ? getPointedObject(objName, objScope) : obj);
		if (null != property) {
			value = getPointedProperty(value);
		}

		return value;

	}

	protected Object getPointedObject(String name, String scope) throws JspException {

		Object rc = null;
		if (scope != null) {
			rc = pageContext.getAttribute(name, translateScope(scope));
		} else {
			rc = pageContext.findAttribute(name);
		}

		if (rc == null) {
			throw new JspTagException("getPointedObject No such Object: " + name);
		}

		return rc;

	}

	protected int translateScope(String scope) throws JspException {

		if (scope.equalsIgnoreCase("page")) {
			return PageContext.PAGE_SCOPE;
		} else if (scope.equalsIgnoreCase("request")) {
			return PageContext.REQUEST_SCOPE;
		} else if (scope.equalsIgnoreCase("session")) {
			return PageContext.SESSION_SCOPE;
		} else if (scope.equalsIgnoreCase("application")) {
			return PageContext.APPLICATION_SCOPE;
		}

		// No such scope, this is probably an error maybe the
		// TagExtraInfo associated with thit tag was not configured
		// signal that by throwing a JspException
		throw new JspTagException("translateScope no such scope: " + scope);
	}

	protected Object getPointedProperty(Object v) throws JspException {

		try {

			Object indexParam = null;
			if(null != index) {
				if(index.startsWith("#")) {
					/* this is a number */
					indexParam = new Integer(index.substring(1));
				} else {
					/* this is a simple String */
					indexParam = index;
				}
			}

			return BeanUtil.getObjectPropertyValue(v, property, indexParam);

		} catch(InvocationTargetException ex) {
			throw new JspTagException("getPointedPropert InvocationTargetException: " + ex.getMessage());
		} catch(IllegalAccessException ex) {
			throw new JspTagException("getPointedPropert IllegalAccessException: " + ex.getMessage());
		} catch(IntrospectionException ex) {
			throw new JspTagException("getPointedPropert IntrospectionException: " + ex.getMessage());
		} catch(NoSuchMethodException ex) {
			throw new JspTagException("getPointedPropert NoSuchMethodException: " + ex.getMessage());
		}
	}

	protected void clearProperties() {
		obj      = null;
		objName  = null;
		objScope = null;
		property = null;
		index    = null;
		super.clearProperties();
	}

}
