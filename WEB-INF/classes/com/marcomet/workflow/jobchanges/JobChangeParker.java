package com.marcomet.workflow.jobchanges;


import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessJobChange;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.mail.JavaMailer1;
import com.marcomet.tools.ReturnPageContentServlet;
import com.marcomet.workflow.emailbodies.JobProposedChange;
import com.marcomet.workflow.actions.CalculateJobCosts;;

public class JobChangeParker extends HttpServlet{

	
	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			
			//save job change information
			ProcessJobChange pjc = new ProcessJobChange();
			CalculateJobCosts cjc = new CalculateJobCosts();
			pjc.setJobId(Integer.parseInt(request.getParameter("jobId")));
			pjc.setCreatedById(Integer.parseInt(request.getParameter("contactId")));
			pjc.setChangeTypeId((request.getParameter("changeTypeId").equals(""))?0:Integer.parseInt(request.getParameter("changeTypeId")));				
			pjc.setReason(request.getParameter("proposedChangeReason"));
			pjc.setCost((request.getParameter("cost").equals(""))?0:Double.parseDouble(request.getParameter("cost")));
			pjc.setMu((request.getParameter("mu").equals(""))?0:Double.parseDouble(request.getParameter("mu")));
			pjc.setFee((request.getParameter("fee").equals(""))?0:Double.parseDouble(request.getParameter("fee")));
			pjc.setPrice((request.getParameter("price").equals(""))?0:Double.parseDouble(request.getParameter("price")));
					
			pjc.setStatusId((((request.getParameter("changeTypeId").equals("1") || request.getParameter("changeTypeId").equals("2") || request.getParameter("changeTypeId").equals("3")))?1:2));
			pjc.insertJobChange();
			cjc.calculate(Integer.parseInt(request.getParameter("jobId")));
			
			//If the job needs approval, park the job by giving it a statusid = 99, otherwise set the approved date and customer id
			if (request.getParameter("changeTypeId").equals("1") || request.getParameter("changeTypeId").equals("2") || request.getParameter("changeTypeId").equals("3")){
				String query = "UPDATE jobs SET last_status_id = status_id, status_id = 99 WHERE id = ?";
				PreparedStatement insert = conn.prepareStatement(query);
				insert.clearParameters();
				insert.setInt(1,Integer.parseInt(request.getParameter("jobId")));
				insert.execute();
			} else {
				DateFormat mysqlFormat = new SimpleDateFormat("yyyy-MM-dd");
				pjc.updateJobChangeJobId("customerdate",mysqlFormat.format(new java.util.Date()));
				pjc.updateJobChangeJobId("customerid",(String)request.getSession().getAttribute("contactId"));
			}
		} catch (Exception e) {
			request.setAttribute("errorMessage","JobChangeParker Error occured " + e.getMessage());
			RequestDispatcher rd;
			rd = getServletContext().getRequestDispatcher(request.getParameter("errorPage"));
			
			try {
				rd.forward(request, response);	
			}catch(IOException ioe) {
				throw new ServletException("JobChangeParker, forward failed from an error" + ioe.getMessage() + ", the original message: " + e.getMessage());
			}
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		if (request.getParameter("changeTypeId").equals("1") || request.getParameter("changeTypeId").equals("2") || request.getParameter("changeTypeId").equals("3")){
			sendEmail(request);
		}
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this, request, response);		
	}
	//New User so send a nice message
	private void sendEmail(HttpServletRequest request){
		String vendorEmail;
		String buyerEmail;
		String vendorEmailId;
		String buyerEmailId;
		String jobId=((request.getParameter("jobId")==null)?"0":request.getParameter("jobId"));
		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			
			String sqlBuyer = "SELECT c.email 'email',c.id 'emailId' FROM jobs j, projects p, orders o, contacts c WHERE j.project_id = p.id AND p.order_id = o.id AND c.id = o.buyer_contact_id AND j.id = " + jobId;			
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
		
		} catch(SQLException sqle){
			System.err.println("");
			return;	
		} catch(Exception e){
			System.err.println(e.getMessage());
			e.printStackTrace();
			return;		
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	
		//mailling section	
	
		//mailer tool
		JavaMailer1 mail = new JavaMailer1();
	
		//JobChange email body
		JobProposedChange jpc = new JobProposedChange();
		
		
		mail.setTo(buyerEmail);
		mail.setFrom(vendorEmail);
		mail.setEmailToId(buyerEmailId);
		mail.setEmailFromId(vendorEmailId);
		mail.setJobId(jobId);
		try{
			mail.setBody(jpc.getBody(request));
		}catch(SQLException sqle){
			System.err.println("Emailer for JobChangeParker, setBody, failed: " + request.getParameter("jobId") + ", sqle: " + sqle.getMessage());	
			return;
		}

		mail.setSubject(jpc.getSubject(request));
		try{
			mail.send();
		}catch(Exception e){
			System.err.println("Emailer for JobChangeParker, send failed: " + request.getParameter("jobId") + ", e: " + e.getMessage());	
			return;
		}	
				
	}
}
