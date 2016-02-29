/**********************************************************************
Description:	This class will create a drop down for many types on 
				forms.

History:
	Date		Author			Description
	----		------			-----------
	6/20/2001	Thomas Dietrich	Created

**********************************************************************/

package com.marcomet.taglibs;

import com.marcomet.jdbc.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;


public class LUDropDownTag extends TagSupport {

	private String selected = "";
	private String dropDownName = "";
	private String table = "";
	private String key = "id";
	private String extra = "";
	
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null;

		try {
			conn = DBConnect.getConnection();
			String sql1 = "select " + key + ", value from " + table + " order by sequence";
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery(sql1);
			StringBuffer output = new StringBuffer();
			
			output.append("<select name=\"");
			output.append(dropDownName);
			output.append("\" ");
			output.append(extra);
			output.append(" >");
			
			
			while (rs1.next()) {
				output.append("<OPTION value=\"");
				output.append(rs1.getString(key));
				output.append("\"");
				if(rs1.getString(key).equals(selected)){
					output.append(" selected ");
				}	
				output.append(">");
				output.append(rs1.getString("value"));
				output.append("</OPTION>\">");			
			}
			output.append("</select>");			
			
			pageContext.getOut().println(output);
					
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
	public final  void release() {
		super.release();
	}
	public final  void setDropDownName(String temp){
		dropDownName = temp;
	}
	public final  void setExtra(String temp){         //for onChange stuff
		extra = temp;
	}
	public final  void setKey(String temp){
		key = temp;
	}
	public final  void setSelected(int temp) {
		setSelected(temp+"");
	}
	public final  void setSelected(String temp){
		selected = temp;
	}
	public final  void setTable(String temp){
		table = temp;
	}
}
