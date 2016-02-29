package com.marcomet.sbpprocesses;

/**********************************************************************
Description:	This class will move a job through the workflow.
**********************************************************************/

import java.io.*;
import java.sql.*;
import java.awt.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;
import com.marcomet.files.*;
import com.marcomet.workflow.*;
import com.marcomet.environment.*;
import com.marcomet.commonprocesses.*;
import com.marcomet.workflow.actions.*;

public class ProcessJobSubmit extends HttpServlet{

//	public void init(ServletConfig cfg)
//	throws ServletException{
//		super.init(cfg);	
//	}
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException,IOException{
	
		//check to see is the session has timed out
		if(request.getSession().getAttribute("currentSession")==null){
			RequestDispatcher rd = getServletContext().getRequestDispatcher("/contents/SessionTimedOutPage.jsp");
			rd.forward(request, response);	
			return;
		}        	
		 	
		
		String contentType = request.getHeader("content-type");
		StringTokenizer st = new StringTokenizer(contentType, ";");
		contentType = (String)st.nextElement();

		JobFlowActionEngine jfae = new JobFlowActionEngine();

		if (contentType.equals("multipart/form-data")) {
			try {
			
				HttpSession session = request.getSession();
				int companyid = Integer.parseInt((String)session.getAttribute("companyId"));
				int userid = Integer.parseInt((String)session.getAttribute("contactId"));
				String domainName = ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName();
				//String homePage = (String)session.getAttribute("homePage");
				
				MultipartRequest mr = null;
				FileManipulator fm = new FileManipulator();
				try {
					mr = fm.uploadFile(request, response);
				} catch (Exception ex) {
					if (ex.getMessage().equals("FileManipulator uploadFile exception: exists")) {
						request.setAttribute("uploaderror", "An error occurred.  It appears that the file you are attempting to upload already exists, please choose to rename or replace the file and try again.");
						RequestDispatcher rd = getServletConfig().getServletContext().getRequestDispatcher("/contents/DuplicateFile.jsp");
						rd.forward(request, response);
					}else{
						throw new Exception(ex.getMessage());      
					}
				}

				mr.setParameter("companyId", companyid+"");
				mr.setParameter("userId", userid+"");
				
				//these are vendor variables set by ed for links in the emails
				mr.setParameter("domainName",domainName);
				mr.setParameter("homePage","index.jsp");

				try {
					jfae.execute(mr, response);
				}catch(Exception e) {
					throw new ServletException("ProcessJobSubmit failed: " + e.getMessage());
				}
				
				String location = mr.getParameter("redirect");
				RequestDispatcher rd = getServletContext().getRequestDispatcher(location);
				rd.forward(request, response);
				
			} catch(Exception ex) {
				throw new ServletException("Error handling ProcessJobSubmit " + ex.getMessage());	
			}

		} else {
			try {
			
				jfae.execute(request,response);

			}catch(ActionException ae) {
			
				//an ae is thrown by an action to break out and goto an error page
				RequestDispatcher rd;
				rd = getServletContext().getRequestDispatcher(request.getParameter("errorPage"));
				try {
					rd.forward(request, response);	
				}catch(IOException ioe) {
					throw new ServletException("ProcessJobSubmit, forward failed from an error" + ioe.getMessage());
				}	
			}catch(Exception e) {
				throw new ServletException("ProcessJobSubmit failed: " + e.getMessage());
			}

			ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
			rpcs.printNextPage(this,request,response);
		}	
	}
}
