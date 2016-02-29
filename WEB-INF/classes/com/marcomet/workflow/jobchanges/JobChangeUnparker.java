package com.marcomet.workflow.jobchanges;

/**********************************************************************
Description:	This class will UNpark a job change submitted status

History:
	Date		Author			Description
	----		------			-----------
	10/8/2001	Tom Dietrich	Created

**********************************************************************/

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.StringTokenizer;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessJob1;
import com.marcomet.commonprocesses.ProcessJobChange;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.mail.JavaMailer1;
import com.marcomet.tools.ReturnPageContentServlet;
import com.marcomet.tools.SimpleLookups;
import com.marcomet.tools.StringTool;
import com.marcomet.workflow.emailbodies.EmailBodyInterface;



public class JobChangeUnparker extends HttpServlet{

	private void approveChange(HttpServletRequest request)
	throws SQLException{
		
		ProcessJobChange pjc = new ProcessJobChange();
		StringTool st = new StringTool();
		DateFormat mysqlFormat = new SimpleDateFormat("yyyy-MM-dd");
		
		pjc.setJobId(request.getParameter("jobId"));
		pjc.updateJobChangeJobId("comments",request.getParameter("comments"));
		pjc.updateJobChangeJobId("statusid",2);
		pjc.updateJobChangeJobId("customerdate",mysqlFormat.format(new java.util.Date()));
		pjc.updateJobChangeJobId("customerid",(String)request.getSession().getAttribute("contactId"));
		
		//reset status id to before change was submitted
		SimpleLookups slups = new SimpleLookups();
		String sql = "UPDATE jobs SET status_id = last_status_id, last_status_id = 99 WHERE jobs.id = " + request.getParameter("jobId");
		slups.simpleQuery(sql);

		try {
			com.marcomet.workflow.actions.CalculateJobCosts cjc = new com.marcomet.workflow.actions.CalculateJobCosts();
			cjc.calculate((String)request.getParameter("jobId"));
		} catch (Exception ex) {
		}

		sendEmail(request, "com.marcomet.workflow.emailbodies.JobChangeApproved");
					
	}
	private void cancelJob(HttpServletRequest request)
	throws SQLException{		
	
		DateFormat mysqlFormat = new SimpleDateFormat("yyyy-MM-dd");	
		
		ProcessJob1 pj = new ProcessJob1();
		pj.updateJob(Integer.parseInt(request.getParameter("jobId")), "cancelation_date",mysqlFormat.format(new java.util.Date()));	
		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String sql = "INSERT INTO form_messages(job_id, contact_id, form_id, message) VALUES (?,?,?,?)";	
			PreparedStatement insertMessage = conn.prepareStatement(sql);
			insertMessage.clearParameters();
	
			insertMessage.setInt(1,Integer.parseInt(request.getParameter("jobId")));
			insertMessage.setInt(2,Integer.parseInt((String)request.getSession().getAttribute("contactId")));
			insertMessage.setInt(3,7);
			insertMessage.setString(4,"Job Canceled, at job change review");
		
			insertMessage.executeUpdate();	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}	
	
		//reset status id to canceled
		SimpleLookups slups = new SimpleLookups();
		String sql = "UPDATE jobs SET last_status_id = status_id, status_id = 9 WHERE jobs.id = " + request.getParameter("jobId");
		slups.simpleQuery(sql);
		
