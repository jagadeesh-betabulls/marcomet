/**********************************************************************
Description:	This class will create a drop down for many types on 
				forms, reguardless of table 

History:
	Date		Author			Description
	----		------			-----------
	9/24/2001	Thomas Dietrich	Created

**********************************************************************/

package com.marcomet.taglibs;


import com.marcomet.jdbc.*;
import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;


public class GenericDropDownTag extends TagSupport {

	private String dropDownName = "";
	private String extra = "";
	private String orderBy = "id";
	private String returnId = "id";
	private String returnValue = "";
	private String selected = "";	
	private String table = "";
	
	

	public final void setDropDownName(String temp){
		dropDownName = temp;
	}
	public final void setExtra(String temp){         //for onChange stuff
		extra = temp;
	}	
	public final void setOrderBy(String temp){
		orderBy = temp;
	}	
	public final void setReturnId(String temp){
		returnId = temp;
	}
	public final void setReturnValue(String temp){
		returnValue = temp;
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
	
	
	
	public final int doEndTag() throws JspException {

		
		Connection conn = null;
		StringBuffer sql1 = new StringBuffer();
			
		try {
			
			conn = DBConnect.getConnection();
			sql1.append("SELECT ");
			sql1.append(returnId);
			sql1.append(",");
			sql1.append(returnValue);
			sql1.append(" FROM ");
			sql1.append(table);
			sql1.append(" order by ");
			sql1.append(orderBy);
			
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery(sql1.toString());
			StringBuffer output = new StringBuffer();
			
			output.append("<select name=\"");
			output.append(dropDownName);
			output.append("\" ");
			output.append(extra);
			output.append(" >");
			
			
			while (rs1.next()) {
				output.append("<OPTION value=\"");
				output.append(rs1.getString(returnId));
				output.append("\"");
				if(rs1.getString(returnId).equals(selected)){
					output.append(" selected ");
				}	
				output.append(">");
				output.append(rs1.getString(returnValue));
				output.append("</OPTION>\">");			
			}
			output.append("</select>");			
			
			pageContext.getOut().println(output);
					
		} catch (IOException ex) {
			throw new JspException(ex.getMessage());	
		} catch (SQLException ex) {
			throw new JspException(ex.getMessage());
		} catch (Exception e) {
			throw new JspException(e.getMessage());	
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return EVAL_PAGE;
	}
	public final void release() {
		super.release();
	}
}
