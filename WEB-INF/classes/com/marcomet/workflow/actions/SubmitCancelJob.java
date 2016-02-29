package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class handles the submission of a job cancellation 
								
**********************************************************************/


import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;


public class SubmitCancelJob implements ActionInterface{

		
	public SubmitCancelJob() {
		
	}
	public Hashtable execute(MultipartRequest mr, HttpServletResponse res) throws Exception {
		
		return new Hashtable();
		
	}
	public Hashtable execute(HttpServletRequest req, HttpServletResponse res) 
	throws Exception{		

		//DateFormat mysqlFormat = new SimpleDateFormat("yyyy-MM-dd");	
		//ProcessJob pj = new ProcessJob();
		//pj.updateJob(Integer.parseInt(req.getParameter("jobId")), "cancelation_date",mysqlFormat.format(new java.util.Date()));	
		
		
		//cancellation message store
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String sql = "insert into form_messages(job_id, contact_id, form_id, message)values(?,?,?,?)";	
			PreparedStatement updateJob = conn.prepareStatement(sql);
			updateJob.clearParameters();
			updateJob.setInt(1,Integer.parseInt(req.getParameter("jobId")));
			updateJob.setInt(2,Integer.parseInt((String)req.getSession().getAttribute("contactId")));
			updateJob.setInt(3,7);
			updateJob.setString(4,"Job Cancelled");
			
			updateJob.execute();
			
			//update post_date on the job if the job was cancelled
			Statement st = conn.createStatement();	
			
			String updatePostCancelledJobs ="update jobs j set cancelation_date=Now(),cancelled_date=Now(),post_date=cancelled_date,accrued_po_cost=0,accrued_shipping=0,accrued_inventory_cost=0,est_material_cost=0  where post_date is null and j.id="+req.getParameter("jobId");
			st.execute(updatePostCancelledJobs);
		} catch (Exception ex) {
			throw new Exception("CalculateJobCosts:updatePostCancelledJobs " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
						
		return new Hashtable();			
	}
	protected void finalize() {
		
	}
}
