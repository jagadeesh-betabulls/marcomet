package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will create a drop down for many types on 
				forms.

History:
	Date		Author			Description
	----		------			-----------
	8/14/01		Ed Cimafonte	Modified and renamed to allow for a custom 2nd field to hold 'value'

**********************************************************************/

import com.marcomet.jdbc.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;


public class LUCustomDropDownTag extends TagSupport {

	private String selected = "";
	private String dropDownName = "";
	private String table = "";
	private String key = "id";
	private String valueField = "";
	private String orderbyField = "sequence";
	private String extra = "";
	
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null;

		try {
			conn = DBConnect.getConnection();
			String sql1 = "select " + key + ", "+ valueField +" from " + table + " order by "+orderbyField;
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery(sql1);
			StringBuffer output = new StringBuffer();
			
			output.append("<select name=\"");
			output.append(dropDownName);
			output.append("\" ");
			output.append(extra);
			output.append(" >");
			output.append("<OPTION value=\"");
			output.append(0);
			output.append("\"");
			output.append(" selected ");	
			output.append(">");
			output.append("-Select-");
			output.append("</OPTION>\">");			
			
			while (rs1.next()) {
				output.append("<OPTION value=\"");
				output.append(rs1.getString(key));
				output.append("\"");
				if(rs1.getString(key).equals(selected)){
					output.append(" selected ");
				}	
				output.append(">");
				output.append(rs1.getString(valueField));
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
	public final  void setValueField(String temp){
		valueField = temp;
	}
	public final  void setOrderbyField(String temp){
		orderbyField = temp;
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
