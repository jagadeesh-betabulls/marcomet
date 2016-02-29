package com.marcomet.files;

/**********************************************************************
Description:	Submit email info information
**********************************************************************/

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.jdbc.DBConnect;
import com.marcomet.mail.JavaMailer1;
import com.marcomet.tools.ReturnPageContentServlet;



public class ProcessEmail extends HttpServlet{
	
	Connection conn;
	//variables
	String errorMessage;
	public ProcessEmail(){
	
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		try{
			SendMail(request,response); 
		}catch(Exception e){
			errorMessage ="There was an error: " + e.getMessage();
			exitWithError(request,response);			
		}
	ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
	rpcs.printNextPage(this,request,response);						
	}
	private void exitWithError(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		//set error attribute
		request.setAttribute("errorMessage",errorMessage);	
		
		//goto an error page
		RequestDispatcher rd;
		rd = getServletContext().getRequestDispatcher(request.getParameter("errorPage"));
		try {
			rd.forward(request, response);	
		}catch(IOException ioe) {
			throw new ServletException("ProcessEmail, forward failed on an error" + ioe.getMessage());
		}
	}

	private void SendMail(HttpServletRequest request, HttpServletResponse response)
	throws SQLException, Exception{
//com.marcomet.tools.MessageLogger.logMessage("in sm");	
		if (conn == null) {			
			conn = DBConnect.getConnection();
		}	
		try {
			String body=((request.getParameter("emailTypeText")==null)?request.getParameter("emailTypeText"):"Email")+"<hr>";	
			if (request.getParameter("productId")!=null && !request.getParameter("productId").equals("")){
				ResultSet rs;
				PreparedStatement selectProduct;
				String selectProductSQL = "select * from products where id = ?";	
				//get Product info
				selectProduct = conn.prepareStatement(selectProductSQL);
				selectProduct.clearParameters();
				selectProduct.setString(1,request.getParameter("productId"));		
				rs = selectProduct.executeQuery();
				if (rs.next())	{
					body="Re Product: "+rs.getString("prod_name")+"; "+"<br>";

				}
				selectProduct.close();
			}
			body=((request.getParameter("sendLiterature")==null)?body:body+"<br>Action: "+ request.getParameter("sendLiterature")+"<br>");
			body=((request.getParameter("sendSample")==null)?body:body+"<br>Action: "+ request.getParameter("sendSample")+"<br>");
			body=((request.getParameter("callUser")==null)?body:body+"<br>Action: "+ request.getParameter("callUser")+"<br>");			
			body=((request.getParameter("application")==null)?body:body+"<br>User Application: "+ request.getParameter("application")+"<br>");			
			body+="<br><br>"+request.getParameter("body");
			JavaMailer1 sm = new JavaMailer1();
			sm.setTo(request.getParameter("to"));
			sm.setFrom(request.getParameter("from"));
			sm.setSubject(request.getParameter("subject"));
			sm.setBody("<pre>"+body+"</pre>");                       //***** for quick fixing message not ready for html formating
			sm.setSiteHostId(request.getParameter("siteHostId"));
			sm.setEmailToId( ((request.getParameter("emailToId")==null)?"0":request.getParameter("emailToId")) );
			sm.setEmailFromId( ((request.getParameter("emailFromId")==null)?"0":request.getParameter("emailFromId")) );							
			sm.setEmailType(request.getParameter("emailType"));	
			sm.setResponseToEmailId(request.getParameter("responseToEmailId"));									
			sm.send();
			if (request.getParameter("emailType")!=null && (request.getParameter("emailType").equals("4") || request.getParameter("emailType").equals("3"))){				
				String insertRequestSQL = "INSERT INTO request_for_info (email_id,send_info,followup_call,send_sample,application) values (?,?,?,?,?)";	
				PreparedStatement insertRequest = conn.prepareStatement(insertRequestSQL);
				insertRequest.setInt(1,sm.getEmailId());
				insertRequest.setString(2,((request.getParameter("sendLiterature")==null)?"":request.getParameter("sendLiterature")));
				insertRequest.setString(3,((request.getParameter("callUser")==null)?"":request.getParameter("callUser")));
				insertRequest.setString(4,((request.getParameter("sendSample")==null)?"":request.getParameter("sendSample")));
				insertRequest.setString(5,((request.getParameter("application")==null)?"":request.getParameter("application")));
				insertRequest.execute();	
				insertRequest.close();
			}
			
		}catch(Exception e){
			errorMessage ="There was an error in update: " + e.getMessage();
			exitWithError(request,response);

		}finally{
			try {
				conn.close();
			}catch(Exception e) {
			}finally {				
				conn = null;
			}		
		}	
	}
}

