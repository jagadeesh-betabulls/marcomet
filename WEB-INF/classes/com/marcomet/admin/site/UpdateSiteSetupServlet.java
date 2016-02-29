/**********************************************************************
Description:	This class will update site setup information
**********************************************************************/

package com.marcomet.admin.site;


import com.marcomet.tools.*;
import com.marcomet.environment.*;
import com.marcomet.commonprocesses.*;
import java.io.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

public class UpdateSiteSetupServlet extends HttpServlet{

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		System.out.println("here we go");
		try{
			int siteHostId = Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId());
			ProcessSiteHost psh = new ProcessSiteHost();
			System.out.println("siteHostId: " + siteHostId);
			
			psh.updateValue(siteHostId, "outer_frame_set_height", Integer.parseInt(request.getParameter("outerFrameSetHeight")));
			psh.updateValue(siteHostId, "inner_frame_set_height", Integer.parseInt(request.getParameter("innerFrameSetHeight")));
			
		}catch(Exception e){
			exitWithError(request,response, e.getMessage());
			return;
		}	
		
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this,request,response);
	
	}
	
	private void exitWithError(HttpServletRequest request, HttpServletResponse response, String errorMessage)
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