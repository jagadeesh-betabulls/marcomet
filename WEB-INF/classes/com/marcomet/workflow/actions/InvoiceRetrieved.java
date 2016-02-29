

/**********************************************************************
Description:	This class will mark an invoice as retrieved

History:
	Date		Author			Description
	----		------			-----------

	1/23/02		ekc				Modified for new invoicing structure

**********************************************************************/
package com.marcomet.workflow.actions;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.marcomet.commonprocesses.*;
import com.marcomet.workflow.actions.*;
import com.marcomet.jdbc.*;
import com.marcomet.tools.ReturnPageContentServlet;
import com.marcomet.files.MultipartRequest;

public class  InvoiceRetrieved  implements ActionInterface {

	
	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {	
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		Connection conn = null; 
		int companyId;
		String invoiceId="";
		String statusId="";
		

		try {
			conn = DBConnect.getConnection();
			if (request.getAttribute("errorMessage")==null){
				invoiceId = request.getParameter("id");	
				statusId=request.getParameter("statusId");
				HttpSession session = request.getSession();
				int userId = Integer.parseInt(request.getParameter("contactId"));	
				String updateInvoice = "update ar_invoices set status_id=?, last_retrieved_by_id=? where id=?";
				PreparedStatement stUpdateInvoice = conn.prepareStatement(updateInvoice);
				stUpdateInvoice.setInt(1,Integer.parseInt(statusId));
				stUpdateInvoice.setInt(2,userId);			
				stUpdateInvoice.setInt(3,Integer.parseInt(invoiceId));
				stUpdateInvoice.execute();
			}
			return new Hashtable();
			 
		} catch (Exception ex) {
			throw new ServletException("InvoiceRetrieved exception " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}


	}

}
