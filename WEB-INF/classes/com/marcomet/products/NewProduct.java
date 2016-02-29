package com.marcomet.products;

/**********************************************************************
Description:	Enter and Edit Product Line information
**********************************************************************/

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessProduct;
import com.marcomet.tools.ReturnPageContentServlet;
import com.marcomet.tools.SimpleLookups;


public class NewProduct extends HttpServlet{
	
	//variables
	String errorMessage;
	int prodLineId;
	ProcessProduct pPl = new ProcessProduct();		
	public NewProduct(){
	
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
	
		try{
			insertProd(request); 
		}catch(Exception e){
			errorMessage ="There was an error: " + e.getMessage();
			exitWithError(request,response);			
		}	
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		request.setAttribute("productId",pPl.getId()+"");
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
			throw new ServletException("NewProduct, forward failed on an error" + ioe.getMessage());
		}
	}


	private void insertProd(HttpServletRequest request)
	throws ServletException, Exception{
		SimpleLookups slups = new SimpleLookups();

		try{
			pPl.setProdName(request.getParameter("prodName"));
		 	pPl.setProdLineId(request.getParameter("prodLineId"));
			pPl.setProdCompanyId(request.getParameter("prodCompanyId"));
			pPl.setStatusId(request.getParameter("statusId"));			
			pPl.setProdFeatures(request.getParameter("prodFeatures"));
			pPl.setDescription(request.getParameter("description"));
			pPl.setSummary(request.getParameter("summary"));				
			pPl.setProdDemoURL(request.getParameter("productDemoURL"));
			pPl.setProdPrintURL(request.getParameter("productPrintURL"));			
			pPl.setProdSpecDiagramPicURL(request.getParameter("productSpecDiagramPicURL"));
			pPl.setProdFullPicURL(request.getParameter("productFullPicURL"));									
			pPl.setProdSmallPicURL(request.getParameter("productSmallPicURL"));		
			pPl.setSendSample(request.getParameter("sendSample"));		
			pPl.setSendLiterature(request.getParameter("sendLiterature"));	
			pPl.setApplication(request.getParameter("application"));
			pPl.setTemplate(request.getParameter("template"));
			pPl.setShowDrivers(request.getParameter("showDrivers"));
			pPl.setShowManuals(request.getParameter("showManuals"));
			pPl.setShowSupportRequest(request.getParameter("showSupportRequest"));
			pPl.setShowSampleRequest(request.getParameter("showSampleRequest"));
			pPl.insert();
				

		}catch(SQLException sqle){
			throw new ServletException("newproduct, insertProd sqle: " + sqle.getMessage());
		}
		
	}
}

