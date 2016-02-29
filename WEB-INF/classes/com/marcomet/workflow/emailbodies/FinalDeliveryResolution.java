package com.marcomet.workflow.emailbodies;

/**********************************************************************
Description:	This class will generate an email body  for a job's
				submittion of a delivery resolution.

History:
	Date		Author			Description
	----		------			-----------
	5/15/2001	Thomas Dietrich	Created
	8/2/01		td				updated to extend new EmailBaseClass
	8/12/03		steve davis		use 'relative' domain by vendor

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

public class FinalDeliveryResolution extends EmailBodyBaseClass implements EmailBodyInterface {
	protected String orderId;
	protected String jobId;
	protected String domainName;
	protected String customerContactId;
	protected String vendorContactId;
	protected String siteHostCompanyId;

	public String getBody(MultipartRequest mr) throws SQLException{
		//key for email bodies
		String key = "FinalDeliveryResolution";

		jobId = (String)mr.getParameter("jobId");
		//domainName = ((SiteHostSettings)mr.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = loadCustomerIdViaJobId(getJobId());
		orderId = loadOrderIdViaJobId(getJobId());
		vendorContactId = loadVendorContactIdViaJobId(getJobId());
			
		//set domain based on vendor
		domainName = DomainReference.getDomainReference(vendorContactId, DomainReference.CONTACT_ID);
			
		return getBaseBody(key);
	}
	public String getBody(HttpServletRequest request) throws SQLException{	
		//key for email bodies
		String key = "FinalDeliveryResolution";

		jobId = (String)request.getParameter("jobId");
		//domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = loadCustomerIdViaJobId(getJobId());
		orderId = loadOrderIdViaJobId(getJobId());
		vendorContactId = loadVendorContactIdViaJobId(getJobId());

		//set domain based on vendor
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
