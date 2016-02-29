package com.marcomet.workflow.emailbodies;

/**********************************************************************
Description:	This class will generate an html body email for a RFQ job
				response from the buyer as accepted.

History:
	Date		Author			Description
	----		------			-----------
	8/16/2001	Thomas Dietrich	Created
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

public class RFQBuyerAccepted extends EmailBodyBaseClass implements EmailBodyInterface {
	protected String orderId;
	protected String jobId;
	protected String domainName;
	protected String customerContactId;
	protected String vendorContactId;
	protected String siteHostCompanyId;
	//key for email bodies
	protected String key = "RFQBuyerAccepted";

	
	public String getBody(MultipartRequest mr) throws SQLException{
		
		jobId = (String)mr.getParameter("jobId");
		//domainName = ((SiteHostSettings)mr.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = loadCustomerIdViaJobId(getJobId());
		orderId = loadOrderIdViaJobId(getJobId());
		vendorContactId = loadVendorContactIdViaJobId(getJobId());
			
		//set domain by vendor id
		domainName = DomainReference.getDomainReference(vendorContactId, DomainReference.CONTACT_ID);

		return getBaseBody(key);
	}
	public String getBody(HttpServletRequest request) throws SQLException{	

		jobId = (String)request.getParameter("jobId");
		//domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = loadCustomerIdViaJobId(getJobId());
		orderId = loadOrderIdViaJobId(getJobId());
		vendorContactId = loadVendorContactIdViaJobId(getJobId());
			
		//set domain by vendor id
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
