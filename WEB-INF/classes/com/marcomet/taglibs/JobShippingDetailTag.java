package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will print a list of shipments table for pages like 
				Job Details.

History:
	Date		Author			Description
	----		------			-----------
	7/4/2001	Thomas Dietrich	Created

**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class JobShippingDetailTag extends TagSupport {

	private String jobId;
	private String tableWidth = "100%"; 
	private boolean isVendor;
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null; 
		FormaterTool formater = new FormaterTool();
		
		double totCost = 0;
		double totMu = 0;
		double totFee = 0;
		double totPrice = 0;

		try {
			conn = DBConnect.getConnection();
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery("SELECT DATE_FORMAT(date,'%m/%d/%y') 'date', reference,cost,mu,fee,price FROM shipping_data WHERE job_id = " + jobId);
		
			StringBuffer output = new StringBuffer("<table border=\"0\" width=\"");
			output.append(tableWidth);
			output.append("\"><tr><td class=\"tableheader\">Date</td><td class=\"tableheader\">Ref Tracking Number</td>");
			if(isVendor){
				output.append("<td class=\"tableheader\">Est. Cost</td><td class=\"tableheader\">Seller MU</td><td class=\"tableheader\">MC Fee</td>");
			}	
			output.append("<td class=\"tableheader\">Total</td></tr>");
			
			while (rs1.next()){
			
				totCost += rs1.getDouble("cost");
				totMu += rs1.getDouble("mu");
				totFee += rs1.getDouble("fee");
				totPrice += rs1.getDouble("price");
				  
				output.append("<tr><td class=\"body\" >");
				output.append(rs1.getString("date"));
				output.append("</td><td class=\"body\" >");
				output.append(rs1.getString("reference"));
				output.append("</td><td  class=\"body\"  align=\"right\">");
				if(isVendor){
					output.append(formater.getCurrency(rs1.getDouble("cost")));
					output.append("</td><td  class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs1.getDouble("mu")));
					output.append("</td><td  class=\"body\" align=\"right\">");
					output.append(formater.getCurrency(rs1.getDouble("fee")));
					output.append("</td><td  class=\"body\" align=\"right\">");
				}	
				output.append(formater.getCurrency(rs1.getDouble("price")));
				output.append("</td></tr>");		
				
			}
		
			//totals
			output.append("<tr><td class=\"label\" align=\"right\" colspan=\"2\">Job Total</td><td  class=\"Topborderlable\" align=\"right\">");
			if(isVendor){
				output.append(formater.getCurrency(totCost));
				output.append("</td><td  class=\"Topborderlable\" align=\"right\">");
				output.append(formater.getCurrency(totMu));
				output.append("</td><td  class=\"Topborderlable\" align=\"right\">");
				output.append(formater.getCurrency(totFee));
				output.append("</td><td  class=\"Topborderlable\" align=\"right\">");
			}	
			output.append(formater.getCurrency(totPrice));
			output.append("</td></tr>");	
		
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
