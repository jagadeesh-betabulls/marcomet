/**********************************************************************
Description:	This servlet populates the bridge table for grid administration
**********************************************************************/

package com.marcomet.admin.catalog;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.jdbc.DBConnect;

public class GridBridgeServlet extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		int insertedCount = 0;
		int vendorId = Integer.parseInt(request.getParameter("vendorId"));
		int catJobId = Integer.parseInt(request.getParameter("catJobId"));
		int catalogPage = Integer.parseInt(request.getParameter("catalogPage"));

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			Statement st0 = conn.createStatement();
			Statement st1 = conn.createStatement();
			Statement st2 = conn.createStatement();

			st2.execute("DELETE FROM catalog_grid_bridge WHERE cat_job_id = " + catJobId + " AND vendor_id = " + vendorId + " AND catalog_page = " + catalogPage);
							
			String relevantAxis = "column_number";
			for (int axis=722; axis<=723; axis++) {
				// Create the bridge table entries based on the axis grid components
				int axisSequence = 0;
				int spanTotal = 0;
				String query0 = "SELECT cr.id AS row_id, span, value, cs.sequence AS axis_sequence, cr.sequence AS span_sequence FROM catalog_rows cr, catalog_specs cs WHERE span < 99999 AND cr.cat_job_id = " + catJobId + " AND cr.cat_spec_id = cs.id AND cr.cat_job_id = cs.cat_job_id AND catalog_page = " + catalogPage + " AND cr.catalog_page = cs.page and axis = " + axis + " ORDER BY axis, axis_sequence, span_sequence";
				ResultSet rs0 = st0.executeQuery(query0);
				if (rs0.next()) {
					do {
						if (axis == 723)
							relevantAxis = "row_number";
						String query1 = "";
						if (rs0.getInt("axis_sequence") > axisSequence) {
							axisSequence = rs0.getInt("axis_sequence");
							query1 = "SELECT id AS price_definition_id, row_number, column_number FROM catalog_price_definitions WHERE cat_job_id = " + catJobId + " AND row_number < 100000 AND catalog_page = " + catalogPage + " AND " + relevantAxis + " <= " + (rs0.getInt("span") - 1);
							spanTotal = rs0.getInt("span");
						} else {
							query1 = "SELECT id AS price_definition_id, row_number, column_number FROM catalog_price_definitions WHERE cat_job_id = " + catJobId + " AND row_number < 100000 AND catalog_page = " + catalogPage + " AND " + spanTotal + " <= " + relevantAxis + " AND " + relevantAxis + " <= " + (rs0.getInt("span") + spanTotal - 1);
							spanTotal = spanTotal + rs0.getInt("span");	
						}
						ResultSet rs1 = st1.executeQuery(query1);
						if (rs1.next()) {
							do {
								st2.executeUpdate("INSERT INTO catalog_grid_bridge VALUES(" + rs0.getString("row_id") + "," + rs1.getString("price_definition_id") + ", " + catJobId + ", " + vendorId + ", " + catalogPage + ")");
								insertedCount++;
							} while (rs1.next());
						}
					} while(rs0.next());
				} else {
					throw new Exception("No results returned for query \n\t" + query0);
				}
			}

			RequestDispatcher rd = getServletContext().getRequestDispatcher("/admin/catalog/GridBridgeTableManager.jsp?insertedCount=" + insertedCount);
			rd.forward(request, response);

		} catch (Exception ex) {
			throw new ServletException("GridBridgeServlet error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	}

}