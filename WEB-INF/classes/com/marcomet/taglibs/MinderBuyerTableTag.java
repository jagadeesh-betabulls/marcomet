package com.marcomet.taglibs;

/**********************************************************************
Description:	This tag produces the table of jobs for buyer.

Notes:			Depending on the value of BuyerMinderFilter, set from site_hosts.
				
				look at the lu_jobminder_filters for values
				
				1, all jobs and need site hosts column
				2, only site spescific jobs, no site host column
				3, site specific jobs, and job where site host is vendor, need site hosts column
				
				

History:
	Date		Author			Description
	----		------			-----------
	7/23/2001	Thomas Dietrich	Created
	9/20/01		td				added environment objects, siteHostSettings, UserProfile
	11/20/01	ekc				added styles to hrefs in columns

**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;
import com.marcomet.environment.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class MinderBuyerTableTag extends TagSupport {

	private SiteHostSettings siteHostSettings;
	private UserProfile userProfile;
	private int minderFilter;
		
	public final int doEndTag() throws JspException {

		
		Connection conn = null;
		StringBuffer query1 = new StringBuffer();
		StringBuffer output = new StringBuffer();
		FormaterTool ft = new FormaterTool();
		minderFilter = siteHostSettings.getBuyerMinderFilter();
		boolean alt = true;
		
		//long ass query for the minder
		query1.append("SELECT o.id AS 'order_id', DATE_FORMAT(o.date_created,'%m/%d/%y') AS 'creation_date', j.id AS 'job_id', ljt.value AS 'job_type', lst.value AS 'service_type', j.status_id AS 'status_id', j.price AS 'total_job_price', j.shipping_price AS 'shipping', j.sales_tax AS 'sales_tax', j.billable AS 'invoice', j.escrow_amount AS 'escrow', jfs.shownstatus AS 'shown_status', consolereseller, consolecustomer, actionform, whosaction, c1.company_name 'vendor', c2.company_name 'sitehost', p.id 'projectnumber', o.site_host_contact_id 'sitehostcontactid', j.vendor_contact_id 'vendorcontactid' ");
		query1.append("FROM orders o, projects p, jobs j, jobflowstates jfs, lu_job_types ljt, lu_service_types lst, companies c1, companies c2, vendors v, site_hosts sh ");
		query1.append("WHERE o.id = p.order_id AND p.id = j.project_id AND j.status_id = jfs.statusnumber AND j.service_type_id = lst.id and j.job_type_id = ljt.id AND v.id = j.vendor_id AND v.company_id = c1.id AND sh.id = o.site_host_id AND sh.company_id = c2.id AND o.buyer_company_id = ? ");
		
		//how can you make this mess worse here is your answer.  :)
		switch(minderFilter){
			case 1: query1.append(" AND (1 = 1 OR sh.id = ?)  "); 
					break;
			case 2: query1.append(" AND sh.id = ? "); 
					break;
			case 3: query1.append("  AND (( v.company_id = ");
					query1.append(siteHostSettings.getSiteHostCompanyId());
					query1.append(") OR sh.id = ?)"); 
					break;
		}
		
		query1.append("ORDER BY o.date_created, j.project_id DESC ");
		
		//if(1==1) throw new JspException("<input value=\"" + query1.toString() + "\"> companyId: " + companyId);
		
		output.append("<table cellspacing=\"0\" cellpadding=\"3\" width=\"100%\" border=\"1\" bordercolor=\"#000000\">\n<tr>");
		output.append("<td class=\"minderheaderleft\" nowrap> Vendor </td>");
		//if not site specific then show site host column
		if(minderFilter != 2){
			output.append("<td class=\"minderheaderleft\" nowrap> Site </td>");
		}	
		output.append("<td class=\"minderheaderleft\" nowrap> Order #&nbsp;&nbsp; </td>");
		output.append("<td class=\"minderheaderleft\" nowrap> Order Date&nbsp;&nbsp; </td>");
		output.append("<td class=\"minderheaderleft\" nowrap> Project #&nbsp;&nbsp; </td>");
		output.append("<td class=\"minderheaderleft\" nowrap> Job #&nbsp;&nbsp; </td>");
		output.append("<td class=\"minderheaderleft\" nowrap> Job Type&nbsp;&nbsp; </td>");
		output.append("<td class=\"minderheaderleft\" nowrap> Service&nbsp;&nbsp; </td>");
		/*output.append("<td class=\"minderheaderright\" width=\"8%\" nowrap>&nbsp;&nbsp;Job Price</td>");
		output.append("<td class=\"minderheaderright\" width=\"8%\" nowrap>&nbsp;&nbsp;Shipping</td>");
		output.append("<td class=\"minderheaderright\" width=\"8%\" nowrap>&nbsp;&nbsp;Sales Tax</td>");
		*/output.append("<td class=\"minderheaderright\" nowrap>&nbsp;&nbsp;Invoice </td>");
		output.append("<td class=\"minderheaderright\"  nowrap>&nbsp;&nbsp;Escrowed </td>");
		output.append("<td class=\"minderheaderright\" nowrap>&nbsp;&nbsp;Job Status </td>");
		output.append("<td class=\"minderheaderleft\" nowrap>&nbsp;&nbsp;Next Action </td>");
		output.append("<td class=\"minderheadercenter\" nowrap>Other Actions </td>");
  		output.append("</tr>");
				
		try {
			conn = DBConnect.getConnection();
			//for finding unpaid invoices. that aren't the typical finial invoice, since that's just a zero balance invoice.
			String invoiceLink = "";
			String query2 = "SELECT ai.id 'id' FROM ar_invoice_details aid,ar_invoices ai LEFT JOIN ar_collection_details acd ON ai.id=acd.ar_invoiceid WHERE ai.id = aid.ar_invoiceid AND acd.ar_invoiceid is null AND ai.ar_invoice_type != 3 AND aid.jobid = ?";
			PreparedStatement selectInvoices = conn.prepareStatement(query2);
		
			PreparedStatement selectJobs = conn.prepareStatement(query1.toString());
			selectJobs.setInt(1,Integer.parseInt(userProfile.getCompanyId()));		
			selectJobs.setInt(2,Integer.parseInt(siteHostSettings.getSiteHostId()));
			ResultSet rs1 = selectJobs.executeQuery();
			
			while(rs1.next()){			
				alt = (alt)?false:true;
				
				//invoice area
				selectInvoices.clearParameters();
				selectInvoices.setInt(1,rs1.getInt("job_id"));
				ResultSet rs2 = selectInvoices.executeQuery();
				
	  			if(rs2.next()){		
					invoiceLink = "<a href=\"/minders/workflowforms/ReviewInvoice.jsp?invoiceId=" + rs2.getString("id") + "\" class=\"minderLink\">|  Pay Invoice</a>";
				}else{
					invoiceLink = "";
				}
	  			//invoice area end

  				output.append("<tr>");

				//vendor
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\"><a href=\"javascript:pop('/popups/PersonProfilePage.jsp?personId=");
				output.append(rs1.getString("vendorcontactid"));
				output.append("','650','450')\" class=\"minderLink\">");
				output.append(rs1.getString("vendor"));
				output.append("</a></td>");
				
				//if not site specific then show site host column
				if(minderFilter != 2){
					//site host
					output.append("<td class=\"lineitemleft");
					output.append((alt)?"alt":"");
					output.append("\"><a href=\"javascript:pop('/popups/PersonProfilePage.jsp?personId=");
					output.append(rs1.getString("sitehostcontactid"));
					output.append("','650','450')\" class=\"minderLink\">");
					output.append(rs1.getString("sitehost"));
					output.append("</a></td>");
				}
				
				//order number				
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("order_id"));
				output.append("</td>");
				
				//order date
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("creation_date"));
				output.append("</td>");
				
				//project number
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
				
				/*
				output.append("<td class=\"lineitemright");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(ft.getCurrency(rs1.getString("total_job_price")));
				output.append("</td>");
				
				output.append("<td class=\"lineitemright");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(ft.getCurrency(rs1.getString("shipping")));
				output.append("</td>");
				
				output.append("<td class=\"lineitemright");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(ft.getCurrency(rs1.getString("sales_tax")));
				output.append("</td>");
				*/
				
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
				output.append(rs1.getString("shown_status"));
				output.append("</td>");
				
				output.append("<td class=\"lineitemright");
				output.append((alt)?"alt":"");
				output.append("\" >");
				if(rs1.getInt("whosaction") == 1){
					output.append("<a class=\"minderACTION\" href=\"");
					output.append(rs1.getString("actionform"));
					output.append("?jobId=");
					output.append(rs1.getString("job_id"));
					output.append("\">");
					output.append(rs1.getString("consolecustomer"));
					output.append("</a>");
				}else{
					output.append(rs1.getString("consolecustomer"));
				}
				output.append("</td>");
				
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\" nowrap>&nbsp;&nbsp;<a href=\"javascript:pop('/popups/JobDetailsPage.jsp?jobId=");
				output.append(rs1.getString("job_id"));
				output.append("','700','300')\" class=\"minderLink\" class=\"minderLink\">Details</a>");
				output.append("| <a href=\"/files/JobFileViewer.jsp?jobId=");
				output.append(rs1.getString("job_id"));
				output.append("\" class=\"minderLink\">Files</a>");     
				output.append("| <a href=\"/files/useremailform.jsp?jobId=");
				output.append(rs1.getString("job_id"));
				output.append("\" class=\"minderLink\">Email Vendor</a>");
				output.append(invoiceLink);
 				output.append("</td></tr>\n");
			}	
				
			output.append("</table>\n");		
			
			//looking for the query
			//output.append("<p><input value=\"" + query1.toString() + "\"> companyId: " + companyId + "<p>");
			
			pageContext.getOut().print(output);
					
		} catch (IOException ex) {
			throw new JspException(ex.getMessage());	
		} catch (SQLException ex) {
			throw new JspException(ex.getMessage() + "<p><input value=\"" + query1.toString() + "\"> companyId: " + userProfile.getCompanyId() + "<p>" );
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
	public final void setSiteHostSettings(SiteHostSettings temp){
		this.siteHostSettings = temp;	
	}
	public final void setUserProfile(UserProfile temp){
		this.userProfile = temp;
	}
}
