package com.marcomet.workflow.emailbodies;

/**********************************************************************
Description:	This class will generate an html body email for a vendor,
				grouping specific jobs per vendor per new order.

Note:			Since this class is specifily called by the NewOrderVendorEmail,
				it doesn't impliment the EmailBodyInterface.				
				
				
History:
	Date		Author			Description
	----		------			-----------
	8/2/01		tom dietrich		created
	8/12/03		steve davis		use 'relative'vendor domain
	
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

public class NewOrderVendor extends EmailBodyBaseClass /*implements EmailBodyInterface*/ {
	protected String orderId;
	protected String jobId;
	protected String domainName;
	protected String customerContactId;
	protected String vendorContactId;
	protected String siteHostCompanyId;
	
	public String getBody(HttpServletRequest request, String vendorContactId) throws SQLException{	
		//key for email bodies
		String key = "NewOrderVendor";
		
		//shouldn't depend on a specific jobid		
		//jobId = (String)request.getParameter("jobId");
		//domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();

		//get the domain based on the vendor
		domainName = DomainReference.getDomainReference(vendorContactId, DomainReference.CONTACT_ID);

		customerContactId = (String)request.getSession().getAttribute("contactId");
		orderId = (String)request.getAttribute("orderId");
		this.vendorContactId = vendorContactId;
	
		return getBaseBody(key);
	}
	protected String getCustomerContactId(){
		return customerContactId;
	}
	protected String getDomainName(){
		return domainName;
	}
	protected String getJobId(){
		//throw this exception to detect if the body tries to use a specific jobId = bad
		int xx = 0;
		int yy = 1/xx;
		
		return jobId;
	}
	protected String getOrderId(){ 
		return orderId;
	}
	protected String getSiteHostCompanyId(){
		return siteHostCompanyId;
	}
	public String getSubject(){
		return "New Order";
	}
	protected String getVendorContactId(){
		return vendorContactId;
	}
}
