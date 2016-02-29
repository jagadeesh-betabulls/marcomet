package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class handles the decline of a job's final delivery /
				plus the reconsoliation portion(messages) from the vendor
**********************************************************************/

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;

public class SubmitFinalDeliveryReview  implements ActionInterface {

	
	
	public SubmitFinalDeliveryReview() {
		
	}
	public Hashtable execute(MultipartRequest mr, HttpServletResponse res) throws Exception {
		
		return new Hashtable();
		
	}
	public Hashtable execute(HttpServletRequest req, HttpServletResponse res) 
	throws Exception{

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
		
			String query = "insert into form_messages (job_id, contact_id, form_id, message) values (?, ?, ?, ?)";
			PreparedStatement insert = conn.prepareStatement(query);
			insert.clearParameters();
			insert.setString(1, req.getParameter("jobId"));
			insert.setString(2, (String)req.getSession().getAttribute("contactId"));
			insert.setString(3, "5");
			insert.setString(4, req.getParameter("message"));
			insert.execute();		
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		return new Hashtable();
						
	}
	public void finalize() {
		
	}
}
