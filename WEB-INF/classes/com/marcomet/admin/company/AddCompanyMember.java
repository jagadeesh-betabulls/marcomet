/**********************************************************************
Description:	This Class will drive the process of registering a new 
				user for a specific company.

History:
	Date		Author			Description
	----		------			-----------
	10/23/01	td				created
	
**********************************************************************/

package com.marcomet.admin.company;

import com.marcomet.mail.*;
import com.marcomet.tools.*;
import com.marcomet.users.admin.*;
import com.marcomet.users.security.*;
import com.marcomet.commonprocesses.*;
import com.marcomet.mail.registration.*;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;


public class AddCompanyMember extends HttpServlet{
	
	//variables
	String errorMessage;

	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		//Register user	
		Hashtable results = new Hashtable();
		UserRegistrationTool urt = new UserRegistrationTool();
		try {
			urt.addNewCompanyMemberInformation(request, response, results);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
			
		//if an error message is return, then stop further action and throw new Exception
		if(!((String)results.get("errorMessage")).equals("")){
			request.setAttribute("errorMessage",(String)results.get("errorMessage"));
			exitWithError(request,response);
			return;	
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
			throw new ServletException("AddCompanyMember, forward failed on an error" + ioe.getMessage());
		}
	}

}