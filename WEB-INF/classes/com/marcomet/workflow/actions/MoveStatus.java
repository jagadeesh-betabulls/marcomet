package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will update the status of a job
**********************************************************************/

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessJob1;
import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;

public class MoveStatus implements ActionInterface {

		
	public MoveStatus() {
		
	}
	
	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {

		int jobId = Integer.parseInt(mr.getParameter("jobId"));
		int actionId = Integer.parseInt(mr.getParameter("nextStepActionId"));

		this.updateStatus(jobId, actionId);
		
		return new Hashtable();
	}
	
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception{
	
		int jobId = Integer.parseInt(request.getParameter("jobId"));
		int actionId = Integer.parseInt(request.getParameter("nextStepActionId"));
		
		this.updateStatus(jobId, actionId);
		
		return new Hashtable();
	}
	protected void finalize() {
		
	}
	public void updateStatus(int jobId, int actionId) throws SQLException { 

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			int nextStatusNumber = 0;
			String sql = "SELECT currentstatus, nextstatus FROM jobflowactions WHERE id =" + actionId;
			ProcessJob1 pj = new ProcessJob1();
			
			Statement qs = conn.createStatement();
			ResultSet rs1 = qs.executeQuery(sql);
			if (rs1.next()) {
				pj.updateJob(jobId,"last_status_id",rs1.getInt(1));        	//load up current statusid
				pj.updateJob(jobId,"status_id",rs1.getInt(2));				//save new statusid
				nextStatusNumber = rs1.getInt(1);
			}	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
}
