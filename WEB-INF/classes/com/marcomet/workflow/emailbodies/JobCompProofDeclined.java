package com.marcomet.workflow.emailbodies;

/**********************************************************************
Description:	This class will generate an html body email for a job
				comp/proof.

History:
	Date		Author			Description
	----		------			-----------
	5/22/2001	Thomas Dietrich	Created
	8/1/01		td				updated to handle the new email base class
	8/12/03		steve davis		use 'relative' domain to vendor

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

public class JobCompProofDeclined extends EmailBodyBaseClass implements EmailBodyInterface {
	protected String orderId;
	protected String jobId;
	protected String domainName;
	protected String customerContactId;
	protected String vendorContactId;
	protected String siteHostCompanyId;

	public String getBody(MultipartRequest mr) throws SQLException{
		String key = "JobCompProofDeclined";
		
		jobId = (String)mr.getParameter("jobId");
		//domainName = ((SiteHostSettings)mr.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = loadCustomerIdViaJobId(getJobId());
		orderId = loadOrderIdViaJobId(getJobId());
		vendorContactId = loadVendorContactIdViaJobId(getJobId());

		//set domain by vendor
		domainName = DomainReference.getDomainReference(vendorContactId, DomainReference.CONTACT_ID);
		
		return getBaseBody(key);
	}
	public String getBody(HttpServletRequest request) throws SQLException{	
		String key = "JobCompProofDeclined";
		
		jobId = (String)request.getParameter("jobId");
		//domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = loadCustomerIdViaJobId(getJobId());
		orderId = loadOrderIdViaJobId(getJobId());
		vendorContactId = loadVendorContactIdViaJobId(getJobId());
			
		//set domain by vendor
		domainName = DomainReference.getDomainReference(vendorContactId, DomainReference.CONTACT_ID);
		
		return getBaseBody(key);
		
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
	public String getSubject(){
		return "Job Id: " + getJobId();
	}
	protected String getVendorContactId(){
		return vendorContactId;
	}
}
