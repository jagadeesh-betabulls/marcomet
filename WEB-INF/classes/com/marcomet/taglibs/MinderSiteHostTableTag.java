package com.marcomet.taglibs;

/**********************************************************************
Description:	This tag produces the table of jobs for the for the site host.

Rule:			"Show all jobs purchased through that site"

History:
	Date		Author			Description
	----		------			-----------
	7/23/2001	Thomas Dietrich	Created

**********************************************************************/


import com.marcomet.jdbc.*;
import com.marcomet.tools.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class MinderSiteHostTableTag extends TagSupport {

	private String companyId = "";
	private String vendorFilter = " 1 = 1 ";
	private String companyFilter = " 1 = 1 ";
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null;
		StringBuffer query1 = new StringBuffer();
		StringBuffer output = new StringBuffer();
		FormaterTool ft = new FormaterTool();
		boolean alt = true;
		
		//long ass query for the minder
		query1.append("SELECT o.id 'order_id', DATE_FORMAT(o.date_created,'%m/%d/%y') 'creation_date', j.id 'job_id', ljt.value 'job_type', lst.value 'service_type', j.status_id 'status_id', j.billable 'invoice', j.escrow_amount 'escrow', jfs.shownstatus 'shown_status', CONCAT(c.firstname,' ',c.lastname) 'customer', j.payable 'payable', j.balance_to_vendor 'vendorbalance', j.balance_to_site_host 'sitehostbalance', consolereseller, actionform, whosaction, com.company_name 'vendor', p.id 'projectnumber', o.buyer_contact_id 'customerid', j.vendor_contact_id 'vendorcontactid' ");
		query1.append("FROM orders o, projects p, jobs j, contacts c, jobflowstates jfs, lu_job_types ljt, lu_service_types lst, vendors v, site_hosts sh, companies com ");
		query1.append("WHERE o.id = p.order_id AND p.id = j.project_id AND o.buyer_contact_id = c.id  AND j.status_id = jfs.statusnumber AND j.service_type_id = lst.id AND j.job_type_id = ljt.id AND o.site_host_id = sh.id AND v.id = j.vendor_id AND v.company_id = com.id AND sh.company_id = ? ");
		query1.append(vendorFilter);
		query1.append(companyFilter);
		query1.append(" ORDER BY o.date_created, j.project_id DESC ");
		
		//if(1==1) throw new JspException("<input value=\"" + query1.toString() + "\"> companyId: " + companyId);
		
		output.append("<table cellspacing=\"0\" cellpadding=\"0\" width=\"100%\" >\n<tr>");
		output.append("<td>&nbsp;</td>");
		output.append("<td class=\"minderheaderleft\"> Customer </td>");
		output.append("<td class=\"minderheaderleft\"> Vendor </td>");
		output.append("<td class=\"minderheaderleft\"> Order #&nbsp;&nbsp;</td>");
		output.append("<td class=\"minderheaderleft\"> Order Date </td>");
		output.append("<td class=\"minderheaderleft\"> Project # </td>");
		output.append("<td class=\"minderheaderleft\"> Job # </td>");
		output.append("<td class=\"minderheaderleft\">Job Type </td>");
		output.append("<td class=\"minderheaderleft\"> Service </td>");
		output.append("<td class=\"minderheaderright\"> Job Status </td>");
		output.append("<td class=\"minderheaderright\"> Next Action </td>");
		output.append("<td class=\"minderheadercenter\"> Other Actions </td>");
		output.append("<td class=\"minderheader\">Invoice</td>");
		output.append("<td class=\"minderheader\">Escrowed</td>");
		output.append("<td class=\"minderheader\">Due To Site</td>");
		output.append("<td class=\"minderheader\">Due To Vendor</td>");
		output.append("</tr>");

		try {
			conn = DBConnect.getConnection();
			PreparedStatement selectJobs = conn.prepareStatement(query1.toString());
			selectJobs.setInt(1,Integer.parseInt(companyId));		
			ResultSet rs1 = selectJobs.executeQuery();
			
			while(rs1.next()){			
				alt = (alt)?false:true;			
				
				output.append("<tr>");
				output.append("<td>&nbsp;</td>");
				
				//customer
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\"><a href=\"javascript:pop('/popups/PersonProfilePage.jsp?personId=");
				output.append(rs1.getString("customerid"));
				output.append("','650','450')\" class=\"minderLink\">");
				output.append(rs1.getString("customer"));
				output.append("</a></td>");
				
				//vendor
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\"><a href=\"javascript:pop('/popups/PersonProfilePage.jsp?personId=");
				output.append(rs1.getString("vendorcontactid"));
				output.append("','650','450')\" class=\"minderLink\">");
				output.append(rs1.getString("vendor"));
				output.append("</a></td>");
								
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("order_id"));
				output.append("</td>");
				
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("creation_date"));
				output.append("</td>");
				
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("projectnumber"));
				output.append("</td>");
				
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("job_id"));
				output.append("</td>");
				
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("job_type"));
				output.append("</td>");
				
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("service_type"));
				output.append("</td>");

				output.append("<td class=\"lineitemright");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("shown_status"));
				output.append("</td>");
				
				output.append("<td class=\"lineitemright");
				output.append((alt)?"alt":"");
				output.append("\" nowrap><b>");
				output.append(rs1.getString("consolereseller"));
				output.append("</b></td>");
				
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\" nowrap ><b><a href=\"javascript:pop('/popups/JobDetailsPage.jsp?jobId=");
				output.append(rs1.getString("job_id"));
				output.append("','700','300')\" class=\"minderLink\">Details</a> | <a href=\"/files/JobFileViewer.jsp?jobId=");
				output.append(rs1.getString("job_id"));
				output.append("\" class=\"minderLink\">Files</a>");
				/*
				if (!rs1.getString("status_id").equals("9")&&!(rs1.getInt("status_id")< 4)) {
					output.append("| <a href=\"/minders/workflowforms/InterimShipment.jsp?jobId=");
					output.append(rs1.getString("job_id"));
					output.append(" class=\"minderLink\">Shipment</a>");
					if(rs1.getInt("status_id") != 12) {
						output.append(" | <a href=\"/minders/workflowforms/InterimInvoice.jsp?jobId=");
						output.append(rs1.getString("job_id"));
						output.append(" class=\"minderLink\">Invoice</a>");
					}
		   		}*/

		   		
		   		output.append("<td class=\"lineitemright");
		   		output.append((alt)?"alt":"");
		   		output.append("\">");
		   		output.append(ft.getCurrency(rs1.getString("invoice")));
		   		output.append("</td>");
		   		
		   		output.append("<td class=\"lineitemright");
		   		output.append((alt)?"alt":"");
		   		output.append("\">");
		   		output.append(ft.getCurrency(rs1.getString("escrow")));
		   		output.append("</td>");
		   		
		   		output.append("<td class=\"lineitemright");
		   		output.append((alt)?"alt":"");
		   		output.append("\">");
		   		output.append(ft.getCurrency(rs1.getDouble("sitehostbalance")));
		   		output.append("</td>");
		   		
		   		output.append("<td class=\"lineitemright");
		   		output.append((alt)?"alt":"");
		   		output.append("\">");
		   		output.append(ft.getCurrency(rs1.getDouble("vendorbalance")));
		   		output.append("</td>");

	  			output.append("</b></td></tr>\n");
			}	
				
			//looking for the query
			//output.append("<p><textarea rows=\"10\" cols=\"120\">" + query1.toString() + "</textarea><br>companyId: " + companyId + "<p>");
			
			output.append("</table>\n");
						
			pageContext.getOut().print(output);
					
		} catch (IOException ex) {
			throw new JspException(ex.getMessage());	
		} catch (SQLException ex) {
			throw new JspException(ex.getMessage() + "<p><input value=\"" + query1.toString() + "\"> companyId: " + companyId + "<p>" );
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
	public final  void setVendorFilter(String temp){
		this.vendorFilter = temp;
	}
	public final  void setCompanyFilter(String temp){
		this.companyFilter = temp;
	}
	public final  void setCompanyId(String temp){
		this.companyId = temp;
	}
}
