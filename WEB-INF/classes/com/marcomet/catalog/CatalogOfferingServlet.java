package com.marcomet.catalog;

/**********************************************************************
Description:	This servlet checks the pertinant vendor info for a 
				given offering and then redirects the user to either a 
				vendor selection page or catalog job page

History:
	Date		Author			Description
	----		------			-----------
	8/10/01		Brian Murphy	Created
	
**********************************************************************/

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.marcomet.jdbc.*;
import com.marcomet.environment.SiteHostSettings;

public class CatalogOfferingServlet extends HttpServlet {



	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		try {
			this.processRequest(request, response);
		} catch (ServletException ex) {
			throw new ServletException("CatalogOfferingServlet Error: " + ex.getMessage());
		}
	}
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		try {
			this.processRequest(request, response);
		} catch (ServletException ex) {
			throw new ServletException("CatalogOfferingServlet Error: " + ex.getMessage());
		}
	}
	public void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			int siteHostOfferingId = Integer.parseInt((String)request.getParameter("siteHostOfferingId"));
			int siteHostId = Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId());

			String description = ""; String subdescription = ""; String picUrl = ""; String title = "";
			int offeringId = 0; int jobTypeId = 0; int serviceTypeId = 0;
			String query0 = "SELECT o.id as offering_id, job_type_id, service_type_id, sho.description, subdescription, pic_url, o.title FROM site_host_offerings sho, site_host_offering_choices shoc, offerings o, offering_sequences os WHERE shoc.active = 1 AND shoc.offering_id = o.id AND o.id = os.offering_id AND shoc.site_host_offering_id = sho.id AND os.sequence = 0 AND sho.id = " + siteHostOfferingId + " AND site_host_id = " + siteHostId + " ORDER BY shoc.sequence";
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);
			if (rs0.next()) {
				request.setAttribute("description", rs0.getString("description"));
				request.setAttribute("subdescription", rs0.getString("subdescription"));
				request.setAttribute("picUrl", rs0.getString("pic_url"));
				Vector linksVector = new Vector();
				do {
					offeringId = rs0.getInt("offering_id");
					serviceTypeId = rs0.getInt("service_type_id");
					jobTypeId = rs0.getInt("job_type_id");
					title = rs0.getString("title");
					String pageLink = "<a href=\"/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=" + offeringId + "&jobTypeId=" + jobTypeId + "&serviceTypeId=" + serviceTypeId + "\" class=\"offeringITEM\">" + title + "</a>";
					linksVector.addElement(pageLink);
				} while(rs0.next());
				request.setAttribute("linksVector", linksVector);
			}		
			
			request.setAttribute("title","");                     //blank title for inner frame
			String nextPage = "/catalog/CatalogNavPage.jsp";
			RequestDispatcher rd = rd = getServletContext().getRequestDispatcher(nextPage);
			rd.forward(request, response);

		} catch (IOException ex) {
			throw new ServletException("processRequest IO Error: " + ex.getMessage());
		} catch (SQLException ex) {
			throw new ServletException("processRequest SQL Error " + ex.getMessage());
		} catch (ServletException ex) {
			throw new ServletException("processRequest Error: " + ex.getMessage());
		} catch (Exception x) {
			throw new ServletException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	} // processRequest
}
