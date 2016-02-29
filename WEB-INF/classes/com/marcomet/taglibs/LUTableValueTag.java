package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will translate the ids of lu tables to a value

History:
	Date		Author			Description
	----		------			-----------
	6/20/2001	Thomas Dietrich	Created

**********************************************************************/

import com.marcomet.jdbc.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;


public class LUTableValueTag extends TagSupport {

	private String selected = "";
	private String table = "";
	
	
	public final int doEndTag() throws JspException {

		
		Connection conn = null;

		try {
			conn = DBConnect.getConnection();
			String sql1 = "select value from " + table + " where id = " + selected;
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery(sql1);
			
			if(rs1.next()){
				pageContext.getOut().println(rs1.getString("value"));
			}else{
				pageContext.getOut().println("");	
			}
					
					
		} catch (IOException ex) {
			throw new JspException(ex.getMessage());	
		} catch (SQLException ex) {
			throw new JspException(ex.getMessage());
		} catch (Exception x) {
			throw new JspException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return EVAL_PAGE;
	}
	public final void release() {
		super.release();
	}
	public final void setSelected(int temp) {
		setSelected(temp+"");
	}
	public final void setSelected(String temp){
		selected = temp;
	}
	public final void setTable(String temp){
		table = temp;
	}
}
