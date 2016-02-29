package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will print a small table for pages like 
				Job Detail.

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

public class JobStatusSmallTableTag extends TagSupport {

	private String jobId;
	private String tableWidth = "100%";
	private boolean isVendor;
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null;

		try {
			conn = DBConnect.getConnection();
			StringBuffer query1 = new StringBuffer("select jfs.shownstatus, ");
			query1.append((isVendor)?"jfs.consolereseller":"jfs.consolecustomer");
			query1.append(" from jobs j, jobflowstates jfs where jfs.statusnumber = j.status_id and j.id = ");
			query1.append(jobId);
			
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery(query1.toString());

			StringBuffer output = new StringBuffer();
			
			while (rs1.next()) {
				output.append("<table border=\"0\" cellpadding=\"5\" cellspacing=\"0\" width=\"");
				output.append(tableWidth);
				output.append("\">\n");
				output.append("  <tr>\n");
				output.append("    <td class=\"tableheader\">Job Status</td>\n");
				output.append("    <td class=\"tableheader\">Next Action</td>\n");
				output.append("  </tr>\n");
				output.append("  <tr>\n");
				output.append("    <td class=\"lineitems\" align=\"center\">");
				output.append(rs1.getString(1));
				output.append("&nbsp;</td>\n");
				output.append("    <td class=\"lineitems\" align=\"center\">");
				output.append(rs1.getString(2));
				output.append("&nbsp;</td>\n");
				output.append("  </tr>\n");
				output.append("</table>");
			}
			
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
	public final  void setIsVendor(boolean temp){
		this.isVendor = temp;
	}
	public final  void setJobId(String temp){
		this.jobId = temp;
	}
	public final  void setTableWidth(String temp){
		this.tableWidth = temp;
	}
}
