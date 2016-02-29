package com.marcomet.workflow.emailbodies;

/**********************************************************************
Description:	This class will be the interface for email bodies.

**********************************************************************/

import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;

import com.marcomet.files.MultipartRequest;

public interface EmailBodyInterface{

	public String getBody(MultipartRequest mr) throws SQLException;
	public String getBody(HttpServletRequest request) throws SQLException;
	public String getSubject();
}
