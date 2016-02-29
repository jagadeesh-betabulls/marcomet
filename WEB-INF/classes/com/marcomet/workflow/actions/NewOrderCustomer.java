package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will generate an html body email for a job
				/order creation.

History:
	Date		Author			Description
	----		------			-----------
	5/24/2001	Thomas Dietrich	Created
	6/7/2001	td				modified, implementing check out to workflow
	7/31/01		td				updated to extend the new emailbase class
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
import com.marcomet.workflow.emailbodies.EmailBodyInterface;
import com.marcomet.catalog.ProxyOrderObject;
import com.marcomet.environment.SiteHostSettings;

public class NewOrderCustomer extends EmailBodyBaseClass implements EmailBodyInterface {
	protected String orderId;
	protected String jobId;
	protected String domainName;
	protected String customerContactId;
	protected String vendorContactId;
	protected String siteHostCompanyId;

	public String getBody(MultipartRequest mr) throws SQLException{
		//key for email bodies
		String key = "NewOrderCustomer";
	
		return getBaseBody(key);
	}
	public String getBody(HttpServletRequest request) throws SQLException{	
		//key for email bodies
		String key = "NewOrderCustomer";
		
		
		jobId = (String)request.getParameter("jobId");
		//domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();
try {
com.marcomet.tools.MessageLogger.logMessage("Grabbing Proxy Object");
} catch(Exception e){}
		try {
			ProxyOrderObject poo = (ProxyOrderObject)request.getSession().getAttribute("ProxyOrderObject");
try {
com.marcomet.tools.MessageLogger.logMessage("Aquired Object");
} catch(Exception e){}
			customerContactId = new Integer(poo.getProxyContactId()).toString();
try {
com.marcomet.tools.MessageLogger.logMessage("Id is: " + customerContactId);
} catch(Exception e){}
		} catch (Exception ex) {	
			customerContactId = (String)request.getSession().getAttribute("contactId");
try {
com.marcomet.tools.MessageLogger.logMessage("An Exception occured, using id: " + customerContactId);
} catch(Exception e){}
		}

		orderId = (String)request.getAttribute("orderId");
		vendorContactId = "";
		siteHostCompanyId = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostCompanyId();
			
		//set domain by order origination
		domainName = DomainReference.getDomainReference(orderId, DomainReference.ORDER_ID);

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
		return "Your New Marcomet Order";
	}
	protected String getVendorContactId(){
		return vendorContactId;
	}
}
