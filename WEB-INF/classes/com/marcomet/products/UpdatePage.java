package com.marcomet.products;

/**********************************************************************
Description:	Enter and Edit Product Line information


History:
	Date		Author			Description
	----		------			-----------
	8/4/2001	Ed Cimafonte	Created


**********************************************************************/

import com.marcomet.tools.*;
import com.marcomet.jdbc.*;
import com.marcomet.commonprocesses.*;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;



public class UpdatePage extends HttpServlet{
	
	//variables
	String errorMessage;
	int PrId;
	public UpdatePage(){
	
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
		
		try{
			updatePage(request,response); 
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
			throw new ServletException("UpdatePage, forward failed on an error" + ioe.getMessage());
		}
	}

	private void updatePage(HttpServletRequest request, HttpServletResponse response)
	throws SQLException, Exception{
		StringTool str = new StringTool();
		ProcessProductLine pPl = new ProcessProductLine();
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String sql= "update pages  set company_id=?, status_id=?, contact_id=?, submitter_id=?,   action_on_expire_id=?, page_type_id=?, date_created=?, print_file_url=?,    html=?, security_username=?, security_password=?,   security_buriedpage=?, misc_keywords=?,   date_expires=?, date_to_post=?, title=?, is_page_outside_site=?,  redirect_url=?, help_publish=?, only_show_html=?, small_picurl=?,   full_picurl=?, demo_url=?, body=?, summary=? where (id=?)";

			PreparedStatement updatePR = conn.prepareStatement(sql);
			int x=1;
			String tempDate="";
			updatePR.setInt(x++,Integer.parseInt(request.getParameter("companyId")));
			updatePR.setInt(x++,Integer.parseInt(request.getParameter("statusId")));
			updatePR.setInt(x++,Integer.parseInt(request.getParameter("contactId")));
			updatePR.setInt(x++,Integer.parseInt(request.getParameter("submitterId")));
			updatePR.setInt(x++,Integer.parseInt(request.getParameter("actionOnExpireId")));
			updatePR.setInt(x++,Integer.parseInt(request.getParameter("pageTypeId")));
			tempDate = request.getParameter("dateCreated");
			try{tempDate = str.mysqlFormatDate(request.getParameter("dateCreated"));
				}catch(Exception e){}	
			updatePR.setString(x++, tempDate);			
			updatePR.setString(x++, request.getParameter("printFileURL"));
			updatePR.setString(x++, request.getParameter("html"));
			updatePR.setString(x++, request.getParameter("securityUsername"));
			updatePR.setString(x++, request.getParameter("securityPassword"));
			updatePR.setString(x++, request.getParameter("securityBuriedPage"));
			updatePR.setString(x++, request.getParameter("miscKeywords"));
			tempDate = request.getParameter("dateExpires");
			try{tempDate = str.mysqlFormatDate(request.getParameter("dateExpires"));
				}catch(Exception e){}	
			updatePR.setString(x++, tempDate);		
							
			tempDate = request.getParameter("dateToPost");
			try{tempDate = str.mysqlFormatDate(request.getParameter("dateToPost"));
				}catch(Exception e){}
			updatePR.setString(x++, tempDate);							
			updatePR.setString(x++, request.getParameter("title"));
			updatePR.setString(x++, request.getParameter("isPageOutsideSite"));
			updatePR.setString(x++, request.getParameter("redirectURL"));
			updatePR.setString(x++, request.getParameter("helpPublish"));
			updatePR.setString(x++, request.getParameter("onlyShowHtml"));
			updatePR.setString(x++, request.getParameter("smallPicURL"));
			updatePR.setString(x++, request.getParameter("fullPicURL"));
			updatePR.setString(x++, request.getParameter("demoURL"));
			updatePR.setString(x++, request.getParameter("body"));
			updatePR.setString(x++, request.getParameter("summary"));
			updatePR.setString(x++, request.getParameter("pageId"));
					
			updatePR.execute();
		}catch(Exception e){
			errorMessage ="There was an error in update: " + e.getMessage();
			exitWithError(request,response);

		}finally	{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
}

