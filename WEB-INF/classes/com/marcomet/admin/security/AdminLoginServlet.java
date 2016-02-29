/**********************************************************************
Description:	This servlet sets some prerequisites for the LoginUserServlet
				and then passes the request along.

**********************************************************************/

package com.marcomet.admin.security;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.environment.SiteHostSettings;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.ReturnPageContentServlet;

public class AdminLoginServlet extends javax.servlet.http.HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException{			

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			Statement st0 = conn.createStatement();

			String query0 = "SELECT * FROM site_hosts sh WHERE sh.site_host_name = \"" + request.getParameter("site") + "\"";
			ResultSet rs0 = st0.executeQuery(query0);

			if (rs0.next()) {
				request.getSession().setAttribute("siteHostId", rs0.getString("id"));
				request.getSession().setAttribute("site", request.getParameter("site"));
				
				
				//SiteHost specific information
				SiteHostSettings siteHostSettings = new SiteHostSettings();
				siteHostSettings.setSiteHostId(rs0.getString("id"));
				siteHostSettings.setSiteHostCompanyId(rs0.getString("company_id"));
				siteHostSettings.setSiteHostGlobalMarkup(rs0.getDouble("site_host_global_markup"));
				siteHostSettings.setMarcometGlobalFee(rs0.getDouble("marcomet_global_fee"));
				siteHostSettings.setDomainName(rs0.getString("domain_name"));
				siteHostSettings.setOuterFrameSetHeight(rs0.getString("outer_frame_set_height"));
				siteHostSettings.setInnerFrameSetHeight(rs0.getString("inner_frame_set_height"));
				siteHostSettings.setCCommerce(rs0.getString("process_credit_cards"));
				siteHostSettings.setBuyerMinderFilter(rs0.getInt("buyer_minder_filter"));
				siteHostSettings.setValidateSiteNumberFlag(rs0.getInt("validate_site_number_flag"));
				siteHostSettings.setUseSiteNumbersFlag(rs0.getInt("use_site_number_flag"));
				
				request.getSession().setAttribute("siteHostSettings", siteHostSettings);
				
				
			} else {
				request.setAttribute("errorMessage", request.getParameter("site") + " is not a valid site.");
				ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
				rpcs.printNextPage(this, request, response);
				return;
			}

			RequestDispatcher rd = getServletContext().getRequestDispatcher("/servlet/com.marcomet.users.security.LoginUserServlet");
			rd.forward(request, response);

		} catch (Exception ex) {
			throw new ServletException ("doPost error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	}
}
