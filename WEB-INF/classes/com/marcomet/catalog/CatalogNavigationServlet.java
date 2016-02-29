package com.marcomet.catalog;

/**********************************************************************
Description:	This servlet checks the pertinant vendor info for a 
				given offering and then redirects the user to either a 
				vendor selection page or catalog job page
**********************************************************************/

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.marcomet.jdbc.*;
import com.marcomet.environment.UserProfile;
import com.marcomet.environment.SiteHostSettings;

public class CatalogNavigationServlet extends HttpServlet {

	public Vector aquireVendors(HttpServletRequest request, Connection conn, int siteHostId) throws ServletException {
		int offeringId=Integer.parseInt((String)(((request.getParameter("offeringId")==null || request.getParameter("offeringId").equals(""))?"0":request.getParameter("offeringId")))); 
		int jobTypeId=Integer.parseInt((String)request.getParameter("jobTypeId"));
		int serviceTypeId=Integer.parseInt((String)request.getParameter("serviceTypeId"));
		Vector vendorChoices = new Vector();
		try {

			offeringId = Integer.parseInt((String)request.getParameter("offeringId"));
			jobTypeId = Integer.parseInt((String)request.getParameter("jobTypeId"));
			serviceTypeId = Integer.parseInt((String)request.getParameter("serviceTypeId"));

			String query0 = "SELECT distinct cat_job_id, vendor_id, company_name, price_tier_id FROM vendor_catalogs vc, catalog_jobs cj, site_host_vendor_catalogs shvc, vendors v, companies c WHERE active = 1 AND vc.cat_job_id = cj.id AND shvc.vendor_catalog_id = vc.id AND v.company_id = c.id AND v.id = vc.vendor_id AND (site_host_id = '0' or site_host_id = " + siteHostId + ") AND job_type_id = " + jobTypeId + " AND service_type_id = " + serviceTypeId + " ORDER BY default_vendor DESC";
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);

			while (rs0.next()) {
				vendorChoices.addElement(rs0.getString("cat_job_id"));
				vendorChoices.addElement(rs0.getString("vendor_id"));
				vendorChoices.addElement(rs0.getString("company_name"));
				vendorChoices.addElement(rs0.getString("price_tier_id"));
			}

		} catch (SQLException ex) {
			throw new ServletException("determineVendor SQL Error: " + ex.getMessage());
		} catch (Exception ex) {
			throw new ServletException("determineVendor Error: o:"+offeringId+" jt:"+jobTypeId+" st:"+ serviceTypeId+"sh:"+siteHostId+" e:" + ex.getMessage());
		}

		return vendorChoices;

	}
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		try {
			this.processRequest(request, response);
		} catch (ServletException ex) {
			throw new ServletException("CatalogNavigationServlet Error: " + ex.getMessage());
		}
	}
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		try {
			this.processRequest(request, response);
		} catch (ServletException ex) {
			throw new ServletException("CatalogNavigationServlet Error: " + ex.getMessage());
		}
	}
	public void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException {

	
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			int vendorSelection = 1;
			int siteHostContactId = -3;
			String query1 = "SELECT c.id, vendor_selection FROM contacts c, site_hosts sh WHERE c.companyid = sh.company_id AND sh.id = " + ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId();
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery(query1);
			if (rs1.next()) {
				vendorSelection = rs1.getInt("vendor_selection");
				siteHostContactId = rs1.getInt("id");
			}
			
			// Instantiate a shopping cart and put it in session
			ShoppingCart shoppingCart = (ShoppingCart)request.getSession().getAttribute("shoppingCart");
			if((request.getParameter("selfDesigned")!=null && request.getParameter("selfDesigned").equals("true")) || (request.getSession().getAttribute("selfDesigned")!=null && request.getSession().getAttribute("selfDesigned").toString().equals("true"))){
				shoppingCart = (ShoppingCart)request.getSession().getAttribute("DIYshoppingCart");	
			}
			if (shoppingCart == null) {
				shoppingCart = new ShoppingCart();
				shoppingCart.setSiteHostContactId(siteHostContactId);
				if((request.getParameter("selfDesigned")!=null && request.getParameter("selfDesigned").equals("true")) || (request.getSession().getAttribute("selfDesigned")!=null && request.getSession().getAttribute("selfDesigned").toString().equals("true"))){
					request.getSession().setAttribute("DIYshoppingCart", shoppingCart);		
				}else{
					request.getSession().setAttribute("shoppingCart", shoppingCart);
				}
			}

			int vendorId, catJobId, priceTierId, contactId, siteHostId;
				siteHostId = Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId());
				
			try {
				contactId = Integer.parseInt(((UserProfile)request.getSession().getAttribute("userProfile")).getContactId());
			} catch (Exception ex) {
				contactId = -1;
			}

			// Get the vendor choices
			Vector vendorChoices = this.aquireVendors(request, conn, siteHostId);

			// Set a request attribute to let the controller servlet know what to do
			if (request.getParameter("newJob") == null) {
				request.setAttribute("newProject", "1");
				request.setAttribute("newJob", "1");
			} else {
				request.setAttribute("newProject", "0");
				request.setAttribute("newJob", "1");
			}

			RequestDispatcher rd = null;
			if (vendorChoices.size() > 4 && (vendorSelection == 1 || (contactId == siteHostContactId))) {
				request.setAttribute("vendorChoices", vendorChoices);
				rd = getServletContext().getRequestDispatcher("/catalog/VendorSelectionPage.jsp");
			} else {
				catJobId = Integer.parseInt((String)vendorChoices.elementAt(0));
				vendorId = Integer.parseInt((String)vendorChoices.elementAt(1));
				priceTierId = Integer.parseInt((String)vendorChoices.elementAt(3));
				rd = getServletContext().getRequestDispatcher("/servlet/com.marcomet.catalog.CatalogControllerServlet?catJobId=" + catJobId + "&vendorId=" + vendorId + "&tierId=" + priceTierId);
			}

			rd.forward(request, response);

		} catch (SQLException ex) {
			throw new ServletException("processRequest SQL Error: " + ex.getMessage());
		} catch (IOException ex) {
			throw new ServletException("processRequest IO Error: " + ex.getMessage());
		} catch (ServletException ex) {
			throw new ServletException("processRequest Servlet Error: " + ex.getMessage());
		} catch (Exception x) {
			throw new ServletException("processRequest Other Error: " + x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	} // processRequest
}
