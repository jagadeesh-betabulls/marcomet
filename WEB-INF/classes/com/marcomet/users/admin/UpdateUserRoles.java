
/**********************************************************************
Description:	Update user role information

**********************************************************************/

package com.marcomet.users.admin;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessRole;
import com.marcomet.tools.ReturnPageContentServlet;



public class UpdateUserRoles extends HttpServlet{
	//variables
	
	String errorMessage;
	int siteHostId;
	int contactId;

	public UpdateUserRoles(){
	
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		try{
			UpdateRoles(request); 
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
			throw new ServletException("UpdateUserRoles, forward failed on an error" + ioe.getMessage());
		}
	}

	private void UpdateRoles(HttpServletRequest request)
	throws SQLException, Exception{
			ProcessRole pr = new ProcessRole ();
			
			Connection conn = null;
			//Statement qs = null;
			try{				
	//			Statement qs = conn.createStatement();
				//cycle through the roles, check to see if the role is checked. 
				//If so, check to see if it exists for that user. If not,create it. 
				//If unchecked, check to see if it exists. If it does, delete it.
				PreparedStatement selectRoles = conn.prepareStatement("Select * from site_host_roles_bridge br,lu_contact_roles lu  left join contact_roles cr on cr.contact_role_id=lu.id and  cr.contact_id=? where lu.id=br.role_id and br.site_host_id=?");
				selectRoles.setInt(1,Integer.parseInt(request.getParameter("contactId")));
				selectRoles.setInt(2,Integer.parseInt(request.getParameter("siteHostId")));				
				ResultSet roles = selectRoles.executeQuery(); ;
				while (roles.next()){
					if (request.getParameter("role_"+roles.getString("lu.id"))==null || request.getParameter("role_"+roles.getString("lu.id")).equals("") ){
						if (roles.getString("cr.id")!=null && !roles.getString("cr.id").equals("")){
							pr.delete(Integer.parseInt(roles.getString("cr.id")));
						}
					}else{
						if (roles.getString("cr.id")==null || roles.getString("cr.id").equals("")){
							pr.setContactId(request.getParameter("contactId"));
							pr.setRoleId(roles.getString("lu.id"));
							pr.setSiteHostId(request.getParameter("siteHostId"));	
							pr.insert();
						}					
					}
				}
			}catch(SQLException e){
				throw new ServletException("UpdateProductLine, " + e.getMessage());
		
		}finally{
			
		}	
	}
	protected void finalize() {
		
	}
	
}


