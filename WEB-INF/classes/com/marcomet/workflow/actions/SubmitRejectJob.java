package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class handles the rejection of a job 
**********************************************************************/


import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessJob1;
import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.StringTool;


public class SubmitRejectJob implements ActionInterface{

	
	
	public SubmitRejectJob() {
		
	}
	public Hashtable execute(MultipartRequest mr, HttpServletResponse res) throws Exception {
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest req, HttpServletResponse res) 
	throws Exception{
		
		ProcessJob1 pj = new ProcessJob1();
		StringTool st = new StringTool();
		
		pj.setId(req.getParameter("jobId"));
		//pj.updateJob("cancelation_message","rejected before confirmation");
		pj.updateJob("cancelation_date",st.mysqlFormatDate("1/1/2001"));
		
		///new message table gotta clean this up
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
		
			String query = "insert into form_messages (job_id, contact_id, form_id, message) values (?, ?, ?, ?)";
			PreparedStatement insert = conn.prepareStatement(query);
			insert.clearParameters();
			insert.setString(1, req.getParameter("jobId"));
			insert.setString(2, (String)req.getSession().getAttribute("contactId"));
			insert.setString(3, "6");
			insert.setString(4, "rejected before confirmation");
			insert.execute();
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		return new Hashtable();
			
	}
	public void finalize() {
		
	}
}
