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

import com.marcomet.commonprocesses.ProcessProductLine;
import com.marcomet.tools.ReturnPageContentServlet;
import com.marcomet.tools.SimpleLookups;


public class NewProductLine extends HttpServlet{
	
	//variables
	String errorMessage;
	int prodLineId;
	public NewProductLine(){
	
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		try{
			insertProdLine(request); 
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
			throw new ServletException("NewProductLine, forward failed on an error" + ioe.getMessage());
		}
	}


	private void insertProdLine(HttpServletRequest request)
	throws ServletException, Exception{
		ProcessProductLine pPl = new ProcessProductLine();
		SimpleLookups slups = new SimpleLookups();

		try{
			pPl.setProdLineName(request.getParameter("prodLineName"));
		 	pPl.setProdLineParentId(request.getParameter("prodLineParentId"));
		 	String tempstr=pPl.getTopId(request.getParameter("prodLineParentId"));
		 	int tempTop=( (tempstr==null || tempstr.equals(""))?0:((tempstr.equals("0")&&!request.getParameter("prodLineParentId").equals("0"))?Integer.parseInt(request.getParameter("prodLineParentId")):Integer.parseInt(tempstr)) );			
			pPl.setProdLineTopParentId(tempTop);		
			pPl.setProdLineCompanyId(request.getParameter("prodLineCompanyId"));
			pPl.setProdLineDivisionId(0);
			pPl.setProdManagerId(request.getParameter("prodManagerId"));
			pPl.setStatusId(request.getParameter("statusId"));			
			pPl.setDescription(request.getParameter("description"));
			pPl.setSequence(request.getParameter("sequence"));	
			pPl.setHeader(request.getParameter("header"));	
			pPl.setFooter(request.getParameter("footer"));
			pPl.setHomepageHtml(request.getParameter("homepageHtml"));
			pPl.setTopLevelFlag(request.getParameter("topLevelFlag"));	
			pPl.setSmallPicURL(request.getParameter("smallPicUrl"));	
			pPl.setFullPicURL(request.getParameter("fullPicUrl"));																					
			pPl.setProdLineMainFeatures("");
			pPl.setProdLineMainBenefits("");
			pPl.setProdLineUSP("");			
			pPl.insert();
//		 	pPl.update(3, "prod_line_name", pPl.getProdLineName()); 

		}catch(SQLException sqle){
			throw new SQLException("newproductline, insertProdLine sqle: " + sqle.getMessage());
		}
		
	}
}

