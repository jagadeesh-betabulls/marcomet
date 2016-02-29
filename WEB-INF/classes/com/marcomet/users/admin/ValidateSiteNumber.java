package com.marcomet.users.admin;

/**********************************************************************
Description:	This Class will validate the site number entry
			
Notes:
	Assumes http request will contain parameter for siteNumber or site_number

**********************************************************************/

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.marcomet.jdbc.DBConnect;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.*;

public class ValidateSiteNumber extends HttpServlet {
    
    private ServletContext context;
    private HashMap accounts = new HashMap();
 
    public void init(ServletConfig config) throws ServletException {
	    super.init(config);
        this.context = config.getServletContext();

    }
    
    public  void doGet(HttpServletRequest request, HttpServletResponse  response)
        throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        String siteNumber = ((request.getParameter("value")==null)?"":request.getParameter("value"));
        response.setContentType("text/xml");
        response.setHeader("Cache-Control", "no-cache");
	    PrintWriter out = response.getWriter();
	    out.println("<result>");
	    if (!siteNumber.equals("") ) {
			Connection conn = null; 
			Statement qs = null;
			try {			
				conn = DBConnect.getConnection();
				qs = conn.createStatement();
				
				ResultSet rs = qs.executeQuery("Select wcc.description as 'brand',site_name,if(GROUP_CONCAT(DISTINCT z.zip ORDER BY z.zip DESC SEPARATOR '|') is null,wp.zip,concat(wp.zip,'|',GROUP_CONCAT(DISTINCT z.zip ORDER BY z.zip DESC SEPARATOR '|'))) as zip,wcc.site_host as 'site_host' FROM wyndham_properties wp left join wyndham_chain_codes wcc on wp.chain_code=wcc.chain_code left join property_alternate_zips z on wp.site_number=z.site_number WHERE wp.site_number = '"+siteNumber+"' group by wp.site_number");	
				if ( rs.next()) {
					out.println("<valid>true</valid>");
					out.println("<brand>" + rs.getString("brand")+ "</brand>");
					out.println("<siteName>" + rs.getString("site_name")+ "</siteName>");
					out.println("<zip>" + rs.getString("zip")+ "</zip>");
					out.println("<sitehost>" + rs.getString("site_host")+ "</sitehost>");
					out.println("<msg>*</msg>");
					//property record found
				}else{
					//property record not found
					out.println("<valid>false</valid>");
					out.println("<msg>Property record not found.</msg>");	
				}
			} catch (Exception x) {
				System.err.println(x.getMessage());
				x.printStackTrace();
				out.println("<valid>false</valid>");
				out.println("<msg>"+x.getMessage()+"</msg>");
			} finally {
				try { qs.close(); } catch ( Exception x) { qs = null; }
				try { conn.close(); } catch ( Exception x) { conn = null; }
			    out.println("</result>");
			    out.close();
			}
        } else {
        	out.println("<valid>false</valid>");
        	out.println("<msg>Site number blank.</msg>");
    	    out.println("</result>");
		    out.close();
        }
    }

    public  void doPost(HttpServletRequest request, HttpServletResponse  response)
        throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        String siteNumber = ((request.getParameter("value")==null)?"":request.getParameter("value"));
        response.setContentType("text/xml");
        response.setHeader("Cache-Control", "no-cache");
	    PrintWriter out = response.getWriter();
	    if (!siteNumber.equals("") ) {
			Connection conn = null; 
			Statement qs = null;
			try {			
				conn = DBConnect.getConnection();
				qs = conn.createStatement();
				
				ResultSet rs = qs.executeQuery("Select wcc.description as 'brand',site_name,zip,wcc.site_host as 'site_host' FROM wyndham_properties wp left join wyndham_chain_codes wcc on wp.chain_code=wcc.chain_code WHERE site_number = '"+siteNumber+"'");	
				if ( rs.next()) {
					out.println("<valid>true</valid>"+
								"<brand>" + rs.getString("brand")+ "</brand>"+
								"<siteName>" + rs.getString("site_name")+ "</siteName>"+
								"<zip>" + rs.getString("zip")+ "</zip>"+
								"<sitehost>" + rs.getString("site_host")+ "</sitehost>"+
		            			"<msg>*</msg>");
					//property record found
				}else{
					//property record not found
					out.println("<valid>false</valid>"+
		            			"<msg>Property record not found.</msg>");	
				}
			} catch (Exception x) {
				System.err.println(x.getMessage());
				x.printStackTrace();
				out.println("<valid>false</valid>"+	
	            			"<msg>"+x.getMessage()+"</msg>");
			} finally {
				try { qs.close(); } catch ( Exception x) { qs = null; }
				try { conn.close(); } catch ( Exception x) { conn = null; }
			    out.close();
			}
        } else {
        	out.println("<valid>false</valid>"+	
            			"<msg>Site number blank.</msg>");
		    out.close();
        }
    }
}
