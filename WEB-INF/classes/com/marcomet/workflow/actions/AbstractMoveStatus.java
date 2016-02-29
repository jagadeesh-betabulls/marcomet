package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This abstract class handles status updates for various
				types of request objects

History:
	Date		Author			Description
	----		------			-----------
	4/16/2001	Brian Murphy	Created

**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.commonprocesses.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.JspException;

import com.marcomet.files.MultipartRequest;

public abstract class AbstractMoveStatus implements ActionInterface {
	
	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {

		int jobId = Integer.parseInt(mr.getParameter("nextStepJobId"));
		int actionId = Integer.parseInt(mr.getParameter("nextStepActionId"));
		
		this.updateStatus(jobId, actionId);
		
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception{
	
		int jobId = Integer.parseInt(request.getParameter("nextStepJobId"));
		int actionId = Integer.parseInt(request.getParameter("nextStepActionId"));
		
		this.updateStatus(jobId, actionId);
		
		return new Hashtable();
	}
	public void updateStatus(int jobId, int actionId) throws SQLException { 
	
		int nextStatusNumber = 0;
		String sql = "select currentstatus, nextstatus from jobflowactions where id =" + actionId;
		ProcessJob1 pj = new ProcessJob1();
		
		Connection conn = null; 
		
		try {
			conn = DBConnect.getConnection();
			Statement qs = conn.createStatement();
			ResultSet rs1 = qs.executeQuery(sql);
			if (rs1.next()) {
				pj.updateJob(jobId,"laststatusid",rs1.getInt(1));        	//load up current statusid
				pj.updateJob(jobId,"statusid",rs1.getInt(2));				//save new statusid
				nextStatusNumber = rs1.getInt(1);
			}	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		//return nextStatusNumber;
	}
}
