package com.marcomet.sbpprocesses;

/**********************************************************************
Description:	This class will update the status of a job
**********************************************************************/

import javax.servlet.*;
import javax.servlet.http.*;

import com.marcomet.workflow.actions.*;
import com.marcomet.tools.ReturnPageContentServlet;

public class InterimShipmentServlet extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		try {

			ShippedMaterialsProcessor smp = new ShippedMaterialsProcessor();
			smp.execute(request, response);
		
			CalculateJobCosts cjc = new CalculateJobCosts();
			cjc.execute(request, response);

			ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
			rpcs.printNextPage(this, request, response);
			
		} catch (ServletException ex) {
			throw new ServletException("InterimShipmentServlet servlet exception " + ex.getMessage());
		} catch (Exception ex) {
			throw new ServletException("InterimShipmentServlet exception " + ex.getMessage());
		}

	}
}
