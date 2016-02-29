package com.marcomet.products;

/**********************************************************************
Description:	Enter and Edit Product Line information

**********************************************************************/

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessProductSpecs;
import com.marcomet.tools.ReturnPageContentServlet;



public class UpdateProductSpecs extends HttpServlet{
	
	//variables
	String errorMessage;
	int prodLineId;
	
	public UpdateProductSpecs(){
	
	}
		
	

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		try{
			UpdateProdSpecs(request); 
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
			throw new ServletException("UpdateProductSpecs, forward failed on an error" + ioe.getMessage());
		}
	}

	private void UpdateProdSpecs(HttpServletRequest request)
	throws ServletException, Exception{
		ProcessProductSpecs pPS = new ProcessProductSpecs();
		pPS.setProdLineId(request.getParameter("prodLineId"));
		//String value="";
		String specvalue="";
		try{
			for (int x=0;x<=50;x++){
				specvalue=((request.getParameter("productSpecValue"+x).equals("0"))?request.getParameter("productSpecValueEntry"+x):request.getParameter("productSpecValue"+x));		
				if (!specvalue.equals("")){
					if ((request.getParameter("specvalueid"+x).equals("0"))){
						pPS.insert(specvalue);
					}else{
						pPS.update(Integer.parseInt(request.getParameter("specvalueid"+x)),specvalue);
					}
				}
			}

		}catch(ServletException e){
			throw new ServletException("UpdateProductLine, " + e.getMessage());
		}	
	}
	
}

