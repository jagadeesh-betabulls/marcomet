/**********************************************************************
Description:	This servlet adds catalogs to vendors
**********************************************************************/

package com.marcomet.admin.catalog;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.environment.UserProfile;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.ReturnPageContentServlet;

public class CatalogSelectionServlet extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			int vendorId = 0;
			Statement st0 = conn.createStatement();
			UserProfile up = (UserProfile)request.getSession().getAttribute("userProfile");
			String query0 = "SELECT id FROM vendors WHERE company_id = " + up.getCompanyId();
			ResultSet rs0 = st0.executeQuery(query0);
			if (rs0.next()) {
				vendorId = rs0.getInt("id");
			}

			String[] catJobIds = request.getParameterValues("catJobIds");
			String query1 = "INSERT INTO vendor_catalogs (cat_job_id, vendor_id) VALUES (?, ?)";
			PreparedStatement catalogInsert = conn.prepareStatement(query1);

			for (int i=0; i<catJobIds.length; i++) {
				
				catalogInsert.clearParameters();
				catalogInsert.setString(1, catJobIds[i]);
				catalogInsert.setInt(2, vendorId);

				if (vendorId == 0) {
					throw new Exception("Invalid Vendor Id");
				} else {
					catalogInsert.executeUpdate();
				}

			}

			String query2 = "INSERT INTO catalog_prices (catalog_price_definition_id, price, rfq, vendor_id, price_tier_id) values (?, ?, ?, ?, ?)";
			PreparedStatement insertDefaultCatalog = conn.prepareStatement(query2);

			for (int i=0; i<catJobIds.length; i++) {

				String query3 = "SELECT catalog_price_definition_id, price, rfq FROM catalog_default_prices WHERE cat_job_id = " + catJobIds[i];
				ResultSet rs2 = st0.executeQuery(query3);

				while (rs2.next()) {

					insertDefaultCatalog.clearParameters();
					insertDefaultCatalog.setInt(1, rs2.getInt("catalog_price_definition_id"));
					insertDefaultCatalog.setDouble(2, rs2.getDouble("price"));
					insertDefaultCatalog.setInt(3, rs2.getInt("rfq"));
					insertDefaultCatalog.setInt(4, vendorId);
					insertDefaultCatalog.setInt(5, 1);
					insertDefaultCatalog.executeUpdate();

				}

			}

			ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
			rpcs.printNextPage(this,request,response);

		} catch(Exception ex) {
			throw new ServletException("doPost error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	}

}
