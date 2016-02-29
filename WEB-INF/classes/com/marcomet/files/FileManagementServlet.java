package com.marcomet.files;

/**********************************************************************
Description:	This servlet takes client requests and calls the 
				appropriate FileManipulator methods.

History:
	Date		Author			Description
	----		------			-----------
	3/23/2001	Brian Murphy	Created
	3/27/2001	"				Changed upload to a popup window

**********************************************************************/

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.marcomet.files.*;
import com.marcomet.mail.JavaMailer;
import com.marcomet.mail.PdfMail;
import com.marcomet.mail.JavaMailer;
import com.marcomet.tools.*;

public class FileManagementServlet extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		FileManipulator fm = new FileManipulator();
		String contentType = request.getHeader("content-type");
		StringTokenizer st = new StringTokenizer(contentType, ";");
		contentType = (String)st.nextElement();
		//JavaMailer mailer = new JavaMailer();
		

		JavaMailer tm;
		try {
			tm = new JavaMailer();
			tm.send();
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		try {
			//mailer.sendEmail();
			
			//pMail.pdfMail(jobId);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		

		try {

			if (contentType.equals("multipart/form-data")) {
				MultipartRequest mr = fm.uploadFile(request, response);
				String location = "";
				try {
					location = mr.getParameter("redirect");
				} catch (Exception ex) {}

				if (location == null) 
					location = "";

				if (!location.equals("")) {
						RequestDispatcher rd = getServletContext().getRequestDispatcher(location);
						rd.forward(request, response);
				} else {
					PrintWriter out;
					response.setContentType("text/html");
					out = response.getWriter();
					out.println("<html><head><title>Closing</title></head>");
					out.println("<script language=\"JavaScript\">");
					out.println("window.parent.opener.location.replace(window.parent.opener.location);");
					out.println("parent.window.setTimeout(\"close()\",200);");
					out.println("</script></html>");
					out.close();
				}
		
			} else if (contentType.equals("application/x-www-form-urlencoded")) {


				String action = "";
				action = request.getParameter("action");
				if (action.equals("associate")) {
					MultipartRequest mr = null;
					fm.associateFiles(request, response, mr);
				}

				
				String location = "";
				try {				
					location = request.getParameter("redirect");
				} catch(Exception ex) {}

				if (!location.equals("")) {
					RequestDispatcher rd = getServletContext().getRequestDispatcher(location);
					rd.forward(request, response);
				} else {
					String[] fileNames = request.getParameterValues("fileList");
					//if (fileNames.length == 1) {
					//	fm.downloadFile(fileNames, request, response);
					//} else {
						fm.downloadArchive(fileNames, request, response);
					//}
				}
			}


		} catch(Exception ex) {

			if (ex.getMessage().equals("FileManipulator uploadFile exception: exists")) {
				request.setAttribute("uploaderror", "An error occurred.  It appears that the file you are attempting to upload already exists, please choose to rename or replace the file and try again.");
				RequestDispatcher rd = getServletContext().getRequestDispatcher("/files/upload.jsp");
				rd.forward(request, response);
			} else {
	        	throw new ServletException("FileManagementServlet exception: " + ex.getMessage());
			}

		}

	} // doPost
} // FileManager
