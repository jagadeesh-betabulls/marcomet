/**********************************************************************
Description:	Takes information from the form, and creates a APPaymentDetail
				in memory till person submits the CreateAPPaymentForm

History:
	Date		Author			Description
	----		------			-----------
	8/29/01		Thomas Dietrich		Created

**********************************************************************/

package com.marcomet.admin.accounting;

import com.marcomet.tools.*;

import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class CreateAPPaymentDetailForm extends HttpServlet{

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
	
		Vector details = (Vector)request.getSession().getAttribute("apPaymentDetails");
		
		if(details == null){
			details = new Vector();
		}
			
		APPaymentDetailObject detail = new APPaymentDetailObject();	
		
		detail.setApInvoiceId(Integer.parseInt((String)request.getParameter("apInvoiceId")));
		detail.setAmount(Double.parseDouble((String)request.getParameter("amount")));;
		detail.setAcctgSysRef(request.getParameter("acctgSysRef"));
		
		//add detail to details
		details.add(detail);
		
		//add details session, this will over write the old one with this new version if it exists.  
		//could just test for the old one, but this is quicker 
		request.getSession().setAttribute("apPaymentDetails",details);
		
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this, request, response);
	
	}


}