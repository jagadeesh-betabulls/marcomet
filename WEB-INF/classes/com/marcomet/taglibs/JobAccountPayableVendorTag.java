package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will print an accounts payable information 
				 table to the vendor, for pages like Job Details.

History:
	Date		Author			Description
	----		------			-----------
	7/5/2001	Thomas Dietrich	Created

**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;
import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class JobAccountPayableVendorTag extends TagSupport {

	private String jobId;
	private String tableWidth = "100%";
	
	public final int doEndTag() throws JspException {

		
		Connection conn = null;
		FormaterTool formater = new FormaterTool();
		
		try {
			conn = DBConnect.getConnection();
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery("SELECT payable, paid_to_vendor, balance_to_vendor FROM jobs WHERE id = " + jobId);
		
			StringBuffer output = new StringBuffer("<table border=\"0\" width=\"");
			output.append(tableWidth);
			output.append("\">");
			output.append("<tr><td class=\"tableheader\">Total Due to Vendor for Job</td>");
			output.append("<td class=\"tableheader\">Amount Payable to Vendor from Escrow Released</td>");
			output.append("<td class=\"tableheader\">Amount Paid to Vendor</td><td class=\"tableheader\">Balance due to Vendor</td></tr>");
			
			while (rs1.next()){  
				output.append("<tr><td  class=\"body\" align=\"right\">");
				output.append(formater.getCurrency(rs1.getDouble("balance_to_vendor") + rs1.getDouble("paid_to_vendor"))); //rs1.getDouble("payable")
				output.append("</td><td class=\"body\" align=\"right\">");
				output.append(formater.getCurrency(rs1.getDouble("paid_to_vendor")));
				output.append("</td><td class=\"body\" align=\"right\">");
				output.append(formater.getCurrency(rs1.getDouble("paid_to_vendor")));
				output.append("</td><td class=\"body\" align=\"right\">");
				output.append(formater.getCurrency(rs1.getDouble("balance_to_vendor")));
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
	public final void release() {
		super.release();
	}
	public final void setJobId(String temp){
		this.jobId = temp;
	}
	public final void setTableWidth(String temp){
		this.tableWidth = temp;
	}
}
