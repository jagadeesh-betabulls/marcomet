/**********************************************************************
Description:	This class will generate a report for the vendor

History:
	Date		Author			Description
	----		------			-----------
	9/27/2001	Thomas Dietrich	Created
	
**********************************************************************/

package com.marcomet.reports;

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;
import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;


public class VendorSalesReport extends HttpServlet {
	
	//tools
	FormaterTool formater;
	
	//session values, for stuff like site host specific information
	String siteHostRoot;
	
	//report total
	double rTotalPrice = 0;
	double rTotalShipping = 0;
	double rTotalSalesTax = 0;
	double rTotalDeposit = 0;
	double rTotalTotal = 0;
		
	//filters
	String siteHostCompanyFrom;
	String siteHostCompanyTo;
	String buyerCompanyFrom;
	String buyerCompanyTo;
	String dateFrom;
	String dateTo;
	String jobTypeFrom;
	String jobTypeTo;
	String serviceTypeFrom;
	String serviceTypeTo;
	String stateTaxFrom;
	String stateTaxTo;
	String reportType;
	String vendorId="";
	String alt="";

	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException,IOException{
	
		//check to see is the session has timed out
		if(request.getSession().getAttribute("currentSession")==null){
			RequestDispatcher rd = getServletContext().getRequestDispatcher("/contents/SessionTimedOutPage.jsp");
			rd.forward(request, response);	
			return;
		} 
	
		formater = new FormaterTool();
		String htmlBody = "";
		
		getFilterValues(request);
		getSessionValues(request);
		
		try{		
			
			htmlBody = getReport();		
		
		}catch(Exception e){
			htmlBody = "error: " + e.getMessage();
		}
		
		//print results
	    PrintWriter		out;

	    // set content type and other response header fields first
        response.setContentType("text/html");

	    // then write the data of the response
	    out = response.getWriter();
	    out.println(getHtmlStart());
		out.println(htmlBody);
		out.println(getHtmlEnd());
	    out.close();		     			
	}
		

	private void getFilterValues(HttpServletRequest request){
		siteHostCompanyFrom = request.getParameter("siteHostCompanyFrom");
		siteHostCompanyTo = request.getParameter("siteHostCompanyTo");
		buyerCompanyFrom = request.getParameter("buyerCompanyFrom");
		buyerCompanyTo = request.getParameter("buyerCompanyTo");
		dateFrom = request.getParameter("dateFrom");
		dateTo = request.getParameter("dateTo");
		jobTypeFrom = request.getParameter("jobTypeFrom");
		jobTypeTo = request.getParameter("jobTypeTo");
		serviceTypeFrom = request.getParameter("serviceTypeFrom");
		serviceTypeTo = request.getParameter("serviceTypeTo");
		stateTaxFrom = request.getParameter("stateTaxFrom");
		stateTaxTo = request.getParameter("stateTaxTo");		
		reportType = request.getParameter("reportType");
		vendorId=request.getParameter("vendorId");
	}
	
	private void getSessionValues(HttpServletRequest request){
		siteHostRoot = (String)request.getSession().getAttribute("siteHostRoot");

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
		sb.append("<link rel=\"stylesheet\" href=\"");
		sb.append(siteHostRoot);
		sb.append("/styles/vendor_styles.css\" type=\"text/css\">");
		sb.append("</head>");
		sb.append("<script language=\"JavaScript\" src=\"/javascripts/mainlib.js\"></script>");
		sb.append("<body bgcolor=\"#FFFFFF\" text=\"#000000\">");
		
		return sb.toString();
	}
	
	private String getHtmlEnd(){
		return "</body></html>";	
	}	
		
