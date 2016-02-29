package com.marcomet.workflow.emailbodies;

/**********************************************************************
Description:	This class will generate an html body email for a job
				final invoice submited not requireing payment immedatly.

History:
	Date		Author			Description
	----		------			-----------
	5/8/2001	Thomas Dietrich	Created
	5/9/01		td				added code to pull email bodies from the db
	5/14/01		td				this class will be extended from the base class
	8/2/01		td				updated to extend new EmailBaseClass
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

public class InterimInvoice extends EmailBodyBaseClass implements EmailBodyInterface {
	protected String orderId;
	protected String jobId;
	protected String domainName;
	protected String customerContactId;
	protected String vendorContactId;
	protected String siteHostCompanyId;

	public String getBody(MultipartRequest mr) throws SQLException{
		//key for email bodies
		String key = "InterimInvoice";	

		jobId = (String)mr.getParameter("jobId");
		//domainName = ((SiteHostSettings)mr.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = loadCustomerIdViaJobId(getJobId());
		orderId = loadOrderIdViaJobId(getJobId());
		vendorContactId = loadVendorContactIdViaJobId(getJobId());

		//set domain based on order origination domain
		domainName = DomainReference.getDomainReference(orderId, DomainReference.ORDER_ID);
			
		return getBaseBody(key);
	}
	public String getBody(HttpServletRequest request) throws SQLException{	
		//key for email bodies
		String key = "InterimInvoice";	

		jobId = (String)request.getParameter("jobId");
		//domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = loadCustomerIdViaJobId(getJobId());
		orderId = loadOrderIdViaJobId(getJobId());
		vendorContactId = loadVendorContactIdViaJobId(getJobId());
		//set domain based on order origination domain
		domainName = DomainReference.getDomainReference(orderId, DomainReference.ORDER_ID);
			
		return getBaseBody(key);
	}
	public String getBody() throws SQLException{	
		//key for email bodies
		String key = "InterimInvoice";	

		//domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = loadCustomerIdViaJobId(getJobId());
		orderId = loadOrderIdViaJobId(getJobId());
		vendorContactId = loadVendorContactIdViaJobId(getJobId());
			
		//set domain based on order origination domain
		domainName = DomainReference.getDomainReference(orderId, DomainReference.ORDER_ID);
			
		return getBaseBody(key);
	}
	protected String getCustomerContactId(){
		return customerContactId;
	}
	protected String getDomainName(){
		return domainName;
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
	public String getJobId() {
		return jobId;
	}
	public void setJobId(String jobId) {
		this.jobId = jobId;
	}
}
