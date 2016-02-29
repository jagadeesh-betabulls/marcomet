package com.marcomet.users.admin;

/**********************************************************************
Description:	This Class will validate the value or useremail entry
			
Notes:
	Assumes http request will contain parameter 'value' for value or email value, as well as MODE for which to check, value or email

**********************************************************************/

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.marcomet.environment.SiteHostSettings;
import com.marcomet.jdbc.DBConnect;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.*;

public class ValidateUserName extends HttpServlet {
    
    private ServletContext context;
    private HashMap accounts = new HashMap();
 
    public void init(ServletConfig config) throws ServletException {
	    super.init(config);
        this.context = config.getServletContext();

    }
    
    public  void doGet(HttpServletRequest request, HttpServletResponse  response)
        throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        String value = ((request.getParameter("value")==null)?"":request.getParameter("value"));
        String mode = ((request.getParameter("mode")==null)?"username":request.getParameter("mode"));
        SiteHostSettings shs = (SiteHostSettings)request.getSession().getAttribute("siteHostSettings");
        String sitehostid = shs.getSiteHostId();
        response.setContentType("text/xml");
        response.setHeader("Cache-Control", "no-cache");
	    PrintWriter out = response.getWriter();
	    out.println("<result>");
	    if (!value.equals("") ) {
			Connection conn = null; 
			Statement qs = null;
			try {			
				conn = DBConnect.getConnection();
				qs = conn.createStatement();
				String queryStr=((mode.equals("username"))?"Select contact_id FROM logins WHERE user_name = '"+value+"'":"SELECT  c.id as contact_id  FROM contacts c left join reg_group_bridge r on default_website=r.sitehost_id left join reg_group_bridge r1 on r1.sitehost_id="+sitehostid+" and r.group_id=r1.group_id  WHERE email = '"+value+"' and r1.id is not null");
				String errStr=((mode.equals("username"))?"Error: There is already a user with that login name, please try another.  If you have already registered and have forgotten your password please {a href='/admin/user_password_reset.jsp'}Click Here to retrieve your User Name and reset your password.{/a}":"Error: There is already a user with that email address, please try another.  If you have already registered with that email address and have forgotten your user name or password please {a href='/admin/user_password_reset.jsp'}Click Here to retrieve your User Name and reset your password.{/a}");
				ResultSet rs = qs.executeQuery(queryStr);
				if ( rs.next()) {
					out.println("<valid>false</valid>");
					out.println("<cid>" + rs.getString("contact_id")+ "</cid>");
					out.println("<msg>"+errStr+"</msg>");
					//property record found
				}else{
					//property record not found
					out.println("<valid>true</valid>");
					out.println("<msg>*</msg>");	
				}
			} catch (Exception x) {
				System.err.println(x.getMessage());
				x.printStackTrace();
				out.println("<valid>false</valid>");
				out.println("<msg>Error:"+x.getMessage()+"</msg>");
			} finally {
				try { qs.close(); } catch ( Exception x) { qs = null; }
				try { conn.close(); } catch ( Exception x) { conn = null; }
			    out.println("</result>");
			    out.close();
			}
        } else {
        	out.println("<valid>false</valid>");
        	out.println("<msg>User Name/Email blank.</msg>");
    	    out.println("</result>");
		    out.close();
        }
    }

    public  void doPost(HttpServletRequest request, HttpServletResponse  response)
        throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        String value = ((request.getParameter("value")==null)?"":request.getParameter("value"));
        String mode = ((request.getParameter("mode")==null)?"username":request.getParameter("mode"));
        response.setContentType("text/xml");
        response.setHeader("Cache-Control", "no-cache");
        SiteHostSettings shs = (SiteHostSettings)request.getSession().getAttribute("siteHostSettings");
        String sitehostid = shs.getSiteHostId();
	    PrintWriter out = response.getWriter();
	    out.println("<result>");
	    if (!value.equals("") ) {
			Connection conn = null; 
			Statement qs = null;
			try {			
				conn = DBConnect.getConnection();
				qs = conn.createStatement();
				String query=((mode.equals("username"))?"Select contact_id FROM logins WHERE user_name = '"+value+"'":"SELECT c.id as contact_id FROM contacts c left join reg_group_bridge r on default_website=r.sitehost_id left join reg_group_bridge r1 on r1.sitehost_id="+sitehostid+" and r.group_id=r1.group_id  WHERE email = '"+value+"' and r1.id is not null");
				String errStr=((mode.equals("username"))?"Error: There is already a user with that login name, please try another.  If you have already registered and have forgotten your password please <a href='/admin/user_password_reset.jsp'>Click Here to retrieve your User Name and reset your password.</a>":"Error: There is already a user with that email address, please try another.  If you have already registered with that email address and have forgotten your user name or password please <a href='/admin/user_password_reset.jsp'>Click Here to retrieve your User Name and reset your password.</a>");
				ResultSet rs = qs.executeQuery(query);
				if ( rs.next()) {
					out.println("<valid>False</valid>");
					out.println("<cid>" + rs.getString("contact_id")+ "</cid>");
					out.println("<msg>"+errStr+"</msg>");
					//property record found
				}else{
					//property record not found
					out.println("<valid>true</valid>");
					out.println("<msg></msg>");	
				}
			} catch (Exception x) {
				System.err.println(x.getMessage());
				x.printStackTrace();
				out.println("<valid>false</valid>");
				out.println("<msg>Error:"+x.getMessage()+"</msg>");
			} finally {
				try { qs.close(); } catch ( Exception x) { qs = null; }
				try { conn.close(); } catch ( Exception x) { conn = null; }
			    out.println("</result>");
			    out.close();
			}
        } else {
        	out.println("<valid>false</valid>");
        	out.println("<msg>User Name/Email blank.</msg>");
    	    out.println("</result>");
		    out.close();
        }
	}
}
