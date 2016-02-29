package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will print a changes table for pages like 
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

public class JobChangesTag extends TagSupport {

	private String jobId;
	private String tableWidth = "100%";
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null;

		try {
			conn = DBConnect.getConnection();
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery("select DATE_FORMAT(jc.createddate,'%m/%d/%y') 'createddate', jct.text 'changetype', ljcs.value 'status', DATE_FORMAT(jc.customerdate,'%m/%d/%y') 'customerdate', jc.reason 'reason' from jobchanges jc, jobchangetypes jct, lu_job_change_statuses ljcs where jc.statusid = ljcs.id and jc.changetypeid = jct.id and jc.jobid = " + jobId + " order by createddate");
		
			StringBuffer output = new StringBuffer("<table border=\"0\" width=\"");
			output.append(tableWidth);
			output.append("\">");
			
			while (rs1.next()){  
	   			output.append("<tr><td class=\"label\"><u>Proposed: ");
				output.append(rs1.getString("createddate"));
				output.append(" as ");
				output.append(rs1.getString("changetype"));
				output.append("&nbsp;&nbsp;&nbsp;&nbsp;");
				output.append(rs1.getString("status"));
				output.append(": ");
				output.append(rs1.getString("customerdate"));
				output.append(" </u></td></tr><tr><td colspan=\"11\">&nbsp;</td></tr>");
				output.append("<tr><td class=\"label\"><u>Description:</u> ");
				output.append(rs1.getString("reason"));
				output.append("</td></tr><tr><td colspan=\"11\">&nbsp;</td></tr>");
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
