package com.marcomet.admin.company;

/**********************************************************************
Description:	This class will update company information
**********************************************************************/

import com.marcomet.tools.*;
import com.marcomet.commonprocesses.*;
import com.marcomet.jdbc.DBConnect;
import java.io.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

public class UpdateCompanyInformationServlet extends HttpServlet{

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		try {

			if (request.getParameter("formChangedCompany").equals("1")) {
				updateCompanyInfo(request);
			}

			if(request.getParameter("formChangedLocations").equals("1")) {
				updateLocations(request);
			}

			if(request.getParameter("formChangedContacts").equals("1")){	
				updateContactTypes(request);
			}

		} catch(Exception e) {
			exitWithError(request,response, e.getMessage());
			return;
		}

		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this,request,response);

	}
	private void exitWithError(HttpServletRequest request, HttpServletResponse response, String errorMessage) throws ServletException{

		//set error attribute
		request.setAttribute("errorMessage",errorMessage);

		//goto an error page
		RequestDispatcher rd;
		rd = getServletContext().getRequestDispatcher(request.getParameter("errorPage"));

		try {
			rd.forward(request, response);
		} catch(IOException ioe) {
			throw new ServletException("NewUserRegistration, forward failed on an error" + ioe.getMessage());
		}

	}
	public void updateCompanyInfo(HttpServletRequest request) throws SQLException {

		ProcessCompany pc = new ProcessCompany();
		pc.setId(request.getParameter("companyId"));
		pc.setCompanyName(request.getParameter("companyName"));
		pc.setCompanyURL(request.getParameter("companyURL"));
		pc.update();

	}
	private void updateContactTypes(HttpServletRequest request) throws SQLException {

		ProcessContactType pct = new ProcessContactType();
		pct.deleteCompanyId(Integer.parseInt(request.getParameter("companyId")));
		
		//insert primary contact
		pct.setContactId(request.getParameter("primaryContactId"));
		pct.setLUContactTypeId(1);
		pct.insert();
		
		//insert bill to contact
		pct.setContactId(request.getParameter("billToContactId"));
		pct.setLUContactTypeId(2);
		pct.insert();
		
		//insert pay to contact
		pct.setContactId(request.getParameter("payToContactId"));
		pct.setLUContactTypeId(1);
		pct.insert();
		
		//insert workflow contact
		pct.setContactId(request.getParameter("workFlowContactId"));
		pct.setLUContactTypeId(1);
		pct.insert();

	}
	public void updateLocations(HttpServletRequest request) throws SQLException {

	
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
		
			String sql = "UPDATE company_locations SET address1 = ?, address2 = ?, city = ?, state = ?, zip = ?, country_id = ? WHERE lu_location_type_id = ? AND company_id = ?";
			PreparedStatement update = conn.prepareStatement(sql);
		
			update.clearParameters();
			update.setString(1, request.getParameter("billToAddress1"));
			update.setString(2, request.getParameter("billToAddress2"));
			update.setString(3, request.getParameter("billToCity"));
			update.setString(4, request.getParameter("billToStateId"));
			update.setString(5, request.getParameter("billToZipcode"));
			update.setString(6, request.getParameter("billToCountryId"));
			update.setInt(7, 2);
			update.setString(8, request.getParameter("companyId"));
			update.execute();
	
			//clear out parameters
			update.clearParameters();
	
			//update payto
			update.setString(1, request.getParameter("payToAddress1"));
			update.setString(2, request.getParameter("payToAddress2"));
			update.setString(3, request.getParameter("payToCity"));
			update.setString(4, request.getParameter("payToStateId"));
			update.setString(5, request.getParameter("payToZipcode"));
			update.setString(6, request.getParameter("payToCountryId"));
			update.setInt(7, 3);
			update.setString(8, request.getParameter("companyId"));
			update.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	}
}
