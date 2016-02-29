package com.marcomet.mail.registration;

/**********************************************************************
Description:	Email Class, for sending messages based on a new registration
				To the new registrant.

History:
	Date		Author			Description
	----		------			-----------
	7/27/2001	Thomas Dietrich	Created

**********************************************************************/

import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.marcomet.mail.*;
import com.marcomet.environment.SiteHostSettings;

public class NewRegistrationMessage extends EmailBodyBaseClass{

	protected String orderId;
	protected String jobId;
	protected String domainName;
	protected String customerContactId;
	protected String vendorContactId;
	protected String siteHostCompanyId;

	public String getBody(HttpServletRequest request) throws SQLException{

		domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();
		siteHostCompanyId = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostCompanyId();
		customerContactId = (String)request.getAttribute("customerId");

		return getBaseBody("NewUserRegistration");
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
