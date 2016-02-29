/**********************************************************************
Description:	this class allows the web developer to control the next 
				page after the submission, with the $$Return field.
**********************************************************************/

package com.marcomet.tools;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class ReturnPageContentServlet extends HttpServlet{
	
	public void destroy(){
		super.destroy();
	}
	public void init(ServletConfig cfg)
	throws ServletException	{
		super.init(cfg);
	}
	private void printCloseWindow(HttpServletRequest req, HttpServletResponse res)
	throws ServletException{		
		try{
			PrintWriter out;
			// set content type and other response header fields first
			res.setContentType("text/html");

			// then write the data of the response
			out = res.getWriter();

			out.println("<HTML><HEAD><TITLE>Closing</TITLE></HEAD>");
			out.println("<script language=\"JavaScript\">");
			out.println("parent.window.setTimeout(\"window.parent.opener.refreshPageNoURL()\",1000);");
			out.println("parent.window.setTimeout(\"close()\",1500);");
			out.println("</script></HTML>");
			out.close();
		}catch(IOException ioe){
			throw new ServletException("ReturnPageContentServlet, printCloseWindow(): " + ioe.getMessage());		
		}
	}
	public void printNextPage(HttpServlet servlet, HttpServletRequest req, HttpServletResponse res)
	throws ServletException
	{		
		String next = req.getParameter("$$Return");

		if(next == null || next.equals("")){
			printCloseWindow(req,res);
			return;
		}

		if(next.indexOf('[') > -1){
			//if (servlet==null){
				redirectPage2(servlet,req, res);   // seems to fail always on a null for the servlet
			//}else{
				redirectPage(req,res);
			//}
			//           //backup function if #2 fails again
		}

		try{
			PrintWriter out;
			// set content type and other response header fields first
			res.setContentType("text/html");

			// then write the data of the response
			out = res.getWriter();

			out.println(next);
			out.close();
		}catch(IOException ioe){
			throw new ServletException("ReturnPageContentServlet, printNextPage(): " + ioe.getMessage());		
		}
	}
	private void redirectPage(HttpServletRequest req, HttpServletResponse res)
	throws ServletException{
		StringTool stringTool = new StringTool();
		String next = stringTool.replaceSubstring(req.getParameter("$$Return"),"[","");
		next = stringTool.replaceSubstring(next,"]","");

		try{
			PrintWriter out;
			// set content type and other response header fields first
			res.setContentType("text/html");

			// then write the data of the response
			out = res.getWriter();

			out.println("<HTML><HEAD><TITLE>Closing</TITLE></HEAD>");
			out.println("<script language=\"JavaScript\">");
			out.println("window.location.replace(\""+next+"\");");
			out.println("</script></HTML>");
			out.close();
		}catch(IOException ioe){
			throw new ServletException("ReturnPageContentServlet, redirectPage(): " + ioe.getMessage());		
		}
	}
	private void redirectPage2(HttpServlet servlet, HttpServletRequest req, HttpServletResponse res)
	throws ServletException{
		StringTool stringTool = new StringTool();
		String next = stringTool.replaceSubstring(req.getParameter("$$Return"),"[","");
		next = stringTool.replaceSubstring(next,"]","");	

		if ( next.charAt(next.length() -1) == '/' )
			next += "index.jsp";


			RequestDispatcher rd;
		try{	
			rd = servlet.getServletContext().getRequestDispatcher(next);
			rd.forward(req, res);
		
		}catch(Exception e){
			try{
				
				rd = servlet.getServletContext().getRequestDispatcher("/index.jsp");
				rd.forward(req, res);			
			
			}catch(Exception ex){
				throw new ServletException("The forwarder failed, (even after putting the /), next: " + next);
			}
		}

	}
}
