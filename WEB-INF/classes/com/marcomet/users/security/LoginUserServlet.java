/**********************************************************************
Description:	This class validates the user submitted information and 
				sets the appropriate information in session.
**********************************************************************/	

package com.marcomet.users.security;
	
import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.tools.ReturnPageContentServlet;
	
	
public class LoginUserServlet extends HttpServlet{	

	public void doGet(HttpServletRequest request, HttpServletResponse response)
	throws ServletException,IOException{
	
		System.out.println("loginuserservlet session = "+request.getSession().getAttribute("currentSession"));
		//check to see is the session has timed out
		if(request.getSession().getAttribute("currentSession")==null){
			RequestDispatcher rd = getServletContext().getRequestDispatcher("/contents/SessionTimedOutPage.jsp");
			rd.forward(request, response);	
			return;
		} 
	
		UserLoginTool ult = new UserLoginTool();
		//int contactId = Integer.parseInt(request.getParameter("contactId"));
		String encryptedId = getEncryptedId(request);				
		
		if(encryptedId.equals("") || !(ult.logUserIntoSystem(request, response, encryptedId))){
			ult.logUserOutOfSystem(request, response);
			request.setAttribute("errorMessage","User Name and Password do not match");				
		}
			
		//send response back to calling page	
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this, request, response);
			
	}
	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{			
		
		UserLoginTool ult = new UserLoginTool();
		if(!ult.validateNameAndPasswordAndLogin(request,response)){
			ult.logUserOutOfSystem(request, response);
			request.setAttribute("errorMessage","User Name and Password do not match");				
		}
		
		//send response back to calling page	
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this, request, response);
	}

	private String getEncryptedId(HttpServletRequest request){
		//check to see if an autologin parameter was passed in, and if so whether the site supports that login
		Cookie[] cookies = request.getCookies();
			
		//if no cookies are found, you don't get an array of zero length but a null object
		if(cookies != null){
			//loop through the cookies for the proper one for our site
			for(int i = 0; i < cookies.length; i++){
				if(cookies[i].getName().equals("qwerty")){
					return cookies[i].getValue();					
				}
			}
		}
			 if (!(request.getSession().getAttribute("cmyp")==null) && request.getSession().getAttribute("allowGuestLogin").toString().equals("1") && request.getSession().getAttribute("guestEID").toString().equals(request.getSession().getAttribute("cmyp").toString())){
	request.getSession().setAttribute("m","y");	
	return request.getSession().getAttribute("cmyp").toString();
			}else{
				return "";	
			}	
} 	
	
}
