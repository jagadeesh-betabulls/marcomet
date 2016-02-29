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

import com.marcomet.commonprocesses.ProcessPR;
import com.marcomet.tools.ReturnPageContentServlet;


public class NewPR extends HttpServlet{
	
	//variables
	String errorMessage;
	int prodLineId;
	ProcessPR pPl = new ProcessPR();		
	public NewPR(){
	
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
	
		try{
			insertPR(request); 
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
			throw new ServletException("NewPR, forward failed on an error" + ioe.getMessage());
		}
	}


	private void insertPR(HttpServletRequest request)
	throws ServletException, Exception{
		try{
			pPl.setPrProdId(request.getParameter("prProdId"));
			pPl.setPrReleaseDate(request.getParameter("prReleaseDate"));			
		 	pPl.setPrProdLineId(request.getParameter("prProdLineId"));
			pPl.setPrCompanyId(request.getParameter("prCompanyId"));
			pPl.setPrStatusId(request.getParameter("prStatusId"));			
			pPl.setPrPublication(request.getParameter("prPublication"));
			pPl.setSummary(request.getParameter("summary"));	
			pPl.setPrTitle(request.getParameter("prTitle"));							
			pPl.setPrDemoURL(request.getParameter("prDemoURL"));
			pPl.setPrPrintURL(request.getParameter("prPrintURL"));			
			pPl.setPrFullPicURL(request.getParameter("prFullPicURL"));									
			pPl.setPrSmallPicURL(request.getParameter("prSmallPicURL"));
			pPl.setPrType(request.getParameter("prType"));									
			pPl.insert();

		}catch(SQLException sqle){
			throw new ServletException("newproduct, insertProd sqle: " + sqle.getMessage());
		}
		
	}
}

