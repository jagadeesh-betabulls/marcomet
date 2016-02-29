package com.marcomet.catalog;

/**********************************************************************
Description:	This servlet determines whether to go into another job
				or redirect to the OrderSummary
	
**********************************************************************/

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.marcomet.jdbc.*;
import com.marcomet.environment.SiteHostSettings;

public class CatalogFlowServlet extends HttpServlet {


	private int siteHostId, offeringId, vendorId, catJobId;

	public String checkSequenceDrivers(HttpServletRequest request, ProjectObject po) throws ServletException {

		// Rewrite this to better leverage the specCount value.  The amount of calculations would be greatly reduced.  8/16

		String nextPage = "";

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			boolean continueFlag = false;
			int jobTypeId = 0; int serviceTypeId = 0;
			int tempJobTypeId = 0; int tempServiceTypeId = 0;
			String query0 = "SELECT job_type_id, service_type_id, spec_id, spec_value_id, offering_sequence_id FROM offerings o, offering_sequences os, offering_sequence_drivers osd WHERE o.id = os.offering_id AND os.id = osd.offering_sequence_id AND sequence = " + po.getProjectSequence().intValue() + " AND o.id = " + offeringId + " ORDER BY offering_sequence_id";
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);
			if (rs0.next()) {
//System.err.println("==============================================================================");
//System.err.println(query0);
				Vector jobs = (Vector)po.getJobs();
				// Build a hashtable to search through
				Hashtable searchTable = new Hashtable();
				for (Enumeration e0 = jobs.elements(); e0.hasMoreElements(); ) {
					JobObject jo = (JobObject)e0.nextElement();
					Hashtable jobSpecs = jo.getJobSpecs();
					for (Enumeration e1 = jobSpecs.keys(); e1.hasMoreElements(); ) {
						String key = (String)e1.nextElement();
						JobSpecObject jso = (JobSpecObject)jobSpecs.get(key);
						String specValue = jso.getValue();
						searchTable.put(key, specValue);
					}
				}

				// Now use the searchTable as a guide to examine the result set
				String lastOfferingSequenceId = "";
				Hashtable offeringSequenceIds = new Hashtable();
//int counter = 0;
				do {
//counter++;
//System.err.println("---------------------------------Next row (" + counter + ") -------------------------------------");
					String offeringSequenceId = rs0.getString("offering_sequence_id");
					Hashtable tempEvaluatedSpecs = (Hashtable)offeringSequenceIds.get(offeringSequenceId);
					if (tempEvaluatedSpecs == null) {

						boolean tmpContinueFlag = this.foundNextOffering(lastOfferingSequenceId, offeringSequenceIds);
						if (tmpContinueFlag == true) {
							serviceTypeId = tempServiceTypeId;
							jobTypeId = tempJobTypeId;
							continueFlag = true;
//System.err.println("Breaking............");
							break;
						}
	
						// We haven't found the correct offering_sequence id, so press on
						tempEvaluatedSpecs = new Hashtable();
						offeringSequenceIds.put(offeringSequenceId, tempEvaluatedSpecs);
					}
//System.err.println("Offering Sequence Ids Size " + offeringSequenceIds.size());
					Object o = tempEvaluatedSpecs.get(rs0.getString("spec_id"));
					if (o == null) {
						// This is the first time evaluating this particular spec, so create it and then evaluate it
						String tempValue = (String)searchTable.get(rs0.getString("spec_id"));
						if ( (tempValue.equals(rs0.getString("spec_value_id"))) && (!tempValue.equals("") || tempValue != null) ) {
							tempEvaluatedSpecs.put(rs0.getString("spec_id"), new Boolean(true));
//System.err.println("put 1");
							tempJobTypeId = rs0.getInt("job_type_id");
							tempServiceTypeId = rs0.getInt("service_type_id");
						} else {
//System.err.println("5");
							tempEvaluatedSpecs.put(rs0.getString("spec_id"), new Boolean(false));
//System.err.println("put 2");
						}
//System.err.println("New Spec, Id: " + rs0.getString("spec_id") + " Spec Value " + rs0.getString("spec_value_id") + " tempValue " + tempValue);
					} else {
						boolean evaluatedSpec = ((Boolean)o).booleanValue();
						if (evaluatedSpec == false) {
							// This spec_id has been visited already but has not been satisfied
							String tempValue = (String)searchTable.get(rs0.getString("spec_id"));
							if ((tempValue != null || !tempValue.equals("")) && (tempValue.equals(rs0.getString("spec_value_id")))) {
								tempEvaluatedSpecs.put(rs0.getString("spec_id"), new Boolean(true));
								tempJobTypeId = rs0.getInt("job_type_id");
								tempServiceTypeId = rs0.getInt("service_type_id");
//System.err.println("put 3");
							}
//System.err.println("Old Spec, Id: " + rs0.getString("spec_id") + " Spec Value " + rs0.getString("spec_value_id") + " tempValue " + tempValue);
						} else {
//System.err.println("Missing condition....");
						}
					}

					lastOfferingSequenceId = offeringSequenceId;

				} while (rs0.next());

				// Check the last offering sequence id processed
				boolean tmpContinueFlag = this.foundNextOffering(lastOfferingSequenceId, offeringSequenceIds);
				if (tmpContinueFlag == true) {
					serviceTypeId = tempServiceTypeId;
					jobTypeId = tempJobTypeId;
					continueFlag = true;
				}

				int specCount = 0;
				String query1 = "SELECT count(distinct spec_id) as spec_count FROM offerings o, offering_sequences os, offering_sequence_drivers osd WHERE o.id = os.offering_id AND os.id = osd.offering_sequence_id AND sequence = " + po.getProjectSequence().intValue() + " AND o.id = " + offeringId;
				Statement st1 = conn.createStatement();
				ResultSet rs1 = st1.executeQuery(query1);
				if (rs1.next()) {
					specCount = rs1.getInt("spec_count");
				}
//System.err.println(specCount +"--"+ tempJobTypeId +"--"+ tempServiceTypeId);
				if (specCount == 1 && tempJobTypeId !=0 && tempServiceTypeId !=0) {
					serviceTypeId = tempServiceTypeId;
					jobTypeId = tempJobTypeId;
					continueFlag = true;
				}

				if (continueFlag == true) {
					nextPage = "/servlet/com.marcomet.catalog.CatalogNavigationServlet?oferringId=" + offeringId + "&jobTypeId=" + jobTypeId + "&serviceTypeId=" + serviceTypeId + "&currentCatalogPage=0&newJob=true";
				} else {
					this.populateShoppingCart(request, po);
					nextPage = "/catalog/summary/OrderSummary.jsp";
				}

			} else {
				String query1 = "SELECT job_type_id, service_type_id FROM offerings o, offering_sequences os WHERE o.id = os.offering_id AND sequence = " + po.getProjectSequence().intValue() + " AND o.id = " + offeringId;
				Statement st1 = conn.createStatement();
				ResultSet rs1 = st1.executeQuery(query1);
				if (rs1.next()) {
					jobTypeId = rs1.getInt("job_type_id");
					serviceTypeId = rs1.getInt("service_type_id");
					nextPage = "/servlet/com.marcomet.catalog.CatalogNavigationServlet?oferringId=" + offeringId + "&jobTypeId=" + jobTypeId + "&serviceTypeId=" + serviceTypeId + "&currentCatalogPage=0&newJob=true";
				}
			}
//System.err.println(nextPage);
		} catch(Exception ex) {
			throw new ServletException("checkSequenceDrivers Error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return nextPage;

	}
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		try {
			this.processRequest(request, response);
		} catch (ServletException ex) {
			throw new ServletException("CatalogFlowServlet Error: " + ex.getMessage());
		}
	}
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		try {
			this.processRequest(request, response);
		} catch (ServletException ex) {
			throw new ServletException("CatalogFlowServlet Error: " + ex.getMessage());
		}
	}
	public boolean foundNextOffering(String lastOfferingSequenceId, Hashtable offeringSequenceIds) {

		Vector booleanResults = new Vector();

		// Before looping through a new offering_sequence ids, check to see if the last offering_sequence's
		// specs evaluated was evaluated to true
		Hashtable lastSpecs = (Hashtable)offeringSequenceIds.get(lastOfferingSequenceId);
		if (lastSpecs != null) {
			boolean tmpContinueFlag = false;
			for (Enumeration e = lastSpecs.keys(); e.hasMoreElements(); ) {
				String key = (String)e.nextElement();
				boolean result = ((Boolean)lastSpecs.get(key)).booleanValue();
//System.err.println("key " + key + " result " + result);
				if (result == true) {
					tmpContinueFlag = true;
				} else {
					tmpContinueFlag = false;
				}
				booleanResults.addElement(new Boolean(tmpContinueFlag));
//System.err.println("tmpContinueFlag " + tmpContinueFlag);
			}
			// Check to see if we've found the correct offering_sequence_id
		}
		
		boolean result = true;
//System.err.println("Vector size " + booleanResults.size());
		if (booleanResults.size() > 0) {
			for (int i=0; i<booleanResults.size(); i++) {
			//for (Enumeration e = booleanResults.elements(); e.hasMoreElements(); ) {
//System.err.println( ((Boolean)booleanResults.elementAt(i)).booleanValue() );
				result = ( result && ((Boolean)booleanResults.elementAt(i)).booleanValue() );
			}
		} else {
			result = false;
		}
//System.err.println("Returning foundNextOffering result " + result);
		return result;

	}
	public void populateShoppingCart(HttpServletRequest request, ProjectObject po) throws ServletException {
		// There are no more jobs.  Throw the project into the ShoppingCart and set the redirect page to OrderSummary.jsp
		try {
			if((request.getParameter("selfDesigned")!=null && request.getParameter("selfDesigned").equals("true")) || (request.getSession().getAttribute("selfDesigned")!=null && request.getSession().getAttribute("selfDesigned").toString().equals("true"))){
				ShoppingCart shoppingCart = (ShoppingCart) request.getSession().getAttribute("DIYshoppingCart");
				shoppingCart.addProject(po);			
			}else{
				ShoppingCart shoppingCart = (ShoppingCart) request.getSession().getAttribute("shoppingCart");
				shoppingCart.addProject(po);
			}
		} catch(Exception ex) {
			throw new ServletException("populateShoppingCart error: " + ex.getMessage());
		}
	}
	
	public void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			offeringId = Integer.parseInt((String)request.getParameter("offeringId"));
			siteHostId = Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId());

			ProjectObject po = (ProjectObject)request.getSession().getAttribute("currentProject");
			Integer sequence = po.getProjectSequence();

			// Query to see if there are more jobs for this project according to offering_sequences
			String nextPage = "";
			String query0 = "";
			query0 = "SELECT job_type_id, service_type_id, os.sequence FROM offering_sequences os, offerings o, site_host_offerings sho WHERE o.id = os.offering_id AND sho.id = " + siteHostId + " AND o.id = " + offeringId + " AND os.sequence = 1 + " + sequence.intValue();
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);
			if (rs0.next()) {
				// Yes, there are more jobs. Increment the sequence and check the sequence_drivers to see how to proceed
				po.setProjectSequence(sequence.intValue() + 1);
				nextPage = this.checkSequenceDrivers(request, po);
			} else {
				this.populateShoppingCart(request, po);
				nextPage = "/catalog/summary/OrderSummary.jsp";
			}

			RequestDispatcher rd = getServletContext().getRequestDispatcher(nextPage);
			rd.forward(request, response);

		} catch (Exception ex) {
			throw new ServletException("processRequest Error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	} // processRequest
}
