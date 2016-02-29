/**********************************************************************
Description:	This class will generate a report of request parameters

History:
	Date		Author			Description
	----		------			-----------
	10/1/2001	Thomas Dietrich	Created
	
**********************************************************************/

package com.marcomet.admin.debug;

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;

import java.io.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;


public class RequestInformation extends HttpServlet {

	public void doGet(HttpServletRequest request, HttpServletResponse response)
	throws IOException{
		doPost(request, response);	
	} 

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws IOException{
	
		//print results
	    PrintWriter		out;

	    // set content type and other response header fields first
        response.setContentType("text/html");
		
		// then write the data of the response
	    out = response.getWriter();
	    out.println(getHtmlStart());
		out.println("<table>");
				
		java.util.Enumeration varNames = request.getParameterNames();
		String varValue = "";
		String varName = "";
		
		if(varNames.hasMoreElements()){
			do{
				varName = (String)varNames.nextElement();
				try{
					if(request.getParameter(varName) == null){
						varValue="HAS NO VALUE";		
					}else{
						//varValue = (String)session.getAttribute(varName);
						varValue = request.getParameter(varName).toString();
					}	
				}catch(Exception e){
					varValue="IS AN OBJECT" + ": " + e.getMessage();	
				}
			
				out.println("<tr><td>" + varName + "</td><td>"+ varValue + "</td></tr>");

			}while(varNames.hasMoreElements());
		}else{

			out.println("<tr><td colspan=\"2\">No request parameters</td></tr>");
	
		}
		
		out.println("</table>");	
		out.println(getHtmlEnd());
	    out.close();
		
	}

	private String getHtmlStart(){
		
		StringBuffer sb = new StringBuffer();
		
		sb.append("<html>");
		sb.append("<head>");
		sb.append("<title>Sales Report By Site/Buyer</title>");
		sb.append("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">");
		sb.append("<META HTTP-EQUIV=\"pragma\" CONTENT=\"no-cache\">");
		sb.append("<META HTTP-EQUIV=\"Pragma-directive\" CONTENT=\"no-cache\">");
		sb.append("<META HTTP-EQUIV=\"cache-directive\" CONTENT=\"no-cache\">");
		sb.append("</head>");
		sb.append("<script language=\"JavaScript\" src=\"/javascripts/mainlib.js\"></script>");
		sb.append("<body bgcolor=\"#FFFFFF\" text=\"#000000\">");
		
		return sb.toString();
	}
	
	private String getHtmlEnd(){
		return "</body></html>";	
	}	
		
	

}