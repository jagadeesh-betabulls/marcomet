/**********************************************************************
Description:	Reset the user's password

History:
	Date		Author			Description
	----		------			-----------
	10/2/01		ekc				created
	
**********************************************************************/

package com.marcomet.users.admin;

import com.marcomet.mail.*;
import com.marcomet.tools.*;
import com.marcomet.users.security.*;
import com.marcomet.commonprocesses.*;
import com.marcomet.mail.registration.*;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;


public class UpdatePassword extends HttpServlet{
	
	//variables
	String errorMessage;
	int contactId;
	int password;
	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		try{
			updatePass(request,response); 
		}catch(Exception e){
			errorMessage ="There was an error: " + e.getMessage();
			exitWithError(request,response);			
		}	
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this,request,response);				
	}
	
	public void updatePass(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{		
						
		try{
			ProcessLogin pl = new ProcessLogin ();
			pl.setContactId(Integer.parseInt((String)request.getParameter("contactId")));
			pl.setPassword(request.getParameter("userpw"));	
			pl.updatePW();
		}catch(Exception e){
			errorMessage ="There was an error: " + e.getMessage();
			exitWithError(request,response);			
		}			
		
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
			throw new ServletException("NewUserRegistration, forward failed on an error" + ioe.getMessage());
		}
	}

}