	private String getBlankRow(){
		StringBuffer sb = new StringBuffer();
		sb.append("<tr>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("<td>&nbsp;</td>");
		sb.append("</tr>");				
		
		return sb.toString();	
	}
	
	private String getBlankCells(int number){
		StringBuffer sb = new StringBuffer();
		for(int i = 0; i < number; i++){
			sb.append("<td>&nbsp;</td>");		
		}	
		return sb.toString();	
	}

	private String getReport() throws SQLException{
	
		//prepare results
		StringBuffer output = new StringBuffer();
		rTotalPrice = 0;
		rTotalShipping = 0; 
		rTotalSalesTax = 0;
		rTotalDeposit = 0;
		rTotalTotal = 0;	
						
		String sqlSiteHosts;
		//type 1 is by site-host, type 2 is by state sales tax
		if(reportType.equals("1")){
			sqlSiteHosts = "SELECT shcomp.id, shcomp.company_name, sh.id FROM site_hosts sh, companies shcomp, orders o,projects p,jobs j WHERE  j.vendor_company_id = "+vendorId+" and j.project_id=p.id and p.order_id=o.id and sh.company_id = shcomp.id AND o.site_host_id = sh.id AND " + siteHostCompanyFrom + " AND " + siteHostCompanyTo + " GROUP BY shcomp.id, shcomp.company_name ORDER BY shcomp.company_name";
		}else{
			sqlSiteHosts = "SELECT shcomp.id, shcomp.company_name, sh.id FROM site_hosts sh, companies shcomp, orders o, projects p, jobs j, sales_tax st WHERE j.vendor_company_id = "+vendorId+" and sh.company_id = shcomp.id AND o.site_host_id = sh.id AND p.order_id = o.id AND j.project_id = p.id AND st.job_id = j.id  AND " + siteHostCompanyFrom + " AND " + siteHostCompanyTo + " GROUP BY shcomp.id, shcomp.company_name ORDER BY shcomp.company_name";
		}
			
		Connection conn = null;
		try {
			
			conn = DBConnect.getConnection();
			Statement qsSiteHosts = conn.createStatement();
			ResultSet rsSiteHosts = qsSiteHosts.executeQuery(sqlSiteHosts);
			
			if(rsSiteHosts.next()){
				
				output.append("<table border=\"0\" cellpadding=\"1\" cellspacing=\"0\" width=\"100%\">");		
			
				do{
					String sqlBuyers;
					if(reportType.equals("1")){
						sqlBuyers = "SELECT bcomp.id, bcomp.company_name FROM companies bcomp, orders o,projects p,jobs j  WHERE  j.vendor_company_id = "+vendorId+" and j.project_id=p.id and p.order_id=o.id and  o.buyer_company_id = bcomp.id AND o.site_host_id = "+rsSiteHosts.getInt("sh.id")+" AND "+buyerCompanyFrom+" AND "+buyerCompanyTo+" GROUP BY bcomp.id, bcomp.company_name ORDER BY bcomp.company_name";
					}else{
						sqlBuyers = "SELECT bcomp.id, bcomp.company_name FROM companies bcomp, orders o, projects p, jobs j, sales_tax st WHERE  j.vendor_company_id = "+vendorId+" and o.buyer_company_id = bcomp.id AND o.site_host_id = " + rsSiteHosts.getInt("sh.id") + " AND p.order_id = o.id AND p.id = j.project_id AND st.job_id = j.id AND "+buyerCompanyFrom+" AND "+buyerCompanyTo+" GROUP BY bcomp.id, bcomp.company_name ORDER BY bcomp.company_name";	
					}	
						
					Statement qsBuyers = conn.createStatement();				
					ResultSet rsBuyers = qsBuyers.executeQuery(sqlBuyers);
					
					
					if(rsBuyers.next()){
						do{
	
							output.append("<tr>");
							output.append("<td class=\"label\" >Source:</td>");
							output.append("<td>");
							output.append(rsSiteHosts.getString("shcomp.company_name"));
							output.append("</td>");
							output.append(getBlankCells(11));
							output.append("</tr>");
							output.append("<tr>");
							output.append("<td class=\"label\" >Buyer Company:</td>");
							output.append("<td>");
							output.append(rsBuyers.getString("bcomp.company_name"));
							output.append("</td>");
							output.append(getBlankCells(11));
							output.append("</tr>");
							output.append(getBlankRow());
			
							output.append("<tr>");
							output.append("<td class=\"minderheadercenter\" >Invoice Date</td>");
							output.append("<td class=\"minderheadercenter\" >Invoice #</td>");
							output.append("<td class=\"minderheadercenter\" >Job #</td>");
							output.append("<td class=\"minderheadercenter\" >Job Type</td>");
							output.append("<td class=\"minderheadercenter\" >Service Type</td>");
							output.append("<td class=\"minderheadercenter\" >Job Amount</td>");
							output.append("<td class=\"minderheadercenter\" >Shipping</td>");
							output.append("<td class=\"minderheadercenter\" >Sales Tax</td>");
							output.append("<td class=\"minderheadercenter\" >Deposit</td>");
							output.append("<td class=\"minderheadercenter\" >Total</td>");
							output.append("<td class=\"minderheadercenter\" >&nbsp;</td>");
							output.append("<td class=\"minderheadercenter\" >Tax State</td>");
							output.append("<td class=\"minderheadercenter\" >Tax Status</td>");
							output.append("</tr>");
							output.append(getBlankRow());
		
								
							//Invoice section
							String sqlARInvoices;						
							if(stateTaxFrom.equals("1 = 1") && stateTaxTo.equals("1 = 1")){
								if(reportType.equals("1")){
									//with out sales tax state filter site_host report type
									sqlARInvoices = "SELECT ai.* FROM ar_invoices ai, ar_invoice_details arid, jobs j, lu_job_types lujt, lu_service_types lust WHERE  j.vendor_company_id = "+vendorId+" and ai.id = arid.ar_invoiceid AND arid.jobid = j.id AND j.job_type_id = lujt.id AND j.service_type_id = lust.id AND ai.bill_to_companyid = " + rsBuyers.getInt("bcomp.id") + " AND " + jobTypeFrom + " AND " + jobTypeTo + " AND " + serviceTypeFrom + " AND " + serviceTypeTo + " AND ai.creation_date >= '" + dateFrom +"' AND ai.creation_date <= '" + dateTo + "' GROUP BY ai.id ORDER BY ai.creation_date ";
								}else{
									//with out sales tax state filter state sales tax type report type
									sqlARInvoices = "SELECT ai.* FROM ar_invoices ai, ar_invoice_details arid, jobs j, lu_job_types lujt, lu_service_types lust, sales_tax st, lu_abreviated_states luas WHERE  j.vendor_company_id = "+vendorId+" and ai.id = arid.ar_invoiceid AND arid.jobid = j.id AND j.job_type_id = lujt.id AND j.service_type_id = lust.id AND j.id = st.job_id AND st.entity = luas.id AND ai.bill_to_companyid = " + rsBuyers.getInt("bcomp.id") + " AND " + jobTypeFrom + " AND " + jobTypeTo + " AND " + serviceTypeFrom + " AND " + serviceTypeTo + " AND ai.creation_date >= '" + dateFrom +"' AND ai.creation_date <= '" + dateTo + "' GROUP BY ai.id ORDER BY ai.creation_date, luas.value ";								
								}	
							}else{
								//with sales tax state filter
								sqlARInvoices = "SELECT ai.* FROM ar_invoices ai, ar_invoice_details arid, jobs j, lu_job_types lujt, lu_service_types lust, sales_tax st, lu_abreviated_states , sales_tax st WHERE  j.vendor_company_id = "+vendorId+" and ai.id = arid.ar_invoiceid AND arid.jobid = j.id AND j.job_type_id = lujt.id AND j.service_type_id = lust.id AND st.job_id = j.id AND st.entity = luas.id AND ai.bill_to_companyid = " + rsBuyers.getInt("bcomp.id") + " AND " + jobTypeFrom + " AND " + jobTypeTo + " AND " + serviceTypeFrom + " AND " + serviceTypeTo + " AND " + stateTaxFrom +" AND " + stateTaxTo + " AND ai.creation_date >= '" + dateFrom + "' AND ai.creation_date <= '" + dateTo + "' GROUP BY ai.id ORDER BY ai.creation_date " ;
							}
							
							Statement qsARInvoices = conn.createStatement();
							ResultSet rsARInvoices = qsARInvoices.executeQuery(sqlARInvoices);
	
							double bTotalPrice = 0;
							double bTotalShipping = 0;
							double bTotalSalesTax = 0;
							double bTotalDeposit = 0;
							double bTotalTotal = 0;
	
							if(rsARInvoices.next()){
								do{
									bTotalPrice += rsARInvoices.getDouble("ar_purchase_amount");
									bTotalShipping += rsARInvoices.getDouble("ar_shipping_amount"); 
									bTotalSalesTax += rsARInvoices.getDouble("ar_sales_tax");
									bTotalDeposit += rsARInvoices.getDouble("deposited");
									bTotalTotal += rsARInvoices.getDouble("ar_invoice_amount");
									alt=((alt.equals(""))?"alt":"");
									output.append("<tr>");
									output.append("<td class=\"lineitemcenter"+alt+"\" >");
									output.append(rsARInvoices.getString("creation_date"));
									output.append("</td>");
									output.append("<td class=\"lineitemcenter"+alt+"\" >");
									output.append(rsARInvoices.getString("id"));
									output.append("</td>");
									output.append(getBlankCells(3));
									output.append("<td class=\"lineitemright"+alt+"\" >");
									output.append(formater.getCurrency(rsARInvoices.getDouble("ar_purchase_amount")));
									output.append("</td>");
									output.append("<td class=\"lineitemright"+alt+"\" >");
									output.append(formater.getCurrency(rsARInvoices.getDouble("ar_shipping_amount")));
									output.append("</td>");
									output.append("<td class=\"lineitemright"+alt+"\" >");
									output.append(formater.getCurrency(rsARInvoices.getDouble("ar_sales_tax")));
									output.append("</td>");
									output.append("<td class=\"lineitemright"+alt+"\" >");
									output.append(formater.getCurrency(rsARInvoices.getDouble("deposited")));
									output.append("</td>");
									output.append("<td class=\"lineitemright"+alt+"\" >");
									output.append(formater.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")));
									output.append("</td>");
									output.append(getBlankCells(3));
									output.append("</tr>");
					
//Detail Section commented out								
//								String sqlJobInvoice;
//								if(reportType.equals("1")){
//									//site-buyer type
//									sqlJobInvoice = "SELECT j.id 'jobid', lujt.value 'jobtype', lust.value 'servicetype', arid.ar_purchase_amount 'price', arid.ar_shipping_amount 'shipping', arid.ar_sales_tax 'tax', arid.deposited 'deposited', arid.ar_invoice_amount 'total' FROM ar_invoice_details arid, jobs j, lu_job_types lujt, lu_service_types lust WHERE  j.vendor_company_id = "+vendorId+" and j.id = arid.jobid AND j.job_type_id = lujt.id AND j.service_type_id = lust.id AND arid.ar_invoiceid = " + rsARInvoices.getString("id");
//								}else{
//									//by state sales tax type
//									sqlJobInvoice = "SELECT j.id 'jobid', lujt.value 'jobtype', lust.value 'servicetype', arid.ar_purchase_amount 'price', arid.ar_shipping_amount 'shipping', arid.ar_sales_tax 'tax', arid.deposited 'deposited', arid.ar_invoice_amount 'total' FROM ar_invoice_details arid, jobs j, lu_job_types lujt, lu_service_types lust, sales_tax st, lu_abreviated_states luas WHERE  j.vendor_company_id = "+vendorId+" and j.id = arid.jobid AND j.job_type_id = lujt.id AND j.service_type_id = lust.id AND st.job_id = j.id AND st.entity = luas.id AND arid.ar_invoiceid = " + rsARInvoices.getString("id") + " ORDER BY luas.value";
//								}	
//								Statement qsTest = conn.createStatement();
//								ResultSet rsJobInvoices;
//								
//								rsJobInvoices = qsTest.executeQuery(sqlJobInvoice);
//												
//								while(rsJobInvoices.next()){
	
//									output.append("<tr>");
//									output.append(getBlankCells(2));
//									output.append("<td class=\"lineitemcenter"+alt+"\" >");
//									output.append(rsJobInvoices.getString("jobid"));
//									output.append("</td>");
//									output.append("<td class=\"lineitemcenter"+alt+"\" >");
//									output.append(rsJobInvoices.getString("jobtype"));
//									output.append("</td>");
//									output.append("<td class=\"lineitemcenter"+alt+"\" >");
//									output.append(rsJobInvoices.getString("servicetype"));
//									output.append("</td>");
//									output.append("<td class=\"lineitemright"+alt+"\" >");
//									output.append(formater.getCurrency(rsJobInvoices.getDouble("price")));
//									output.append("</td>");
//									output.append("<td class=\"lineitemright"+alt+"\" >");
//									output.append(formater.getCurrency(rsJobInvoices.getDouble("shipping")));
//									output.append("</td>");
//									output.append("<td class=\"lineitemright"+alt+"\" >");
//									output.append(formater.getCurrency(rsJobInvoices.getDouble("tax")));
//									output.append("</td>");
//									output.append("<td class=\"lineitemright"+alt+"\" >");
//									output.append(formater.getCurrency(rsJobInvoices.getDouble("deposited")));
//									output.append("</td>");
//									output.append("<td class=\"lineitemright"+alt+"\" >");
//									output.append(formater.getCurrency(rsJobInvoices.getDouble("total")));
//									output.append("</td>");
//									output.append("<td>&nbsp;</td>");
//
//									String sqlTaxInfo = "SELECT luas.value 'state', if(st.tax_job=1,'Taxable','Non-tax') 'taxstatus' FROM  lu_abreviated_states luas, sales_tax st WHERE st.entity = luas.id AND st.job_id = " + rsJobInvoices.getInt("jobid");
//									Statement psTaxInfo = conn.createStatement();
//									ResultSet rsTaxInfo = psTaxInfo.executeQuery(sqlTaxInfo);
//									
//									if(rsTaxInfo.next()){
//
//										output.append("<td class=\"lineitemcenter"+alt+"\" >");
//										output.append(rsTaxInfo.getString("state"));
//										output.append("</td>");
//										output.append("<td class=\"lineitemcenter"+alt+"\" >");
//										output.append(rsTaxInfo.getString("taxstatus"));
//										output.append("</td>");
//
//									}else{
//	
//										output.append("<td class=\"lineitemleft"+alt+"\" >No Tax Info</td>");
//										output.append("<td class=\"lineitemleft"+alt+"\" >No Tax Info</td>");
//									}  //tax if's
//
//									output.append("</tr>");
//
//								}//Ends while job invoices(details)
		
								output.append(getBlankRow());
			
							}while(rsARInvoices.next());  //ends invoices loop for the buyer
							
							rTotalPrice += bTotalPrice;
							rTotalShipping += bTotalShipping; 
							rTotalSalesTax += bTotalSalesTax;
							rTotalDeposit += bTotalDeposit;
							rTotalTotal += bTotalTotal;	
						}else{							
							output.append("<tr><td colspan=\"13\">No Invoices Found for this buyer.</td></tr>");
						}							
	
						output.append("<tr>");
						output.append("<td class=\"lineitemleft"+alt+"\" >Total</td>");
						output.append(getBlankCells(4));
						output.append("<td class=\"lineitemright"+alt+"\" >");
						output.append( formater.getCurrency(bTotalPrice));
						output.append("</td>");
						output.append("<td class=\"lineitemright"+alt+"\" >");
						output.append(formater.getCurrency(bTotalShipping));
						output.append("</td>");
						output.append("<td class=\"lineitemright"+alt+"\" >");
						output.append(formater.getCurrency(bTotalSalesTax));
						output.append("</td>");
						output.append("<td class=\"lineitemright"+alt+"\" >");
						output.append(formater.getCurrency(bTotalDeposit));
						output.append("</td>");
						output.append("<td class=\"lineitemright"+alt+"\" >");
						output.append(formater.getCurrency(bTotalTotal));
						output.append("</td>");
						output.append(getBlankCells(3));
						output.append("</tr>");
						output.append(getBlankRow());

					}while(rsBuyers.next()); 				//end of loop for buyers
				}else{
					return "No Buyers Found";
				}							   				//if condition for buyers
				
			}while(rsSiteHosts.next());               //the do end loop for site host

			output.append("<tr>");
			output.append(getBlankCells(4));
			output.append("<td class=\"lineitemleft"+alt+"\" >Report Totals:</td>");
			output.append("<td class=\"lineitemright"+alt+"\" >");
			output.append(formater.getCurrency(rTotalPrice));
			output.append("</td>");
			output.append("<td class=\"lineitemright"+alt+"\" >");
			output.append(formater.getCurrency(rTotalShipping));
			output.append("</td>");
			output.append("<td class=\"lineitemright"+alt+"\" >");
			output.append(formater.getCurrency(rTotalSalesTax));
			output.append("</td>");
			output.append("<td class=\"lineitemright"+alt+"\" >");
			output.append(formater.getCurrency(rTotalDeposit));
			output.append("</td>");
			output.append("<td class=\"lineitemright"+alt+"\" >");
			output.append(formater.getCurrency(rTotalTotal));
			output.append("</td>");
			output.append(getBlankCells(3));
			output.append("</tr>");
			output.append("</table>");
	
		}else{
			return "No Site Hosts Found";
		}
		} catch ( Exception e ) {
			throw new SQLException(e.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		return output.toString();	
	
	}		

	protected void finalize() {
		
	}	
}