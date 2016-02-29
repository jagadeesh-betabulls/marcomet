/**********************************************************************
Description:	Enter and Edit Product Line information
**********************************************************************/
package com.marcomet.products;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessProductLine;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.ReturnPageContentServlet;
import com.marcomet.tools.StringTool;



public class UpdatePR extends HttpServlet{
	
	//variables
	String errorMessage;
	int PrId;
	public UpdatePR(){
	
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		try{
			updatePR(request); 
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
			throw new ServletException("UpdatePR, forward failed on an error" + ioe.getMessage());
		}
	}

	private void updatePR(HttpServletRequest request)
	throws SQLException, Exception{
		StringTool str = new StringTool();
		ProcessProductLine pPl = new ProcessProductLine();
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String sql= "update press_releases set prod_line_id=?,product_id=?,company_id=?,";
			sql+="publication=?,title=?,summary=?,body=?,release_date=?,status_id=?,";
			sql+="small_picurl=?,full_picurl=?,print_file_url=?,demo_url=?,pr_type=? where (id=?)";

			PreparedStatement updatePR = conn.prepareStatement(sql);
			updatePR.setInt(1,Integer.parseInt(request.getParameter("prProdLineId")));	
			updatePR.setInt(2,Integer.parseInt(request.getParameter("prProdId")));
			updatePR.setInt(3,Integer.parseInt(request.getParameter("prCompanyId")));
			updatePR.setString(4,request.getParameter("prPublication"));
			updatePR.setString(5,request.getParameter("prTitle"));
			updatePR.setString(6,request.getParameter("summary"));
			updatePR.setString(7,request.getParameter("body"));		
			String tempDate=request.getParameter("prReleaseDate");
			try{
				tempDate = str.mysqlFormatDate(request.getParameter("prReleaseDate"));			
			}catch(Exception e){
			}			
			updatePR.setString(8,tempDate);	
			updatePR.setInt(9,Integer.parseInt(request.getParameter("prStatusId")));	
			updatePR.setString(10,request.getParameter("prSmallPicURL"));	
			updatePR.setString(11,request.getParameter("prFullPicURL"));	
			updatePR.setString(12,request.getParameter("prPrintURL"));	
			updatePR.setString(13,request.getParameter("prDemoURL"));
			updatePR.setInt(14,Integer.parseInt(request.getParameter("prType")));					
			updatePR.setInt(15,Integer.parseInt(request.getParameter("prId")));													
										
			updatePR.execute();
		}catch(SQLException e){
			throw new ServletException("UpdatePR, " + e.getMessage());		
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
}

