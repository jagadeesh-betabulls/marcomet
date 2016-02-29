package com.marcomet.admin.accounting;

/**********************************************************************
Description:	This class will create ap_payments.
**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;
import com.marcomet.commonprocesses.*;
import com.marcomet.workflow.actions.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;



public class CreateAPPaymentForm extends HttpServlet{

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		
		Connection conn = null;
		
		try {		

			conn = DBConnect.getConnection();
			int pappId = 0;
			ProcessAPPayment papp = new ProcessAPPayment();
			papp.setAcctgSysRef((String)request.getParameter("acctgSysRef"));
			papp.setPaidContactId((String)request.getParameter("paidContactId"));
			papp.setPaidCompanyId(getCompanyIdFromContactId((String)request.getParameter("paidContactId"), conn));
			papp.setPaymentDate((String)request.getParameter("paymentDate"));
			papp.setPmtTypeId((String)request.getParameter("paymentTypeId"));
			papp.setRefNo((String)request.getParameter("refNo"));

			try {
				pappId = papp.insert();
			} catch(Exception e) {
				//throw new ServletException("error: " + e.getMessage());
				returnWithError(request,response,e.getMessage());
			}	

			Vector details = (Vector)request.getSession().getAttribute("apPaymentDetails");

			if (details != null) {

				PreparedStatement checkBalance = conn.prepareStatement("SELECT SUM(balance_to_vendor + balance_to_site_host) AS sum FROM jobs WHERE id = ?");
				
				for (int i = 0; i < details.size(); i++) {
				
					APPaymentDetailObject appd = (APPaymentDetailObject)details.elementAt(i);

					ProcessAPPaymentDetail pappd = new ProcessAPPaymentDetail();
					pappd.setAcctgSysRef(appd.getAcctgSysRef());
					pappd.setApPaymentId(pappId);
					pappd.setApInvoiceId(appd.getApInvoiceId());
					pappd.setAmount(appd.getAmount());	
					pappd.insert();

					try {

						Vector jobIds = (Vector) appd.getJobIds();
						CalculateJobCosts cjc = new CalculateJobCosts();
						for (Enumeration e = jobIds.elements(); e.hasMoreElements(); ) {

							int jobId = Integer.parseInt((String)e.nextElement());
							cjc.calculate(jobId);

							checkBalance.clearParameters();
							checkBalance.setInt(1, jobId);
							ResultSet rs0 = checkBalance.executeQuery();
							if (rs0.next()) {;

								double sum = rs0.getDouble("sum");

								if (sum == 0) {
									MoveStatus ms = new MoveStatus();
									ms.updateStatus(jobId, Integer.parseInt((String)request.getParameter("nextStepActionId")));
								}

							}

						}

					} catch(Exception e) {
						throw new ServletException("error: " + e.getMessage());
						//returnWithError(request,response,e.getMessage());
					}

				}
			}

		} catch (Exception ex) {
			throw new ServletException("doPost error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		request.getSession().removeAttribute("apPaymentDetails");

		request.setAttribute("errorMessage","Worked");	
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this,request,response);
	}
	
	private int getCompanyIdFromContactId(String contactId, Connection conn) throws ServletException {

		try {

			String sqlCompanyId = "SELECT c.companyid 'companyid' FROM contacts c WHERE id = " + contactId;
			Statement qsCompanyId = conn.createStatement();
			ResultSet rsCompanyId = qsCompanyId.executeQuery(sqlCompanyId);
			
			if(rsCompanyId.next()){
				return rsCompanyId.getInt("companyid");				
			}else{
				return 0;
			}	
		
			
		} catch(Exception e) {
			throw new ServletException("" + e.getMessage());
		}
		
	}
	private void returnWithError(HttpServletRequest request, HttpServletResponse response,String errorMessage)
	throws ServletException{
		request.setAttribute("errorMessage",errorMessage);

		RequestDispatcher rd;
		rd = getServletContext().getRequestDispatcher(request.getParameter("errorPage"));
		try{
			rd.forward(request, response);	
		}catch(IOException ioe){
			throw new ServletException(ioe.getMessage());
		}
	}
}
