package com.marcomet.products;

/**********************************************************************
Description:	Enter and Edit Press Release Information
**********************************************************************/

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessPage;
import com.marcomet.tools.ReturnPageContentServlet;


public class NewPage extends HttpServlet{
	
	//variables
	String errorMessage;
	int prodLineId;
	ProcessPage pPl = new ProcessPage();		
	public NewPage(){
	
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
	
		try{
			insertPage(request); 
		}catch(Exception e){
			errorMessage ="There was an error: " + e.getMessage();
			exitWithError(request,response);			
		}	
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		request.setAttribute("pageId",pPl.getId()+"");
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
			throw new ServletException("NewPage, forward failed on an error" + ioe.getMessage());
		}
	}


	private void insertPage(HttpServletRequest request)
	throws ServletException, Exception{
		try{
			pPl.setCompanyId(request.getParameter("companyId"));
			pPl.setStatusId(request.getParameter("statusId"));
			pPl.setContactId(request.getParameter("contactId"));
			pPl.setSubmitterId(request.getParameter("submitterId"));
			pPl.setActionOnExpireId(request.getParameter("actionOnExpireId"));
			pPl.setPageTypeId(request.getParameter("pageTypeId"));
			pPl.setPrintFileURL(request.getParameter("printFileURL"));
			pPl.setHtml(request.getParameter("html"));
			pPl.setSecurityUsername(request.getParameter("securityUsername"));
			pPl.setSecurityPassword(request.getParameter("securityPassword"));
			pPl.setSecurityBuriedPage(request.getParameter("securityBuriedPage"));
			pPl.setMiscKeywords(request.getParameter("miscKeywords"));
			pPl.setDateCreated(request.getParameter("dateCreated"));
			pPl.setDateExpires(request.getParameter("dateExpires"));
			pPl.setDateToPost(request.getParameter("dateToPost"));
			pPl.setTitle(request.getParameter("title"));
			pPl.setIsPageOutsideSite(request.getParameter("isPageOutsideSite"));
			pPl.setRedirectURL(request.getParameter("redirectURL"));
			pPl.setHelpPublish(request.getParameter("helpPublish"));
			pPl.setOnlyShowHtml(request.getParameter("onlyShowHtml"));
			pPl.setSmallPicURL(request.getParameter("smallPicURL"));
			pPl.setFullPicURL(request.getParameter("fullPicURL"));
			pPl.setDemoURL(request.getParameter("demoURL"));
			pPl.setPrintFileURL(request.getParameter("printFileURL"));
			pPl.setBody(request.getParameter("body"));
			pPl.setSummary(request.getParameter("summary"));			
			pPl.insert();

		}catch(SQLException sqle){
			throw new ServletException("newpage, insertPage sqle: " + sqle.getMessage());
		}
		
	}
}

