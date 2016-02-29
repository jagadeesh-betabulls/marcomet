/**********************************************************************
Description:	This servlet rebuilds the entire grid_bridge table
**********************************************************************/

package com.marcomet.admin.catalog;

import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.marcomet.jdbc.DBConnect;

public class RebuildGridBridgeServlet extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		int insertedCount = 0;

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			Hashtable existingCatJobs = new Hashtable();

			Statement st0 = conn.createStatement();
			Statement st1 = conn.createStatement();

			st0.execute("DELETE FROM catalog_grid_bridge WHERE 1 = 1");

			//String query0 = "SELECT cr.id AS row_id, span, value, cs.sequence AS axis_sequence, cr.sequence AS span_sequence, cr.cat_job_id, catalog_page FROM catalog_rows cr, catalog_specs cs WHERE span < 99999 AND cr.cat_spec_id = cs.id AND cr.cat_job_id = cs.cat_job_id AND cr.catalog_page = cs.page and axis = " + axis + " ORDER BY cat_job_id, catalog_page, axis, axis_sequence, span_sequence";
			//String query1 = "SELECT DISTINCT vendor_id FROM catalog_prices cp, catalog_price_definitions cpd WHERE cpd.id = cp.catalog_price_definition_id AND cat_job_id = " + rs0.getString("cat_job_id");
			//String query2 = "SELECT cpd.id AS price_definition_id, row_number, column_number FROM catalog_prices cp, catalog_price_definitions cpd WHERE cpd.id = cp.catalog_price_definition_id AND cat_job_id = " + rs0.getString("cat_job_id") + " AND row_number < 100000 AND vendor_id = " + vendorId + " AND catalog_page = " + rs0.getString("catalog_page") + " AND " + relevantAxis + " <= " + (rs0.getInt("span") - 1);
			//String query3 = "SELECT cpd.id AS price_definition_id, row_number, column_number FROM catalog_prices cp, catalog_price_definitions cpd WHERE cpd.id = cp.catalog_price_definition_id AND cat_job_id = " + rs0.getString("cat_job_id") + " AND row_number < 100000 AND vendor_id = " + vendorId + " AND catalog_page = " + rs0.getString("catalog_page") + " AND " + spanTotal + " <= " + relevantAxis + " AND " + relevantAxis + " <= " + (rs0.getInt("span") + spanTotal - 1);
			//String query4 = "INSERT INTO catalog_grid_bridge VALUES(" + rs0.getString("row_id") + ", " + rs1.getString("price_definition_id") + ", " + rs0.getString("cat_job_id") + ", " + vendorId + ", " + rs0.getString("catalog_page") + ")";
	
			String query0 = "SELECT cr.id AS row_id, span, value, cs.sequence AS axis_sequence, cr.sequence AS span_sequence, cr.cat_job_id, catalog_page FROM catalog_rows cr, catalog_specs cs WHERE span < 99999 AND cr.cat_spec_id = cs.id AND cr.cat_job_id = cs.cat_job_id AND cr.catalog_page = cs.page and axis = ? ORDER BY cat_job_id, catalog_page, axis, axis_sequence, span_sequence";
			String query1 = "SELECT DISTINCT vendor_id FROM catalog_prices cp, catalog_price_definitions cpd WHERE cpd.id = cp.catalog_price_definition_id AND cat_job_id = ?";
			//String query2 = "SELECT cpd.id AS price_definition_id, row_number, column_number FROM catalog_prices cp, catalog_price_definitions cpd WHERE cpd.id = cp.catalog_price_definition_id AND cat_job_id = ? AND row_number < 100000 AND vendor_id = ? AND catalog_page = ? AND ? <= (? - 1)";
			//String query3 = "SELECT cpd.id AS price_definition_id, row_number, column_number FROM catalog_prices cp, catalog_price_definitions cpd WHERE cpd.id = cp.catalog_price_definition_id AND cat_job_id = ? AND row_number < 100000 AND vendor_id = ? AND catalog_page = ? AND ? <= ? AND ? <= ?";
			String query4 = "INSERT INTO catalog_grid_bridge VALUES(?, ?, ?, ?, ?)";

			PreparedStatement getRowInfo = conn.prepareStatement(query0);
			PreparedStatement getVendorId = conn.prepareStatement(query1);
			//PreparedStatement getPriceInfoA = conn.prepareStatement(query2);
			//PreparedStatement getPriceInfoB = conn.prepareStatement(query3);
			PreparedStatement bridgeInsert = conn.prepareStatement(query4);

			String relevantAxis = "column_number";

			for (int axis=722; axis<=723; axis++) {

				if (axis == 723)
					existingCatJobs = new Hashtable();

				// Create the bridge table entries based on the axis grid components

				int axisSequence = 0;
				int spanTotal = 0;

				getRowInfo.clearParameters();
				getRowInfo.setInt(1, axis);
				ResultSet rs0 = getRowInfo.executeQuery();

				if (rs0.next()) {

					do {

						getVendorId.clearParameters();
						getVendorId.setInt(1, rs0.getInt("cat_job_id"));
						ResultSet rs3 = getVendorId.executeQuery();

						Vector vendorIdVector = new Vector();
						while (rs3.next()) {
							vendorIdVector.addElement(rs3.getString("vendor_id"));
						}

						Object o = existingCatJobs.get(rs0.getString("cat_job_id"));

						if (o == null) {

							spanTotal = 0;
							axisSequence = 0;
							Hashtable existingPages = new Hashtable();
							existingPages.put(rs0.getString("catalog_page"), new Object());
							existingCatJobs.put(rs0.getString("cat_job_id"), existingPages);

						} else {

							Hashtable existingPages = (Hashtable)o;
							Object obj = existingPages.get(rs0.getString("catalog_page"));
							if (obj == null) {
								spanTotal = 0;
								axisSequence = 0;
								existingPages.put(rs0.getString("catalog_page"), new Object());
							}

						}

						for (int i=0; i<vendorIdVector.size(); i++) {

							String vendorId = (String)vendorIdVector.elementAt(i);
							ResultSet rs1 = null;

							if (axis == 723) {
								relevantAxis = "row_number";
							}

							String queryX = null;

							if (rs0.getInt("axis_sequence") > axisSequence) {

								queryX = "SELECT cpd.id AS price_definition_id, row_number, column_number FROM catalog_price_definitions cpd WHERE cat_job_id = " + rs0.getString("cat_job_id") + " AND row_number < 100000 AND catalog_page = " + rs0.getString("catalog_page") + " AND " + relevantAxis + " <= " + (rs0.getInt("span") - 1);

								if (i == vendorIdVector.size() - 1) {
									spanTotal = rs0.getInt("span");
									axisSequence = rs0.getInt("axis_sequence");
								}

							} else {

								queryX = "SELECT cpd.id AS price_definition_id, row_number, column_number FROM catalog_price_definitions cpd WHERE cat_job_id = " + rs0.getString("cat_job_id") + " AND row_number < 100000 AND catalog_page = " + rs0.getString("catalog_page") + " AND " + spanTotal + " <= " + relevantAxis + " AND " + relevantAxis + " <= " + (rs0.getInt("span") + spanTotal - 1);

								if (i == vendorIdVector.size() - 1)
									spanTotal = spanTotal + rs0.getInt("span");
	
							}

							rs1 = st1.executeQuery(queryX);

							if (rs1.next()) {

								do {

									bridgeInsert.clearParameters();
									bridgeInsert.setInt(1, rs0.getInt("row_id"));
									bridgeInsert.setInt(2, rs1.getInt("price_definition_id"));
									bridgeInsert.setInt(3, rs0.getInt("cat_job_id"));
									bridgeInsert.setString(4, vendorId);
									bridgeInsert.setInt(5, rs0.getInt("catalog_page"));
									bridgeInsert.executeUpdate();

									insertedCount++;

								} while (rs1.next());

							}

						}

					} while(rs0.next());

				} else {
					throw new Exception("No results returned for query \n\t" + query0);
				}

			}

			RequestDispatcher rd = getServletContext().getRequestDispatcher("/admin/catalog/GridBridgeTableRebuilder.jsp?insertedCount=" + insertedCount);
			rd.forward(request, response);

		} catch (Exception ex) {
			throw new ServletException("RebuildGridBridgeServlet error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	}

}