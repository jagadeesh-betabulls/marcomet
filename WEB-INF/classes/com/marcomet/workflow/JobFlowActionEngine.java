package com.marcomet.workflow;

/**********************************************************************
Description:	This class will dynamicly look up actions and perform them
				as needed.

History:
	Date		Author			Description
	----		------			-----------
	4/11/2001	Thomas Dietrich	Created
	4/16/01		Brian			Added support for multipart/form-data
	6/26/01		td				removed nextActionJobId, now using just jobId
	8/14/01		td				removed jobId since code that used is missing yet, this still works.

**********************************************************************/

import com.marcomet.files.MultipartRequest;
import com.marcomet.workflow.actions.*;
import com.marcomet.workflow.*;
import com.marcomet.jdbc.*;

import java.sql.*;
import javax.servlet.http.*;
import javax.servlet.*;


public class JobFlowActionEngine {
	
	public JobFlowActionEngine() {		
		
	}
	
	public void execute(MultipartRequest mr, HttpServletResponse res) throws Exception {

		//int jobId = Integer.parseInt(mr.getParameter("jobId"));
		int actionId = Integer.parseInt(mr.getParameter("nextStepActionId"));
		Connection conn = null;
		
		try {
		
			conn = DBConnect.getConnection();
		
			String sql = "select * from jobflowstatuschangeactions where actionid = " + actionId + "  order by actionorder";
			Statement qs = conn.createStatement();
			ResultSet rs1 = qs.executeQuery(sql);
	
			while (rs1.next()) {
				ActionInterface ai = (ActionInterface)Class.forName(rs1.getString("javaclass")).newInstance();
				ai.execute(mr,res);
			}
		
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	}
	
	public void execute(HttpServletRequest req, HttpServletResponse res) throws Exception {

		//int jobId = Integer.parseInt(req.getParameter("jobId"));
		int actionId = Integer.parseInt(req.getParameter("nextStepActionId"));

Connection conn = null;
		
		try {
		
			conn = DBConnect.getConnection();

			String sql = "select * from jobflowstatuschangeactions where actionid = " + actionId + "  order by actionorder";
			Statement qs = conn.createStatement();
			ResultSet rs1 = qs.executeQuery(sql);
	
			while (rs1.next()) {
				ActionInterface ai = (ActionInterface)Class.forName(rs1.getString("javaclass")).newInstance();
				ai.execute(req,res);
			}
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	protected void finalize() {
		
	}
}
