package com.marcomet.workflow.emailbodies;

/**********************************************************************
Description:	This class will generate an html body email for a job
				rfq creation.

History:
	Date		Author			Description
	----		------			-----------
	5/21/2001	Thomas Dietrich	Created
	8/3/01		td 				updated to extend new EmailBaseClass
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

public class NewRFQOrderedReseller extends EmailBodyBaseClass implements EmailBodyInterface {
	protected String orderId;
	protected String jobId;
	protected String domainName;
	protected String customerContactId;
	protected String vendorContactId;
	protected String siteHostCompanyId;

	public String getBody(MultipartRequest mr) throws SQLException{
		//key for email bodies
		String key = "NewRFQOrdered";
	
		return getBaseBody(key);
	}
	public String getBody(HttpServletRequest request) throws SQLException{	
		//key for email bodies
		String key = "NewRFQOrdered";

		jobId = (String)request.getParameter("jobId");
		//domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();
		customerContactId = (String)request.getSession().getAttribute("contactId");
		orderId = (String)request.getAttribute("orderId");
		vendorContactId = loadVendorContactIdViaJobId(getJobId());
		siteHostCompanyId = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostCompanyId();

		//set domain by vendor
		domainName = DomainReference.getDomainReference(vendorContactId, DomainReference.CONTACT_ID);
			
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
		return "New RFQ Order from Customer";
	}
	protected String getVendorContactId(){
		return vendorContactId;
	}
}
