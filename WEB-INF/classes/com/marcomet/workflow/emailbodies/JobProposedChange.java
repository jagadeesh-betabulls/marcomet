package com.marcomet.workflow.emailbodies;

/**********************************************************************
Description:	This class will generate an html body email for a job
				proposed changes.

History:
	Date		Author			Description
	----		------			-----------
	4/16/2001	Thomas Dietrich	Created
	5/9/01		td				added code to pull email bodies from the db
	5/14/01		td				this class will be extended from the base class
	8/2/01		td				This 
	8/12/03		steve davis		use 'relative' domain to order origination

**********************************************************************/

import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.marcomet.jdbc.*;
import com.marcomet.mail.*;
import com.marcomet.files.*;
import com.marcomet.workflow.*;
import com.marcomet.environment.SiteHostSettings;

public class JobProposedChange extends EmailBodyBaseClass implements EmailBodyInterface {
	protected String orderId;
	protected String jobId;
	protected String domainName;
	protected String customerContactId;
	protected String vendorContactId;
	protected String siteHostCompanyId;

	public String getBody(MultipartRequest mr) throws SQLException{
		//key for email bodies
		String key1 = "JobProposedChangeRequired";
		String key2 = "JobProposedChangeRecommended";
		String key3 = "JobProposedChangeRequested";
		
		jobId = (String)mr.getParameter("jobId");
		//domainName = ((SiteHostSettings)mr.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = loadCustomerIdViaJobId(getJobId());
		orderId = loadOrderIdViaJobId(getJobId());
		vendorContactId = loadVendorContactIdViaJobId(getJobId());

		//set domain by order origination
		domainName = DomainReference.getDomainReference(orderId, DomainReference.ORDER_ID);
	
		if(((String)mr.getParameter("changeTypeId")).equals("1")){
			return getBaseBody(key1);
		}
		if(((String)mr.getParameter("changeTypeId")).equals("2")){
			return getBaseBody(key2);
		}	
		
		return getBaseBody(key3);
	}
	public String getBody(HttpServletRequest request) throws SQLException{	
		//key for email bodies
		String key1 = "JobProposedChangeRequired";
		String key2 = "JobProposedChangeRecommended";
		String key3 = "JobProposedChangeRequested";

		jobId = (String)request.getParameter("jobId");
		//domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = loadCustomerIdViaJobId(getJobId());
		orderId = loadOrderIdViaJobId(getJobId());
		vendorContactId = loadVendorContactIdViaJobId(getJobId());

		//set domain by order origination
		domainName = DomainReference.getDomainReference(orderId, DomainReference.ORDER_ID);
	
		if(((String)request.getParameter("changeTypeId")).equals("1")){
			return getBaseBody(key1);
		}
		if(((String)request.getParameter("changeTypeId")).equals("2")){
			return getBaseBody(key2);
		}	

		return getBaseBody(key3);
	}
	protected String getCustomerContactId(){
		return customerContactId;
	}
	protected String getDomainName(){
		return domainName;
	}
	protected String getJobId(){
		return jobId;
	}
	protected String getOrderId(){ 
		return orderId;
	}
	protected String getSiteHostCompanyId(){
		return siteHostCompanyId;
	}
	public String getSubject() {	
		return "Job Id: " + getJobId();
	}
	public String getSubject(HttpServletRequest request) {

		String title = "";

		if (((String)request.getParameter("changeTypeId")).equals("1")) {
			title = "Required Job Change Proposed";
		} else if(((String)request.getParameter("changeTypeId")).equals("2")) {
			title = "Recommended Job Change Proposed";
		} else if(((String)request.getParameter("changeTypeId")).equals("3")) {
			title = "Requested Job Change Proposed";
		} else if(((String)request.getParameter("changeTypeId")).equals("5")) {
			title = "Job Completed and Priced";
		} else {		
			title = "Requested Job Change Proposed";
		}
		
		return "Job Id: " + getJobId() + " - " + title;
	}
	protected String getVendorContactId(){
		return vendorContactId;
	}
}
