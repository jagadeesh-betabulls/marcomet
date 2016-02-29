package com.marcomet.sbpprocesses;

/**********************************************************************
Description:	This class will process a shipment and decrease the inventory for the shipped product

**********************************************************************/

import javax.servlet.*;
import javax.servlet.http.*;

import com.marcomet.workflow.actions.*;
import com.marcomet.tools.ReturnPageContentServlet;

public class InterimShipmentInvServlet extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		try {

			ShippedMaterialsInvProcessor smp = new ShippedMaterialsInvProcessor();
			smp.execute(request, response);
		
			CalculateJobCosts cjc = new CalculateJobCosts();
			cjc.execute(request, response);

			ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
			rpcs.printNextPage(this, request, response);
			
		} catch (ServletException ex) {
			throw new ServletException("InterimShipmentInvServlet servlet exception " + ex.getMessage());
		} catch (Exception ex) {
			throw new ServletException("InterimShipmentInvServlet exception " + ex.getMessage());
		}

	}
}
