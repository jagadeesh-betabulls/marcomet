package com.marcomet.users.admin;

/**********************************************************************
Description:	This Class will drive the process of updateing a registered
				user.
	
**********************************************************************/

import java.io.IOException;
import java.util.Hashtable;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.tools.ReturnPageContentServlet;


public class UpdateUserRegistration extends HttpServlet{
	
	//variables
	String errorMessage;
	
	public UpdateUserRegistration(){
	}
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		UserRegistrationTool urt = new UserRegistrationTool();
		Hashtable results = new Hashtable();
		
		urt.updateUserInformation(request, results);				
		
		request.setAttribute("returnMessage", (String)results.get("errorMessage"));
		
		//Log user in
		request.getSession().setAttribute("UserFullName",request.getParameter("firstName")+" " + request.getParameter("lastName"));
		request.getSession().setAttribute("email",request.getParameter("email"));
		
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
			throw new ServletException("NewUserRegistration, forward failed on an error" + ioe.getMessage());
		}
	}
	
}
