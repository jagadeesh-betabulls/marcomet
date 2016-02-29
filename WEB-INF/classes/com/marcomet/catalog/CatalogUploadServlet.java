package com.marcomet.catalog;

/**********************************************************************
Description:	This servlet handles file uploads and then redirects
				to the controller servlet for the rest of the processing

History:
	Date		Author			Description
	----		------			-----------
	8/22/01		Brian Murphy	Created
	
**********************************************************************/

import javax.servlet.*;
import javax.servlet.http.*;

import com.marcomet.files.*;
import com.marcomet.environment.SiteHostSettings;

public class CatalogUploadServlet extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		try {
			this.processMultipartRequest(request, response);
		} catch (ServletException ex) {
			throw new ServletException("CatalogControllerServlet Error: " + ex.getMessage());
		}

	}
	public void processMultipartRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		try {

			FileManipulator fm = new FileManipulator();
			MultipartRequest mr = fm.uploadFile(request, response);
			if (mr.getParameterValues("associatedFileList") != null) {
				fm.associateFiles(request, response, mr);
			}

			ProjectObject po = (ProjectObject)mr.getSession().getAttribute("currentProject");
			po.uploadComplete = true;

			int vendorId = Integer.parseInt((String)mr.getParameter("vendorId"));
			int catJobId = Integer.parseInt((String)mr.getParameter("catJobId"));
			int offeringId = Integer.parseInt((String)mr.getParameter("offeringId"));
			int tierId = Integer.parseInt((String)mr.getParameter("tierId"));
			int currentCatalogPage = Integer.parseInt((String)mr.getParameter("currentCatalogPage"));
			int siteHostId = Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId());
			
			response.sendRedirect("/servlet/com.marcomet.catalog.CatalogControllerServlet?vendorId=" + vendorId + "&catJobId=" + catJobId + "&offeringId=" + offeringId + "&siteHostId=" + siteHostId + "&currentCatalogPage=" + currentCatalogPage + "&tierId=" + tierId);

		} catch (Exception ex) {
			if (ex.getMessage().equals("FileManipulator uploadFile exception: exists")) {
				request.setAttribute("uploaderror", "An error occurred.  It appears that one of the files you are attempting to upload already exists, please rename the files and try again.");
				RequestDispatcher rd = getServletConfig().getServletContext().getRequestDispatcher("/contents/DuplicateFile.jsp");
				try {
					rd.forward(request, response);
				} catch (java.io.IOException ioe) {
					throw new ServletException("processRequest IO Error: " + ioe.getMessage());
				}
			} else {
				throw new ServletException(ex.getMessage());      
			}
		}


	} // processMultipartRequest
}
