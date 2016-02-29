package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will recieve/update db for a submited Comp/Proof.
**********************************************************************/

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;

public class ShippedMaterialsProcessor {
	
	
	public void complete(MultipartRequest mr) throws Exception {

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();

			String query = "update shipping_data set date = ?, method = ?, reference = ? where status = 'final' and job_id = " + mr.getParameter("jobId");
			PreparedStatement update = conn.prepareStatement(query);
	
			update.clearParameters();
			update.setString(1, mr.getParameter("shipdate"));
			update.setString(2, mr.getParameter("method"));
			update.setString(3, mr.getParameter("reference"));
			update.execute();
		
		} catch(Exception ex) {
			throw new Exception("Error in ProcessShippedMaterials " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	} // complete
	
	public void execute(MultipartRequest mr, String status) throws Exception {

		if (!(mr.getParameter("cost").equals("")) && !(mr.getParameter("cost") == null)) {


			Connection conn = null; 

			try {			
				conn = DBConnect.getConnection();

				HttpSession session = mr.getSession();
				String userId = (String)session.getAttribute("contactId");

				PreparedStatement lockTable = conn.prepareStatement("LOCK TABLES shipping_data WRITE");
				PreparedStatement unlockTable = conn.prepareStatement("UNLOCK TABLES");
				PreparedStatement getMaxId = conn.prepareStatement("select max(id) as shipping_id from shipping_data");
				
				String query = "insert into shipping_data (date, method, reference, cost, mu, fee, price, job_id, user_id, shipped_to, shipped_from, status) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 'seller', 'buyer', ?)";
				PreparedStatement shipping = conn.prepareStatement(query);
				shipping.clearParameters();
				shipping.setString(1, mr.getParameter("shipdate"));
				shipping.setString(2, mr.getParameter("method"));
				shipping.setString(3, mr.getParameter("reference"));
				shipping.setString(4, mr.getParameter("cost"));
				shipping.setString(5, mr.getParameter("mu"));
				shipping.setString(6, mr.getParameter("fee"));
				shipping.setString(7, mr.getParameter("price"));
				shipping.setString(8, mr.getParameter("jobId"));
				shipping.setString(9, userId);
				shipping.setString(10, mr.getParameter("shippingStatus"));

				//Lock the shipping table, insert, get the max id and move on
				lockTable.execute();
				shipping.execute();
				ResultSet rs = getMaxId.executeQuery();
				unlockTable.execute();

				int shippingId = 0;
				while (rs.next()) {
					shippingId = rs.getInt("shipping_id");
				}

				if (!(shippingId > 0)) {
					throw new Exception("Invalid Shipping Id " + shippingId);
				}

				String projectId = "";
				Statement st = conn.createStatement();
				ResultSet rs0 = st.executeQuery("SELECT j.project_id FROM jobs j WHERE j.id = " + mr.getParameter("jobId"));
				while (rs0.next()) {
					projectId = rs0.getString("project_id");
				}

				for (int i=0; i<3; i++) {
					String material = mr.getParameter("material" + i);
					if ((!material.equals(" ")) && (!material.equals("")) && (material != null)) {
						query = "insert into material_meta_data (file_name, description, company_id, user_id, project_id, job_id, status, shipping_data_id, category, group_id, comments) values (?, ?, ?, ?, ?, ?, ?, ?, 'Comp', ?, ?)";
						PreparedStatement materials = conn.prepareStatement(query);
						materials.clearParameters();
						materials.setString(1, material);
						materials.setString(2, mr.getParameter("mDescription" + i));
						materials.setString(3, mr.getParameter("companyId"));
						materials.setString(4, userId);
						materials.setString(5, projectId);
						materials.setString(6, mr.getParameter("jobId"));
						materials.setString(7, status);
						materials.setInt(8, shippingId);
						materials.setString(9, mr.getParameter("groupId"));
						materials.setString(10, mr.getParameter("mComments" + i));
						materials.execute();
					}
				}
			} catch(Exception ex) {
				throw new Exception("Error in ShippedMaterialsProcessor " + ex.getMessage());
			} finally {
				try { conn.close(); } catch ( Exception x) { conn = null; }
			}
		} //if
	}
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception{

		if (!(request.getParameter("cost").equals("")) && !(request.getParameter("cost") == null)) {

			Connection conn = null; 

			try {			
				conn = DBConnect.getConnection();
				HttpSession session = request.getSession();
				String userid = (String)session.getAttribute("contactId");

				String query = "insert into shipping_data (date, method, reference, cost, mu, fee, price, job_id, user_id, shipped_to, shipped_from, description, status,shipping_quantity,product_id,warehouse_id,handling,subvendor_handling) values (?,?,?,?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)";
				PreparedStatement shipping = conn.prepareStatement(query);
				shipping.clearParameters();
				shipping.setString(1, request.getParameter("shipdate"));
				shipping.setString(2, request.getParameter("method"));
				shipping.setString(3, request.getParameter("reference"));
				shipping.setString(4, request.getParameter("cost"));
				shipping.setString(5, request.getParameter("mu"));
				shipping.setString(6, request.getParameter("fee"));
				shipping.setString(7, request.getParameter("price"));
				shipping.setString(8, request.getParameter("jobId"));
				shipping.setString(9, userid);
				shipping.setString(10, request.getParameter("shippedTo"));
				shipping.setString(11, request.getParameter("shippedFrom"));
				shipping.setString(12, request.getParameter("description"));
				shipping.setString(13, request.getParameter("shippingStatus"));
				shipping.setString(14, request.getParameter("quantity"));
				shipping.setString(15, request.getParameter("productId"));	
				shipping.setString(17, request.getParameter("warehouse_id"));
				shipping.setString(15, request.getParameter("handling"));
				shipping.setString(16, request.getParameter("svhandling"));

				shipping.execute();

			} catch(Exception ex) {
				throw new Exception("Error in ProcessShippedMaterials " + ex.getMessage());
			} finally {
				try { conn.close(); } catch ( Exception x) { conn = null; }
			}
		} //if
	}
	public void finalize() {
		
	}
}
