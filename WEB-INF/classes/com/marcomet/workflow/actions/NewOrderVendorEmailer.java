/**********************************************************************
Description:	This Class Sends out a email to vendors grouping their jobs
				together
				
Notes:			This class is specificly designed for a task, so fewer checks,
				and get's down to busines.

				These email addresss queries relay heavily on the rule that there
				is one contact per company.  This was told so early in sbp's developement.
				If this changes, there are 'types' of contacts for each company, look for that.
				
				
History:
	Date		Author			Description
	----		------			-----------
	8/6/01		Tom dietrich	created
	
**********************************************************************/

package com.marcomet.workflow.actions;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.mail.JavaMailer;
import com.marcomet.mail.JavaMailer1;
import com.marcomet.workflow.emailbodies.NewOrderVendor;


public class NewOrderVendorEmailer extends JobFlowActionEmailer implements ActionInterface{
	
	//boolean isOrder;
	//String orderId;
	String jobId;
		
	public NewOrderVendorEmailer() {
	}
	
	public Hashtable execute(MultipartRequest mr, HttpServletResponse res) throws Exception {

		return new Hashtable();		
	}
	
	public Hashtable execute(HttpServletRequest request, HttpServletResponse res) throws Exception {

				
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			//parmeters that drives queries for determining who is supose to get the email	
			String actionId = request.getParameter("nextStepActionId");	
			isOrder = true;
			orderId = (String)request.getAttribute("orderId");
			jobId =  request.getParameter("jobId");		
			//determin what email bodies and to whom the emails goto.
			Statement qsVendorEmails = conn.createStatement();
			String sql = "SELECT DISTINCT c.email 'email', c.id 'id',j.id 'jobId' FROM orders o, projects p, jobs j, contacts c WHERE o.id = p.order_id AND p.id = j.project_id AND j.vendor_contact_id = c.id AND o.id = " + (String)request.getAttribute("orderId");
			ResultSet rs1 = qsVendorEmails.executeQuery(sql);
		
			if(rs1.next()){							
				JavaMailer mail = new JavaMailer();
			
				do{
					//get email body builder
					NewOrderVendor nov = new NewOrderVendor();
					mail.setJobId(rs1.getString("jobId"));
					mail.setTo(rs1.getString("email"));
					mail.setFrom((String)who(3).get("email"));
					mail.setEmailToId((String)who(3).get("id"));				
					mail.setBody(nov.getBody(request,rs1.getString("id")));
					mail.setSubject(nov.getSubject());
					mail.send();
				
				}while(rs1.next());
				
			}else {
				throw new Exception("newordervendoremailer: this query failed: SELECT DISTINCT c.email FROM orders o, projects p, jobs j, contacts c WHERE o.id = p.order_id AND p.id = j.project_id AND j.vendor_contact_id = c.id AND o.id = " + (String)request.getAttribute("orderId"));
			}	
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return new Hashtable();			
	}
	
}
