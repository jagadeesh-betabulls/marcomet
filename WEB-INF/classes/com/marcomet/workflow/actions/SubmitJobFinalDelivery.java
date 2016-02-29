package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class handles the submittion of a job's final delivery.
**********************************************************************/

import java.sql.*;
import java.util.*;
import javax.servlet.http.*;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.files.MultipartRequest;

public class SubmitJobFinalDelivery implements ActionInterface{

	
	public SubmitJobFinalDelivery() {
		
	}
	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String query = "insert into form_messages (job_id, contact_id, form_id, message) values (?, ?, ?, ?)";
			PreparedStatement insert = conn.prepareStatement(query);
			insert.clearParameters();
			insert.setString(1, mr.getParameter("jobId"));
			insert.setString(2, mr.getParameter("userId"));
			insert.setString(3, "4");
			insert.setString(4, mr.getParameter("message"));
			insert.execute();

			ShippedMaterialsProcessor smp = new ShippedMaterialsProcessor();
			smp.complete(mr);
						
		} catch (Exception ex) {
			throw new Exception("SubmitJobFinalDelivery Error occured " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		try {

		} catch(Exception ex) {
			throw new Exception("You shouldn't be seeing this");
		}
		
		return new Hashtable();
	}
	public void finalize() {
		
	}
}
