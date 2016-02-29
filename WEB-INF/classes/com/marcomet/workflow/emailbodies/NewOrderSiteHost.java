package com.marcomet.workflow.emailbodies;

/**********************************************************************
Description:	This class will generate an html body email for a job
				/order creation.

History:
	Date		Author			Description
	----		------			-----------
	6/7/2001	Thomas Dietrich	Created
	7/31/01		td				updated to use the new emailbaseclass
	8/2/01		td				renamed so that it becomes the site host email

**********************************************************************/

import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.marcomet.jdbc.*;
import com.marcomet.mail.*;
import com.marcomet.files.*;
import com.marcomet.environment.SiteHostSettings;

public class NewOrderSiteHost extends EmailBodyBaseClass implements EmailBodyInterface {
	protected String orderId;
	protected String jobId;
	protected String domainName;
	protected String customerContactId;
	protected String vendorContactId;
	protected String siteHostCompanyId;

	public String getBody(MultipartRequest mr) throws SQLException{
		//key for email bodies
		String key = "NewOrderReseller";
	
		return getBaseBody(key);
	}
	public String getBody(HttpServletRequest request) throws SQLException{	
		//key for email bodies
		String key = "NewOrderReseller";
		
		
		jobId = (String)request.getParameter("jobId");
		domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = (String)request.getSession().getAttribute("contactId");
		orderId = (String)request.getAttribute("orderId");
		vendorContactId = "";
		siteHostCompanyId = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostCompanyId();
			
		//patch work
		SBPVendorEmail ve = new SBPVendorEmail();
		try{
			return "<pre>" + ve.buildOrderEmail(Integer.parseInt(getOrderId())) + "</pre>";
		}catch(Exception e){
			throw new SQLException(e.getMessage());
		}	
		//return getBaseBody(key);
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
		return "New Catalog Order from Customer";
	}
	protected String getVendorContactId(){
		return vendorContactId;
	}
}
