package com.marcomet.users.admin;

import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

import com.marcomet.jdbc.*;

public class EditPasswordServlet extends HttpServlet {

/**
 * EditPasswordServlet constructor comment.
 */
public EditPasswordServlet() {
	super();
}
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException{

		Connection conn = null; 

		try {			
			String newPassword = request.getParameter("newPassword");
			String newPasswordConfirm = request.getParameter("newPasswordConfirm");

			if (!newPassword.equals(newPasswordConfirm)) {
				request.setAttribute("errorMessage", "The new passwords don't match");
				throw new ServletException();
			}
			String contactId=((request.getParameter("contactId")==null)?"":request.getParameter("contactId"));
			conn = DBConnect.getConnection();
			String sql1 =((contactId.equals(""))?"SELECT contact_id FROM logins WHERE user_name = ? AND user_password = md5(?)":"SELECT contact_id FROM logins WHERE user_name = ? AND user_password = md5(?) and contact_id='"+contactId+"'");
			PreparedStatement selectLogin = conn.prepareStatement(sql1);

			selectLogin.setString(1,request.getParameter("userName"));
			selectLogin.setString(2,request.getParameter("oldPassword"));
			ResultSet rs1 = selectLogin.executeQuery();
			if (rs1.next() || (request.getParameter("proxyId")!=null && !request.getParameter("proxyId").equals(""))) {
				Statement st = conn.createStatement();
				String updateSQL = "update logins set user_password=md5(?) where contact_id=?";
				try {
					//lock table
					st.execute("LOCK TABLES logins WRITE");
					PreparedStatement updatePassword = conn.prepareStatement(updateSQL);
					updatePassword.clearParameters();
					updatePassword.setString(1, newPassword);
					updatePassword.setString(2, contactId);
					updatePassword.execute();
					request.setAttribute("returnMessage", "Password updated");
				} finally {
					st.execute("UNLOCK TABLES");
				}
				
			} else {
				request.setAttribute("errorMessage", "The original password entered is incorrect, please try again");
				throw new ServletException();
			}

			RequestDispatcher rd = getServletConfig().getServletContext().getRequestDispatcher("/users/ChangePasswordForm.jsp");
			rd.forward(request, response);

		} catch(SQLException sqle) {
			throw new ServletException("SQL Error: " + sqle.getMessage());
		} catch (java.io.IOException ioe) {
			throw new ServletException("Error on redirect");
		} catch (ServletException se) {
			try {
				RequestDispatcher rd = getServletConfig().getServletContext().getRequestDispatcher("/users/ChangePasswordForm.jsp");
				rd.forward(request, response);
			} catch (Exception ex) {}
		} catch (Exception x) {
			throw new ServletException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	}
}
