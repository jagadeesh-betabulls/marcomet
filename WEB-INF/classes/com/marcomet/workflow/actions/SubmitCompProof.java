package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will recieve/update db for a submited Comp/Proof.

**********************************************************************/

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;

public class SubmitCompProof implements ActionInterface {
	
	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {

		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String stage = mr.getParameter("stage");
			String formId = "1";
			String groupId = mr.getParameter("groupId");

			String query = "insert into form_messages (job_id, contact_id, form_id, group_id, message) values (?, ?, ?, ?, ?)";
			
			if (!stage.equals("interim")) {
				formId = "2";
			}

			PreparedStatement update = conn.prepareStatement(query);
			update.clearParameters();
			update.setInt(1, Integer.parseInt(mr.getParameter("jobId")));
			update.setString(2, mr.getParameter("userId"));
			update.setString(3, formId);
			update.setString(4, groupId);
			update.setString(5, mr.getParameter("message"));
			update.execute();

			ShippedMaterialsProcessor smp = new ShippedMaterialsProcessor();
			smp.execute(mr, "Submitted");
						
		} catch (Exception ex) {
			throw new Exception("Submit Comp Proof Error occured " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new Hashtable();
	}
}
