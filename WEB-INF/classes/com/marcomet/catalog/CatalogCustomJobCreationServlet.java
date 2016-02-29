package com.marcomet.catalog;

/**********************************************************************
Description:	This servlet is for creating a custom job and placing it
				in the Shopping Cart.

History:
	Date		Author			Description
	----		------			-----------
	8/15/01		Thomas Dietrich	Created
	
**********************************************************************/

import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;
import com.marcomet.jdbc.*;
import com.marcomet.tools.*;
import com.marcomet.environment.UserProfile;
import com.marcomet.environment.SiteHostSettings;


public class CatalogCustomJobCreationServlet extends HttpServlet{
	protected JobObject createJob(HttpServletRequest request, int siteHostId) throws ServletException {
		
		String jobName = "Custom Job Request, RFQ";
		int id = 0;
		int vendorId = 0;
		int vendorContactId = 0;
		int vendorCompanyId = 0;
		int jobTypeId = Integer.parseInt((String)request.getParameter("jobTypeId"));
		int serviceTypeId = Integer.parseInt((String)request.getParameter("serviceTypeId"));
		double escrowPercentage = 0;
		double siteHostMarkup = 0;
		double marcometFee = 0;
    double shippingPrice = 0;
    double discount = 0;
    String promoCode = "";
    String shippingType = "ground";
    String gridLabel = "";
    String subvendorReferenceData="";
    int quantity = 0;

		Connection conn = null;
		try{
			id = Indexer.getNextId("jobs");
		
			conn = DBConnect.getConnection();
			String query2 = "SELECT c.id 'contact_id', v.id 'vendor_id', c.companyid 'company_id', marcomet_global_fee, site_host_global_markup FROM contacts c, vendors v, site_hosts sh, lu_contact_roles lcr, contact_roles cr WHERE sh.company_id = c.companyid AND v.company_id = sh.company_id AND lcr.value = 'site host' AND cr.contact_role_id  = lcr.id AND cr.contact_id = c.id AND sh.id = " + siteHostId;
			Statement st2 = conn.createStatement();
			ResultSet rs2 = st2.executeQuery(query2);
		
			if (rs2.next()){
				vendorContactId = rs2.getInt("contact_id");
				vendorCompanyId = rs2.getInt("company_id");
				vendorId = rs2.getInt("vendor_id");
				siteHostMarkup = rs2.getDouble("site_host_global_markup");
				marcometFee = rs2.getDouble("marcomet_global_fee");
			}
		
		}catch(SQLException sqle){
			throw new ServletException("CreatJob failed, sqle: " + sqle.getMessage());
		} catch (Exception x) {
			throw new ServletException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	
			
		return new JobObject(jobName, id, vendorId, vendorContactId, vendorCompanyId, jobTypeId, serviceTypeId, escrowPercentage, siteHostMarkup, marcometFee, shippingPrice, shippingType, promoCode, discount, gridLabel, quantity,subvendorReferenceData);
	}
	protected JobSpecObject createJobSpec(HttpServletRequest request, int siteHostId) {

		int specId = 1001;
		String specValue = (String)request.getParameter("notes");

		int contactId = Integer.parseInt(((UserProfile)request.getSession().getAttribute("userProfile")).getContactId());
		boolean proxyEnabled = false;
		try {
		   ProxyOrderObject poo = (ProxyOrderObject)request.getSession().getAttribute("ProxyOrderObject");
		   proxyEnabled = poo.isProxyEnabled();
		} catch (Exception ex) {}

		return new JobSpecObject(specId, specId, specValue, 0, 0, contactId, siteHostId, proxyEnabled);
	
	}
	protected ProjectObject createProject(HttpServletRequest request) throws ServletException {
		
		int id;
		try{
			id = Indexer.getNextId("projects");
		}catch(SQLException sqle){
			throw new ServletException("CreateProject failed, sqle: " + sqle.getMessage());
		}
		int sequence = 0;
		String projectName = "RFQ";
	
		return new ProjectObject(id, sequence, projectName);

	}
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {
	
		//get ShoppingCart
		ShoppingCart shoppingCart = (ShoppingCart) request.getSession().getAttribute("shoppingCart");
		if(shoppingCart == null){
			shoppingCart = new ShoppingCart();
			request.getSession().setAttribute("shoppingCart",shoppingCart);		
		}

		int siteHostId = Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId());

		JobObject jo = createJob(request, siteHostId);
		jo.setAsRFQ();
		jo.addJobSpec(createJobSpec(request, siteHostId));
		
		ProjectObject po = createProject(request);
		po.addJob(jo);
			
		shoppingCart.addProject(po);
		
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this,request,response);	
	}
}
