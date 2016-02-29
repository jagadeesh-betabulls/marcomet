package com.marcomet.taglibs.iteration;

public interface FieldGetter {

	public void setObject(Object o) throws IllegalArgumentException;

	public Object getField(String fieldName) throws IllegalAccessException;

}
