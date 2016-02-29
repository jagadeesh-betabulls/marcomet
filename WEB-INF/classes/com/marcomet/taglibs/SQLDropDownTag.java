/**********************************************************************
Description:	This class will create a drop down for many types on 
				forms, by using a query 

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


public class SQLDropDownTag extends TagSupport {

	//jdbc connections
	


	//tag varables
	private String dropDownName = "";
	private String extraCode = "";
	private String extraFirstOption = "";
	private String selected = "";
	private String sql = "";
	

	public final  void setDropDownName(String temp){
		dropDownName = temp;
	}
	public final  void setExtraCode(String temp){         //for onChange stuff
		extraCode = temp;
	}	
	public final  void setExtraFirstOption(String temp){
		extraFirstOption = temp;
	}	
	public final  void setSelected(int temp) {
		setSelected(temp+"");
	}
	public final  void setSelected(String temp){
		selected = temp;
	}
	public final  void setSql(String temp){
		sql = temp;
	}	
	
	
	
	public final  int doEndTag() throws JspException {

			
		Connection conn = null;
		
			
		try{
			conn = DBConnect.getConnection();		
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery(sql);
			StringBuffer output = new StringBuffer();
			
			output.append("<select name=\"");
			output.append(dropDownName);
			output.append("\" ");
			output.append(extraCode);
			output.append(" >");
			
			//first option user setable
			output.append(extraFirstOption);
			
			while (rs1.next()) {
				output.append("<OPTION value=\"");
				output.append(rs1.getString("value"));
				output.append("\"");
				if(rs1.getString("value").equals(selected)){
					output.append(" selected ");
				}	
				output.append(">");
				output.append(rs1.getString("text"));
				output.append("</OPTION>\">");			
			}
			output.append("</select>");			
			
			pageContext.getOut().println(output);
					
		} catch (Exception e) {
			throw new JspException(e.getMessage());	
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}	
		
		return EVAL_PAGE;
	}
	public final  void release() {
		super.release();
	}

	protected void finalize(){
		
	}	
}
