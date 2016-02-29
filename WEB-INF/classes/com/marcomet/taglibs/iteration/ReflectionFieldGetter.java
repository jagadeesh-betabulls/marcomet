package com.marcomet.taglibs.iteration;

import java.beans.IntrospectionException;
import java.lang.reflect.InvocationTargetException;

public class ReflectionFieldGetter implements FieldGetter {

	protected Object o;

	public void setObject(Object o) throws IllegalArgumentException {
		this.o = o;
	}

	public Object getField(String fieldName) throws IllegalAccessException {

		try {
			return BeanUtil.getObjectPropertyValue(o, fieldName, null);
		} catch(InvocationTargetException ex) {
			// Fall through
		} catch(IllegalAccessException ex) {
			// Fall through
		} catch(IntrospectionException ex) {
			// Fall through
		} catch(NoSuchMethodException ex) {
			// Fall through
		}

		throw new IllegalAccessException("Can not access field: " + fieldName);

	}

}
