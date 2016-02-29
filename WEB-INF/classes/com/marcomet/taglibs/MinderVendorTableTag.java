package com.marcomet.taglibs;

/**********************************************************************
Description:	This tag produces the table of jobs for the vendor

Rule:			"Should show anything that was purchased from them via 
				their catalogs, regardless of site"

History:
	Date		Author			Description
	----		------			-----------
	7/20/2001	Thomas Dietrich	Created
	8/7/01		td				sitehost filter added
	8/30/01     td 				fixed query

**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class MinderVendorTableTag extends TagSupport {

	private String companyId = "";;
	private String actionFilter = " 1 = 1 ";
	private String companyFilter = " 1 = 1 ";
	private String siteHostFilter = " 1 = 1 ";
	
	public final  int doEndTag() throws JspException {

		
		Connection conn = null;
		StringBuffer query1 = new StringBuffer();
		StringBuffer output = new StringBuffer();
		FormaterTool ft = new FormaterTool();
		boolean alt = true;
		
		//long ass query for the minder
		query1.append("SELECT o.id 'order_id', DATE_FORMAT(o.date_created,'%m/%d/%y') 'creation_date', j.id 'job_id', ljt.value 'job_type', lst.value 'service_type', j.status_id 'status_id', j.billable 'invoice', j.escrow_amount 'escrow', jfs.shownstatus 'shown_status', CONCAT(c.firstname,' ',c.lastname) 'customer', j.payable 'payable', j.balance_to_vendor 'vendorbalance', j.balance_to_site_host 'sitehostbalance', consolereseller, actionform, whosaction, c2.company_name 'sitehost', p.id 'projectnumber', c.id 'customerid', o.site_host_contact_id 'sitehostcontactid', j.internal_reference_data 'internalref' ");
		query1.append("FROM orders o, projects p, jobs j, contacts c, jobflowstates jfs, lu_job_types ljt, lu_service_types lst, vendors v, companies c2, site_hosts sh ");
		query1.append("WHERE o.id = p.order_id AND p.id = j.project_id AND o.buyer_contact_id = c.id AND j.status_id = jfs.statusnumber AND j.service_type_id = lst.id AND j.job_type_id = ljt.id AND o.site_host_id = sh.id AND sh.company_id = c2.id AND j.vendor_id = v.id AND v.company_id = ? ");
		query1.append(actionFilter);
		query1.append(companyFilter);
		query1.append(siteHostFilter);
		query1.append(" ORDER BY o.date_created, j.project_id DESC ");
		
		//if(1==1) throw new JspException("<input value=\"" + query1.toString() + "\"> companyId: " + companyId);
		
		output.append("<table cellspacing=\"0\" cellpadding=\"0\" width=\"100%\">\n<tr>");
		output.append("<td>&nbsp;</td>");

    output.append("<td class=\"minderheaderleft\" height=\"0\" width=\"0\">Client</td>");
    output.append("<td class=\"minderheaderleft\" height=\"0\" width=\"0\">Site Host</td>");
//    output.append("<td class=\"minderheaderleft\" height=\"0\" width=\"0\">Vendor </td>");
    output.append("<td class=\"minderheadercenter\" height=\"0\" width=\"0\">Order</td>");
    output.append("<td class=\"minderheaderleft\" height=\"0\" width=\"0\">Date</td>");
    output.append("<td class=\"minderheaderleft\" height=\"0\" width=\"0\">Proj.</td>");
    output.append("<td class=\"minderheadercenter\" height=\"0\" width=\"0\">Job</td>");
    output.append("<td class=\"minderheaderleft\" height=\"0\" width=\"0\">Ref.</td>");
    output.append("<td class=\"minderheaderleft\" height=\"0\" width=\"0\">Job Type</td>");
    output.append("<td class=\"minderheaderleft\" height=\"0\" width=\"0\">Service</td>");
    output.append("<td class=\"minderheaderleft\" height=\"0\" width=\"0\"> Status</td>");
    output.append("<td class=\"minderheaderleft\" height=\"0\" width=\"0\"> Actions Items</td>");
    output.append("<td class=\"minderheaderleft\" height=\"0\" width=\"0\">Other Actions</td>");
    output.append("<td class=\"minderheaderright\" height=\"0\" width=\"0\">Invoiced</td>");
    output.append("<td class=\"minderheaderright\" height=\"0\" width=\"0\">Escrowed</td>");
    output.append("<td class=\"minderheaderright\" height=\"0\" width=\"0\">Due Site</td>");
    output.append("<td class=\"minderheaderright\" height=\"0\" width=\"0\">Due Vendor </td>");
	output.append("</tr>");
				
		try {
			conn = DBConnect.getConnection();
			PreparedStatement selectJobs = conn.prepareStatement(query1.toString());
			selectJobs.setInt(1,Integer.parseInt(companyId));		
			ResultSet rs1 = selectJobs.executeQuery();
			
			while(rs1.next()){			
				alt = (alt)?false:true;

				output.append("<tr><td>&nbsp;</td>");
				
				
				//customer
				output.append("<td class=\"minderLink");
				output.append((alt)?"alt":"");
				output.append("\"><a href=\"javascript:pop('/popups/PersonProfilePage.jsp?personId=");
				output.append(rs1.getString("customerid"));
				output.append("','650','450')\" class=\"minderLink\">");
				output.append(rs1.getString("customer"));
				output.append("</a></td>");
				
				//site
				output.append("<td class=\"minderLink");
				output.append((alt)?"alt":"");
				output.append("\"><a href=\"javascript:pop('/popups/PersonProfilePage.jsp?personId=");
				output.append(rs1.getString("sitehostcontactid"));
				output.append("','650','450')\" class=\"minderLink\">");
				output.append(rs1.getString("sitehost"));
				output.append("</a></td>");
		
				/*//vendor
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append("vendor");
				output.append("</td>");*/
							
				//order #
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
				
				//job number
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("job_id"));
				output.append("</td>");
				
				//internal reference
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("internalref"));
				output.append("</td>");
				
				//job type
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("job_type"));
				output.append("</td>");
				
				//service type
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("service_type"));
				output.append("</td>");
				
				//job status
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\">");
				output.append(rs1.getString("shown_status"));
				output.append("</td>");
				
				//next action
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\"><a class=\"minderACTION\" href=\"");
				output.append(rs1.getString("actionform"));
				output.append("?jobId=");
				output.append(rs1.getString("job_id"));
				output.append("\" class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\"><b>");
				output.append(rs1.getString("consolereseller"));
				output.append("</b></a></td>");
				
				//other actions
				output.append("<td class=\"lineitemleft");
				output.append((alt)?"alt":"");
				output.append("\" nowrap ><b><a href=\"javascript:pop('/popups/JobDetailsPage.jsp?jobId=");
				output.append(rs1.getString("job_id"));
				output.append("','700','300')\" class=\"minderLink\">Details</a> | <a href=\"/files/JobFileViewer.jsp?jobId=");
				output.append(rs1.getString("job_id"));
				output.append("\" class=\"minderLink\">Files</a>");
				if(rs1.getInt("status_id") == 4){
					output.append(" | <a href=\"javascript:window.location.replace('/minders/workflowforms/ProposeJobChangeForm.jsp?jobId=");
					output.append(rs1.getString("job_id"));
					output.append("')\" class=\"minderLink\">Propose Change</a>");
				}
				if (!rs1.getString("status_id").equals("6") && !rs1.getString("status_id").equals("8") && !rs1.getString("status_id").equals("9") && (rs1.getInt("status_id") > 4) && (rs1.getInt("status_id") < 13)) {
					output.append("| <a href=\"/minders/workflowforms/InterimShipment.jsp?jobId=");
					output.append(rs1.getString("job_id"));
					output.append("\" class=\"minderLink\">Shipment</a>");
					if(rs1.getInt("status_id") != 12) {
						output.append(" | <a href=\"/minders/workflowforms/InterimInvoice.jsp?jobId=");
						output.append(rs1.getString("job_id"));
						output.append("\" class=\"minderLink\">Invoice</a>");
					}
		   		}

		   		//invoice amount
		   		output.append("<td class=\"lineitemright");
		   		output.append((alt)?"alt":"");
		   		output.append("\">");
		   		output.append(ft.getCurrency(rs1.getString("invoice")));
		   		output.append("</td>");
		   		
		   		//escrow amount
		   		output.append("<td class=\"lineitemright");
		   		output.append((alt)?"alt":"");
		   		output.append("\">");
		   		output.append(ft.getCurrency(rs1.getString("escrow")));
		   		output.append("</td>");
		   		
		   		//amount due to site
		   		output.append("<td class=\"lineitemright");
		   		output.append((alt)?"alt":"");
		   		output.append("\">");
		   		output.append(ft.getCurrency(rs1.getDouble("sitehostbalance")));
		   		output.append("</td>");
		   		
		   		//aount due to vendor
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
	public final  void setActionFilter(String temp){
		this.actionFilter = temp;
	}
	public final  void setCompanyFilter(String temp){
		this.companyFilter = temp;
	}
	public final  void setCompanyId(String temp){
		this.companyId = temp;
	}
	public final  void setSiteHostFilter(String temp){
		this.siteHostFilter = temp;
	}
}
