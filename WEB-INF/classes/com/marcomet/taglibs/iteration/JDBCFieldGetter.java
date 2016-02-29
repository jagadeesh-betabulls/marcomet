package com.marcomet.taglibs.iteration;

import java.sql.ResultSet;
import java.sql.SQLException;

public class JDBCFieldGetter implements FieldGetter {


	protected ResultSet rs;

	public void setObject(Object o) throws IllegalArgumentException {

		if(!(o instanceof ResultSet)) {
			throw new IllegalArgumentException("Not a ResultSet");
		}

		this.rs = (ResultSet)o;

	}

	public Object getField(String fieldName) throws IllegalAccessException {

		try {
			return rs.getObject(fieldName);
		} catch(SQLException ex) {
		}

		throw new IllegalAccessException("SQL Exception");

	}

}
