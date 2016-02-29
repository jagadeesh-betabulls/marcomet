package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will print a small job spec table for pages like 
				Job Details.

History:
	Date		Author			Description
	----		------			-----------
	6/29/2001	Thomas Dietrich	Created

**********************************************************************/

import com.marcomet.jdbc.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class JobSpecsTag extends TagSupport {

	private String jobId;
	private String tableWidth = "100%";
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null;

		try {
			conn = DBConnect.getConnection();
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery("SELECT ls.value AS label, js.value AS value FROM job_specs js, lu_specs ls, catalog_specs cs WHERE ls.id != 88888 AND ls.id != 99999 AND ls.id = cs.spec_id AND cs.id = js.cat_spec_id AND js.job_id = " + jobId + " ORDER BY ls.sequence");
		
			StringBuffer output = new StringBuffer("<table border=\"0\" width=\"");
			output.append(tableWidth);
			output.append("\"><tr><td class=\"tableheader\">Specification</td><td class=\"tableheader\">Spec Value</td></tr>");
			
			while (rs1.next()){  
	   			output.append("<tr><td class=\"label\" width=30%>");
				output.append(rs1.getString("label"));
				output.append(":</td><td class=\"body\">");
				output.append(rs1.getString("value"));
				output.append("</td></tr>");
			}
			
			output.append("</table>");
			
			pageContext.getOut().print(output);
					
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
	public final  void setJobId(String temp){
		this.jobId = temp;
	}
	public final  void setTableWidth(String temp){
		this.tableWidth = temp;
	}
}
