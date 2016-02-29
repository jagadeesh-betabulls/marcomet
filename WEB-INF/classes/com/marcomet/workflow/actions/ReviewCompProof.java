package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will recieve/update db for a submited Comp/Proof.
**********************************************************************/

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Hashtable;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;

public class ReviewCompProof implements ActionInterface {


	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();

			int approvalType = 0;
			int value = 0;
			String temp = (String)request.getParameter("comp");

			StringTokenizer tokenizer = new StringTokenizer(temp, ":");
			if (tokenizer.hasMoreElements()) {
				approvalType = Integer.parseInt((String)tokenizer.nextElement());
				value = Integer.parseInt((String)tokenizer.nextElement());
			}

			int id = 0;
			int groupId = 0;
			String status = null;
			
			int fileCount = Integer.parseInt((String)request.getParameter("fileCount"));			
			String fileQuery = "UPDATE file_meta_data SET status = ?, reply = ? WHERE id = ?";
			PreparedStatement updateFMD = conn.prepareStatement(fileQuery);

			for (int i=0; i<fileCount; i++) {
				id = Integer.parseInt((String)request.getParameter("file" + i));
				if ((approvalType == 1) && (id == value)) {
					status = "Accepted";
				} else if ((approvalType == 0) && (id == value)) {
					status= "Modified";
				} else {
					status = "Rejected";
				}

				updateFMD.clearParameters();
				updateFMD.setString(1, status);
				updateFMD.setString(2, request.getParameter("fileComments" + i));
				updateFMD.setInt(3, new Integer(id).intValue());
				updateFMD.execute();
				
				Statement st = conn.createStatement();
				ResultSet rs0 = st.executeQuery("SELECT group_id FROM file_meta_data WHERE id = " + id);
				if (rs0.next())
					groupId = rs0.getInt("group_id");
			}
			

			int materialCount = Integer.parseInt((String)request.getParameter("materialCount"));			
			String materialQuery = "UPDATE material_meta_data SET status = ?, reply = ? WHERE id = ?";
			PreparedStatement updateMMD = conn.prepareStatement(materialQuery);
			
			for (int i=0; i<materialCount; i++) {
				id = Integer.parseInt((String)request.getParameter("material" + i));
				if ((approvalType == 1) && (id == value)) {
					status = "Accepted";
				} else if ((approvalType == 0) && (id == value)) {
					status= "Modified";
				} else {
					status = "Rejected";
				}

				updateMMD.clearParameters();
				updateMMD.setString(1, status);
				updateMMD.setString(2, request.getParameter("materialComments" + i));
				updateMMD.setInt(3, new Integer(id).intValue());
				updateMMD.execute();

				Statement st1 = conn.createStatement();
				ResultSet rs1 = st1.executeQuery("SELECT group_id FROM material_meta_data WHERE id = " + id);
				if (rs1.next())
					groupId = rs1.getInt("group_id");
				
			}
			
			HttpSession session = request.getSession();
			String userId = (String)session.getAttribute("contactId");
			
			String returnComments = request.getParameter("return_romments");
			String messageQuery = "INSERT INTO form_messages (job_id, contact_id, form_id, message, group_id) VALUES (?, ?, ?, ?, ?)";
			PreparedStatement insertMessage = conn.prepareStatement(messageQuery);
			insertMessage.clearParameters();
			insertMessage.setInt(1, Integer.parseInt(request.getParameter("jobId")));
			insertMessage.setString(2, userId);
			insertMessage.setString(3, "8");
			insertMessage.setString(4, request.getParameter("message"));
			insertMessage.setInt(5, groupId);			
			insertMessage.execute();
			
		} catch(Exception ex) {
			throw new Exception("The following error occurred in ApproveCompProof " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return new Hashtable();
	}
}