		sendEmail(request, "com.marcomet.workflow.emailbodies.JobCancelation");
	}
	private void declineChange(HttpServletRequest request)
	throws SQLException{
		
		ProcessJobChange pjc = new ProcessJobChange();
		StringTool st = new StringTool();
		DateFormat mysqlFormat = new SimpleDateFormat("yyyy-MM-dd");
		
		pjc.setJobId(request.getParameter("jobId"));
		pjc.updateJobChangeJobId("comments",request.getParameter("comments"));
		pjc.updateJobChangeJobId("statusid",3);
		pjc.updateJobChangeJobId("customerdate",mysqlFormat.format(new java.util.Date()));
		pjc.updateJobChangeJobId("customerid",(String)request.getSession().getAttribute("contactId"));
		
		//reset status id to before change was submitted
		SimpleLookups slups = new SimpleLookups();
		String sql = "UPDATE jobs SET status_id = last_status_id, last_status_id = 99 WHERE jobs.id = " + request.getParameter("jobId");
		slups.simpleQuery(sql);
		
		sendEmail(request, "com.marcomet.workflow.emailbodies.JobChangeDeclined");	
	}
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
	
		try{
			switch(Integer.parseInt(request.getParameter("changeStatus"))){
				case 1: approveChange(request); 
						break;
				case 2: declineChange(request); 
						break;
				case 3: cancelJob(request); 
						break;	
			}
		}catch(SQLException sqle){
			System.err.println("JobChangeUnparker sqle: " + sqle.getMessage());
		}
	
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this, request, response);				
	}
	private void sendEmail(HttpServletRequest request, String emailKey){
		String vendorEmail;
		String buyerEmail;
		String vendorEmailId;
		String buyerEmailId;
		String jobId=((request.getParameter("jobId")==null)?"0":request.getParameter("jobId"));
		
		//jdbc lookups section
		
		Connection conn = null;
		
		try{
			conn = DBConnect.getConnection();
			
			String sqlBuyer = "SELECT c.email 'email',c.id 'emailId'  FROM jobs j, projects p, orders o, contacts c WHERE j.project_id = p.id AND p.order_id = o.id AND c.id = o.buyer_contact_id AND j.id = " + jobId;			
			ResultSet rsEmail = conn.createStatement().executeQuery(sqlBuyer);
			
			if(rsEmail.next()){
				buyerEmail = rsEmail.getString("email");	
				buyerEmailId = rsEmail.getString("emailId");	
			}else{
				System.err.println("JobChangeParker, couldn't find buyer email, jobId: " + jobId);
				return;
			}
			
			String sqlVendor = "SELECT c.email 'email',c.id 'emailId'  FROM jobs j, contacts c WHERE c.id = j.vendor_contact_id AND j.id = " + jobId;	
			rsEmail = conn.createStatement().executeQuery(sqlVendor);
			
			if(rsEmail.next()){
				vendorEmail = rsEmail.getString("email");	
				vendorEmailId = rsEmail.getString("emailId");	
			}else{
				System.err.println("JobChangeParker, couldn't find vendor email, jobId: " + request.getParameter("jobId"));
				return;			
			}
		
		}catch(SQLException sqle){
			System.err.println("");
			return;		
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
			return;		
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	
		//************** mailling section	*****************
		//get email body builder
		EmailBodyInterface ebi;
		try{
			ebi = (EmailBodyInterface)Class.forName(emailKey).newInstance();	
		}catch(ClassNotFoundException cnfe){
			System.err.println("JobChangeUnparker email body class failed, cnfe: " + cnfe.getMessage());
			return;
		}catch(ClassCastException cce){
			System.err.println("JobChangeUnparker email body class failed, cce: " + cce.getMessage());
			return;
		}catch(InstantiationException ie){
			System.err.println("JobChangeUnparker email body class failed, ie: " + ie.getMessage());
			return;
		}catch(IllegalAccessException iae){
			System.err.println("JobChangeUnparker email body class failed, cce: " + iae.getMessage());
			return;	
		}
			
		//mailer tool
		JavaMailer1 mail = new JavaMailer1();
		
		
		mail.setTo(buyerEmail);
		mail.setFrom(vendorEmail);
		mail.setEmailToId(buyerEmailId);
		mail.setEmailFromId(vendorEmailId);
		mail.setJobId(jobId);
		
		try{
			mail.setBody(ebi.getBody(request));
		}catch(SQLException sqle){
			System.err.println("Emailer for JobChangeParker, setBody, failed: " + request.getParameter("jobId") + ", sqle: " + sqle.getMessage());	
			return;
		}

		String title = "";

		try {

			//get the email title to throw in the subject
			String key = "";
			Statement st2 = conn.createStatement();
			StringTokenizer token = new StringTokenizer(emailKey, ".");
			while (token.hasMoreTokens()) {
				key = token.nextToken();
			}

			String query0 = "SELECT email_subject FROM email_form_letters WHERE email_key = \"" + key + "\"";
			ResultSet rs2 = st2.executeQuery(query0);
			if (rs2.next())
				title = rs2.getString("email_subject");

		} catch (SQLException ex) {}
	
		mail.setSubject(ebi.getSubject() + " - " + title);
		
		try {
			mail.send();
		} catch(Exception e) {
			System.err.println("Emailer for JobChangeParker, send failed: " + request.getParameter("jobId") + ", e: " + e.getMessage());
			return;
		}	
				
	}
}
