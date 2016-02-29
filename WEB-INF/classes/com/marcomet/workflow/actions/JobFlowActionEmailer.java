package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class Sends out an email and what email based on 
				the db entries.
**********************************************************************/

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Hashtable;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.mail.JavaMailer1;
import com.marcomet.workflow.emailbodies.EmailBodyInterface;
import com.marcomet.workflow.emailbodies.InterimInvoice;


public class JobFlowActionEmailer implements ActionInterface{

	//this class name for email bodies lookups
	String className ="com.marcomet.workflow.actions.JobFlowActionEmailer";
	
	protected boolean isOrder;
	protected String orderId;
	protected String jobId;
		
	public JobFlowActionEmailer() {
		
	}
	public Hashtable execute(MultipartRequest mr, HttpServletResponse res) throws Exception {
		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
		
			//parmeters that drives queries for determining who is supose to get the email	
			String actionId = mr.getParameter("nextStepActionId");	
			isOrder = (mr.getParameter("orderId") != null);        //if this is an order there isn't a specific job associated with it.
			orderId = mr.getParameter("orderId");
			jobId =  mr.getParameter("jobId");		
			
			Statement qsEmails = conn.createStatement();
		
			//determin what email bodies and to whom the emails goto.
			String sql = "SELECT email.* FROM jobflowemailclasses email, jobflowstatuschangeactions jfsca WHERE email.jfcsaid = jfsca.id AND jfsca.javaclass='"+className+"' AND jfsca.actionid = " + actionId;
	
			ResultSet rs1 = qsEmails.executeQuery(sql);
			
			if(rs1.next()){							
				JavaMailer1 mail = new JavaMailer1();
				
				do{
					//get email body builder
					EmailBodyInterface ebi = (EmailBodyInterface)Class.forName(rs1.getString("emailbodyclass")).newInstance();
					
					mail.setTo((String)who(rs1.getInt("towho")).get("email"));
					mail.setFrom((String)who(rs1.getInt("fromwho")).get("email"));
					mail.setEmailToId((String)who(rs1.getInt("towho")).get("id"));
					mail.setEmailFromId((String)who(rs1.getInt("fromwho")).get("id"));
					
					mail.setBody(ebi.getBody(mr));
					mail.setSubject(ebi.getSubject());
					mail.send();
					
				}while(rs1.next());
					
			}else {
				throw new Exception("No body found for, actionId: " + actionId);
			}	
		} catch (Exception x) {
			throw new Exception(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		return new Hashtable();		
	}
	
	public Hashtable execute(HttpServletRequest request, HttpServletResponse res) throws Exception {
		Connection conn = null; 
		try {			
			conn = DBConnect.getConnection();
			//parameters that drive queries for determining who is supposed to get the email	
			String actionId = request.getParameter("nextStepActionId");	
			isOrder = (request.getAttribute("orderId") != null);
			orderId = (String)request.getAttribute("orderId");
			jobId =  request.getParameter("jobId");		
			
			//determine what email bodies and to whom the emails goto.
			Statement qsEmails = conn.createStatement();
			String sql = "SELECT email.* FROM jobflowemailclasses email, jobflowstatuschangeactions jfsca WHERE email.jfcsaid = jfsca.id AND jfsca.javaclass='"+className+"' AND jfsca.actionid = " + actionId;
			ResultSet rs1 = qsEmails.executeQuery(sql);
			
			if(rs1.next()){							
				JavaMailer1 mail = new JavaMailer1();
				
				do{
					//get the email title to throw in the subject
					String title = "";
					String key = "";
					Statement st2 = conn.createStatement();
					StringTokenizer token = new StringTokenizer(rs1.getString("emailbodyclass"), ".");
					while (token.hasMoreTokens()) {
						key = token.nextToken();
					}
	
					String query0 = "SELECT email_subject FROM email_form_letters WHERE email_key = \"" + key + "\"";
					ResultSet rs2 = st2.executeQuery(query0);
					if (rs2.next())
						title = rs2.getString("email_subject");
					
					//get email body builder
					EmailBodyInterface ebi = (EmailBodyInterface)Class.forName(rs1.getString("emailbodyclass")).newInstance();
					mail.setJobId(jobId);
					mail.setTo((String)who(rs1.getInt("towho")).get("email"));
					mail.setFrom((String)who(rs1.getInt("fromwho")).get("email"));
					mail.setEmailToId((String)who(rs1.getInt("towho")).get("id"));
					mail.setEmailFromId((String)who(rs1.getInt("fromwho")).get("id"));
					mail.setBody(ebi.getBody(request));
					mail.setSubject(ebi.getSubject() + "  -  " + title);
					mail.send();
				}while(rs1.next());
					
			}else {
				throw new Exception("No body found for, actionId: " + actionId);
			}	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		return new Hashtable();			
	}
	
	public Hashtable execute(String actionId,String idForJob,String nameOfClass) throws Exception {
		Connection conn = null; 
		try {			
			conn = DBConnect.getConnection();
			//parameters that drive queries for determining who is supposed to get the email	
			isOrder = false;
			orderId = "0";	
			jobId=idForJob;
			//determine what email bodies and to whom the emails goto.
			Statement qsEmails = conn.createStatement();
			String sql = "SELECT email.* FROM jobflowemailclasses email, jobflowstatuschangeactions jfsca WHERE email.jfcsaid = jfsca.id AND jfsca.javaclass='"+nameOfClass+"' AND jfsca.actionid = " + actionId;
			ResultSet rs1 = qsEmails.executeQuery(sql);
			
			if(rs1.next()){							
				JavaMailer1 mail = new JavaMailer1();
				
				do{
					//get the email title to throw in the subject
					String title = "";
					String key = "";
					Statement st2 = conn.createStatement();
					StringTokenizer token = new StringTokenizer(rs1.getString("emailbodyclass"), ".");
					while (token.hasMoreTokens()) {
						key = token.nextToken();
					}
	
					String query0 = "SELECT email_subject FROM email_form_letters WHERE email_key = \"" + key + "\"";
					ResultSet rs2 = st2.executeQuery(query0);
					if (rs2.next())
						title = rs2.getString("email_subject");
					
					//get email body builder
					InterimInvoice ebi = new InterimInvoice();
					mail.setJobId(jobId);
					mail.setTo((String)who(rs1.getInt("towho")).get("email"));
					mail.setFrom((String)who(rs1.getInt("fromwho")).get("email"));
					mail.setEmailToId((String)who(rs1.getInt("towho")).get("id"));
					mail.setEmailFromId((String)who(rs1.getInt("fromwho")).get("id"));
					ebi.setJobId(jobId+"");
					mail.setBody(ebi.getBody());
					mail.setSubject(ebi.getSubject() + "  -  " + title);
					mail.send();
				}while(rs1.next());
					
			}else {
				throw new Exception("No body found for, actionId: " + actionId);
			}	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		return new Hashtable();			
	}
	
	protected void finalize() {
		
	}
	
	protected Hashtable who(int whoId) throws Exception{
		Hashtable<String, String> toWhoStr = new Hashtable<String, String>();
		String toWhoSql = ""; 
		
		if (whoId == 1) {            	//1 being customer, 2 being vendor, 3 is the site host
			if(isOrder){				//order process not a job process    
			 	toWhoSql = "SELECT c.email,c.id as toId FROM orders o, contacts c WHERE c.id = o.buyer_contact_id and o.id = " + orderId + " ORDER BY c.id DESC ";
			}else{						//job process not a order process
				toWhoSql = "SELECT c.email,c.id as toId FROM contacts c, jobs j, projects p, orders o WHERE o.id = p.order_id AND p.id = j.project_id AND c.id = o.buyer_contact_id AND j.id = " + jobId + " ORDER BY c.id DESC";
			}	
		} else if(whoId == 2){
			if(isOrder){				//order process not job process		
				toWhoSql = "SELECT c.email,c.id as toId FROM projects p, jobs j, contacts c WHERE j.vendor_contact_id = c.id AND p.id = j.project_id AND p.order_id = " + orderId + " ORDER BY c.id DESC";
			}else{						//job process not order process
				//removed this top sql, since contact id isn't always set, system not currently built to accept more than
				//one type of contact for each vendor - td 27 apr 01
				//sql = "select contacts.email from contacts, companies, vendors, jobs where contacts.contacttypeid = "+slups.getId("primary")+" and contacts.companyid = companies.id and vendors.companyid = companies.id and jobs.vendor_id = vendors.id and jobs.id = " + jobId; 
				toWhoSql = "SELECT c.email,c.id as toId FROM contacts c, jobs j WHERE j.vendor_contact_id = c.id and j.id = "  + jobId + " ORDER BY c.id DESC"; 
			}
		}else if(whoId == 3){  // if not vendor or customer then it must be the site host vendor
			if(isOrder){
				toWhoSql = "SELECT c.email,c.id as toId  FROM contacts c, orders o WHERE o.site_host_contact_id = c.id AND o.id = " + orderId + " ORDER BY c.id DESC";
			}else{
				toWhoSql = "SELECT c.email,c.id as toId  FROM contacts c, orders o, projects p, jobs j WHERE c.id = o.site_host_contact_id AND o.id = p.order_id AND p.id = j.project_id AND j.id = " + jobId + " ORDER BY c.id DESC";
			}	
		}else if(whoId == 4){
				toWhoSql = "SELECT c.email,c.id as toId  from contacts c, jobs j where  c.id = j.sales_contact_id AND j.id = " + jobId; 
		}					
		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			Statement qsEmail = conn.createStatement();	
			ResultSet rsEmail = qsEmail.executeQuery(toWhoSql);
			
			if (rsEmail.next()) {
				toWhoStr.put("email", rsEmail.getString(1)); 
				toWhoStr.put("id",rsEmail.getString(2));
				return toWhoStr;
			}else {
				throw new Exception("jobflowemail: no email address found " + toWhoSql);
			}
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
}
