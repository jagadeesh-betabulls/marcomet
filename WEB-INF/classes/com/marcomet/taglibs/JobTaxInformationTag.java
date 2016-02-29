package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will print tax information on pages like 
				Job Details.

History:
	Date		Author			Description
	----		------			-----------
	7/3/2001	Thomas Dietrich	Created

**********************************************************************/

import com.marcomet.jdbc.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class JobTaxInformationTag extends TagSupport {

	private String jobId;
	private String tableWidth = "100%";
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null;

		try {
			conn = DBConnect.getConnection();
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery("select if(st.tax_job=1,'Yes','No') 'tax_job', if(st.tax_shipping=1,'Yes','No') 'tax_shipping', las.value 'entity', st.rate 'rate', if(st.buyer_exempt=1,'Yes','No') 'exempt' from sales_tax st, lu_abreviated_states las where las.id = st.entity and st.job_id = " + jobId);
		
			StringBuffer output = new StringBuffer("<table border=\"0\" width=\"");
			output.append(tableWidth);
			output.append("\">");
			
			while (rs1.next()){  
				output.append("<tr><td class=\"tableheader\">Tax Job</td><td class=\"tableheader\">");
				output.append("Tax Shipping</td><td class=\"tableheader\">State</td><td class=\"tableheader\">");
				output.append("Rate</td><td class=\"tableheader\">Client Exempt</td></tr>");
				output.append("<tr><td class=\"body\" align=\"right\">");
				output.append(rs1.getString("tax_job"));
				output.append("</td><td class=\"body\" align=\"right\">");
				output.append(rs1.getString("tax_shipping"));
				output.append("</td><td class=\"body\" align=\"right\">");
				output.append(rs1.getString("entity"));
				output.append("</td><td class=\"body\" align=\"right\">");
				output.append(rs1.getString("rate"));
				output.append("</td><td class=\"body\" align=\"right\">");
				output.append(rs1.getString("exempt"));
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
