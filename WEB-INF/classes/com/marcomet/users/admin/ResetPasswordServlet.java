package com.marcomet.users.admin;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Random;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.ReturnPageContentServlet;

public class ResetPasswordServlet extends HttpServlet {

/**
 * ResetPasswordServlet constructor comment.
 */
 
public ResetPasswordServlet() {
	super();
} 
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException{

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String sql="";
			String foundFlag="";
			String contactName="";
			String userName=((request.getParameter("userName")==null)?"":request.getParameter("userName"));
			String contactId=((request.getParameter("contactId")==null)?"":request.getParameter("contactId"));
			
			if (!contactId.equals("")){
				sql="Select * from contacts c,logins l where c.id="+contactId+" AND c.id=l.contact_id";
			}else{
				if (!userName.equals("")){
					sql="Select * from contacts c,logins l where user_name=\""+userName+"\" AND email=\""+request.getParameter("emailAddress")+"\" AND c.id=l.contact_id";
				}else{
					sql="Select * from contacts c,logins l where l.contact_id=c.id and email=\""+request.getParameter("emailAddress")+"\"";
				}
			}
			Statement qs=conn.createStatement();
			ResultSet rsContact=qs.executeQuery(sql);
			if (rsContact.next()){
				contactName=rsContact.getString("firstname")+" "+rsContact.getString("lastname");
				contactId=rsContact.getString("id");
				foundFlag="true";
			}else{
				foundFlag="false";	
			}
			if (foundFlag.equals("false")){
			  String errorMessage="<div class=\"maintitle\">***There was a problem resetting your password. Please return to the previous page and try again.***</div>";
			}else if (foundFlag.equals("true")){
				String rnd = ""+(new Random().nextInt(999999));
				String newPass=""+("000000"+rnd).substring(rnd.length());
				sql="update logins set user_password=md5(\'"+newPass+"\') where contact_id="+rsContact.getString("id");
				Statement qs1=conn.createStatement();
				qs1.execute(sql);
				
				String body="<font face=\"Arial, Helvetica, sans-serif\" size=\"4\"><b>Password Reset </b></font> <hr size=1>";
				body+="At your request, your password has been reset to the following:<br><p> <b>Login Name:</b> "+rsContact.getString("l.user_name")+"<br><b>Password: </b>"+newPass+"</p>";
				
				sql="select ct.id,ct.email, sh.site_name from default_company_contacts d,contacts ct,site_hosts sh where sh.company_id=d.company_id and ct.id=d.support_contact_id and d.company_id="+request.getParameter("siteHostCompanyId");
				qs1=conn.createStatement();
				ResultSet rsDefaults=qs1.executeQuery(sql);
				String emailFromId=request.getParameter("siteHostCompanyId");
				String emailFrom="lostlogin@marcomet.com";
				if (rsDefaults.next()){
					emailFromId=rsDefaults.getString("ct.id");
					emailFrom=rsDefaults.getString("ct.email");
                                body+="<p>You may now log into our system. Once logged in you may go to your 'Account Info' page and change your password if you wish. Thank you for visiting <a href=\"http://"+request.getParameter("domainName")+"\">"+rsDefaults.getString("sh.site_name")+"</a></p>";
				}
				String email_from="";
				sql="insert into email_sent_histories (email_to,email_from,subject,body,sent,site_host_id,email_type,email_to_id,email_from_id,response_to_email_id)";
				sql+="values (?,?,?,?,?,?,?,?,?,?)";
				PreparedStatement sEmail = conn.prepareStatement(sql);	
				int x=1;
				
				sEmail.setString(x++,rsContact.getString("email"));
				sEmail.setString(x++,emailFrom);
				sEmail.setString(x++,"Response to Support Request");
				sEmail.setString(x++,body);
				sEmail.setInt(x++,0);
				sEmail.setString(x++,request.getParameter("siteHostId"));
				sEmail.setInt(x++,6);
				sEmail.setString(x++,rsContact.getString("id"));
				sEmail.setString(x++,emailFromId);
				sEmail.setInt(x++,0);
				sEmail.execute();
				sEmail=null;	
				
			}
			ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
			rpcs.printNextPage(this,request,response);							

		} catch(SQLException sqle) {
			throw new ServletException("SQL Error: " + sqle.getMessage());
		} catch (Exception x) {
			throw new ServletException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	}
}
