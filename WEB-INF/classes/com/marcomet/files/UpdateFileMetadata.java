package com.marcomet.files;

/**********************************************************************
Description:	Edit File Metadata
**********************************************************************/

import com.marcomet.tools.*;
import com.marcomet.jdbc.*;
import com.marcomet.commonprocesses.*;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;



public class UpdateFileMetadata extends HttpServlet{
	
	
	//variables
	String errorMessage;
	int fileId;
	public UpdateFileMetadata(){
	
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		try{
			Update(request); 
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
			throw new ServletException("UpdateFileMetadata, forward failed on an error" + ioe.getMessage());
		}
	}

	private void Update(HttpServletRequest request)
	throws SQLException, Exception{
		
		Connection conn = null;
		StringTool str = new StringTool();
				
		conn = DBConnect.getConnection();
	
		
		try{
			String sql= "update file_metadata set description=? where id=?";
			String fBsql= "update file_bridge set related_id=?,role_id=?,status_id=? where id=?";			
			PreparedStatement updateFile = conn.prepareStatement(sql);
			PreparedStatement updateFileBridge = conn.prepareStatement(fBsql);
			updateFile.setString(1,request.getParameter("description"));	
			updateFile.setInt(2,Integer.parseInt(request.getParameter("fileId")));		
			updateFile.execute();
			updateFileBridge.setInt(1,Integer.parseInt(request.getParameter("relatedId")));
			updateFileBridge.setInt(2,Integer.parseInt(request.getParameter("roleId")));
			updateFileBridge.setInt(3,Integer.parseInt(request.getParameter("statusId")));
			updateFileBridge.setInt(4,Integer.parseInt(request.getParameter("Id")));											
			updateFileBridge.execute();
			
			updateFile.close();
			updateFileBridge.close();
		}catch(SQLException e){
			throw new ServletException("UpdateFileData, " + e.getMessage());
		} finally {
			try { conn.close(); } catch (Exception e) {}
		}
	}
}

