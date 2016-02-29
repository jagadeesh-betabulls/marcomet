package com.marcomet.users.admin;

/**********************************************************************
Description:	This Class will drive the process of registering a new 
				user.
				****/

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


public class NewUserRegistration extends HttpServlet{
	
	//variables
	String errorMessage;
	int contactId;
	int companyId;
	
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		
		
		String step = ((request.getParameter("step")==null)?"":request.getParameter("step"));
				
		System.out.println("Step=" + step);
		
		//Register user	
		Hashtable results = new Hashtable();
		UserRegistrationTool urt = new UserRegistrationTool();
		if ( step.equals("1") )
			urt.addNewUserInformationStep1(request, response, results);
		else if ( step.equals("2") )
			try {
				urt.addNewUserInformationStep2(request, response, results);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		else
			try {
				urt.addNewUserInformation(request, response, results);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		//if an error message is return, then stop further action and throw new Exception
		if(!((String)results.get("errorMessage")).equals("")) {
			request.setAttribute("errorMessage",(String)results.get("errorMessage"));
			System.err.println("Error Msg:" + (String)results.get("errorMessage"));
			exitWithError(request,response);
			return;	
		}		
					
		//System.out.println("nur-Login");
		//Log user in
		step=((step == null || step.equals(""))?"2":"2");
		if ( step.equals("2")) {
			System.out.println("log user in");
			UserLoginTool ult = new UserLoginTool();
			ult.logUserIntoSystem(request, response, Integer.parseInt((String)results.get("contactId")));
			System.out.println("user logged in");
		}
		
		System.out.println("nur-Return");		
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this,request,response);
		
	}
	
	private void exitWithError(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		
		//set error attribute
		//request.setAttribute("errorMessage",errorMessage);	
		System.out.println("nur-exitWErr");
		
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
