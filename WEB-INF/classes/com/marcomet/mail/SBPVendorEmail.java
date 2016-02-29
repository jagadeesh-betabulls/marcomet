package com.marcomet.mail;

/************************************
purpose builds invoice
might be temp class
thomas dietrich
***************************************/

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;

import java.sql.*;
import java.text.*;
import java.util.Hashtable;

public class SBPVendorEmail {

	
	Connection conn = null;

	SimpleLookups slups;
	
	PreparedStatement selectContact;
	PreparedStatement selectCompany;
	PreparedStatement selectMailLocation;
	PreparedStatement selectBillLocation;
	PreparedStatement selectPhones;
	PreparedStatement selectOrder;
	PreparedStatement selectProjects;
	PreparedStatement selectJobs;
	PreparedStatement selectCreativeJobSpecs;
	PreparedStatement selectCostJobSpecs;
	PreparedStatement selectState;
	PreparedStatement selectOrderDetails;

	String customerBody = "";
	String orderBody = "";
	String projectJobBody = "";	
	String ccInfoBody ="";
	

	private final String selectContactText =
		"SELECT * FROM contacts WHERE id = ?";
	private final String selectCompanyText =
		"SELECT a.* FROM companies a,contacts b WHERE a.id = b.companyid AND b.id = ?;";
	private final String selectLocationText =
		"SELECT * FROM locations WHERE  contactid = ? AND locationtypeid = ?";
	private final String selectPhonesText =
		"SELECT * FROM phones WHERE contactid = ?";	
	private final String selectOrderText = 
		"SELECT *, right(left(date_created,8),2) \"day\", right(left(date_created,6),2) \"month\", left(date_created,4) \"year\"  FROM orders WHERE id = ?";
	private final String selectProjectsText = 
		"SELECT * FROM projects WHERE order_id = ?";	
	private final String selectJobsText =
		"SELECT * FROM jobs WHERE project_id = ?";	
	private final String selectCreativeJobSpecsText =
		"SELECT l.value as label, js.value as value FROM job_specs js, lu_specs l WHERE js.cat_spec_id = l.id AND js.job_id = ?";
	private final String selectCostJobSpecsText =
		"SELECT ls.value 'specname', js.value 'specvalue', js.cost 'cost', js.fee 'fee', js.mu 'mu', js.price 'price' FROM job_specs js, lu_specs ls WHERE js.price != 0 and js.cat_spec_id = ls.id and js.job_id = ? ORDER BY js.price ASC";
	private final String selectStateText =
		"SELECT state_abreviation from lu_states where state_number = ?";
	private final String selectOrderDetailsText = 
		"select jobs.id as jobId, projects.id as projectId, service_type_id, job_type_id from jobs, projects, orders where jobs.project_id = projects.id and projects.order_id = orders.id and orders.id = ?";
		

	public SBPVendorEmail(){
	}
	public void buildCustomerInfoSection(int id)
	throws Exception
	{
		try
		{
			selectContact = conn.prepareStatement(selectContactText);
			selectCompany = conn.prepareStatement(selectCompanyText);
			selectBillLocation = conn.prepareStatement(selectLocationText);
			selectMailLocation = conn.prepareStatement(selectLocationText);
			selectPhones = conn.prepareStatement(selectPhonesText);
			selectState = conn.prepareStatement(selectStateText);

			selectContact.clearParameters();
			selectContact.setInt(1,id);
			ResultSet rsContact = selectContact.executeQuery();	


			selectCompany.clearParameters();
			selectCompany.setInt(1,id);
			ResultSet rsCompany = selectCompany.executeQuery();		

			selectBillLocation.clearParameters();
			selectBillLocation.setInt(1,id);
			selectBillLocation.setInt(2,2);
			ResultSet rsBillLocation = selectBillLocation.executeQuery();
			
			selectMailLocation.clearParameters();
			selectMailLocation.setInt(1,id);
			selectMailLocation.setInt(2,1);
			ResultSet rsMailLocation = selectMailLocation.executeQuery();					

			selectPhones.clearParameters();
			selectPhones.setInt(1,id);
			ResultSet rsPhones = selectPhones.executeQuery();

			if(rsContact.next())
			{
				if(rsCompany.next()){
					customerBody += "\n\nCustomer:\t\t\t\t" + rsCompany.getString("company_name");
					customerBody += "\n\n\tName:\t\t\t" + rsContact.getString("firstname") + " " + rsContact.getString("lastname");			
					customerBody += "\n\tEmail:\t\t\t" + rsContact.getString("email");
				}else{
					customerBody += "\n\nNo Company Info?";
				}
				
				if(rsBillLocation.next()){

					selectState.clearParameters();
					selectState.setInt(1, rsBillLocation.getInt("state"));
					ResultSet rsState = selectState.executeQuery();
					rsState.next();
				
					customerBody += "\n\tAddress1:\t\t" + rsBillLocation.getString("address1");
					customerBody += "\n\tAddress2:\t\t" + rsBillLocation.getString("address2");
					customerBody += "\n\tCity:\t\t\t" + rsBillLocation.getString("city");
					customerBody += "\n\tState:\t\t\t" + rsState.getString("state_abreviation");
					customerBody += "\n\tZipcode:\t\t" + rsBillLocation.getString("zip");
				}else{
					customerBody += "no billing address";
				}
			
				customerBody += "\n\n\tPhones:";
				while(rsPhones.next()){		
					customerBody += "\n\t" + slups.getValue("lu_phone_types","id",rsPhones.getString("phonetype"),"value")+ ":\t";
					customerBody += "(" + rsPhones.getString("areacode") + ") ";
					customerBody += rsPhones.getString("phone1") + "-" + rsPhones.getString("phone2");
					customerBody += " Ext: " + rsPhones.getString("extension");
				}
				
				if (rsMailLocation.next()) {
					customerBody += "\n\nShip To:\t\t\t\t" + rsCompany.getString("company_name");
					customerBody += "\n\n\tEmail:\t\t\t" + rsContact.getString("email");
					customerBody += "\n\tAddress1:\t\t" + rsMailLocation.getString("address1");
					customerBody += "\n\tAddress2:\t\t" + rsMailLocation.getString("address2");
					customerBody += "\n\tCity:\t\t\t" + rsMailLocation.getString("city");
					customerBody += "\n\tState:\t\t\t" + slups.getValue("lu_abreviated_states","id",rsMailLocation.getString("state"),"value");
					customerBody += "\n\tZipcode:\t\t" + rsMailLocation.getString("zip");
				}else {
					customerBody += "\n\nNo seperate Mailing Addresss|" + id;
				}
				
				customerBody += "\n_______________________________________________________";

			}else{
				throw new Exception("info not found: " + id );
			}
		} catch (SQLException sqle)
		{
			throw new Exception("sbpvendoremail, contact info sqle: " + sqle.getMessage());	
		}	

	}
	public String buildOrderEmail(int intOrderId) throws Exception{
		
		conn = DBConnect.getConnection();
		slups = new SimpleLookups();
		
		try {
			selectOrder = conn.prepareStatement(selectOrderText);
		
			selectOrder.setInt(1,intOrderId);
			ResultSet rsOrder = selectOrder.executeQuery();
			
			if (rsOrder.next()) {
				orderBody += "_______________________________________________________________";
				orderBody += "\nOrder:\t\t\t#" + intOrderId;
				orderBody += "\nDate:\t\t\t" + rsOrder.getString("month") + "/" + rsOrder.getString("day") + "/" + rsOrder.getString("year") + "\n";
				
				//load up cc info for the end of the order
				/* NOTE: commented out since time spent on fixing this section is better spent on later replacing this whole class, td*/
				//ccInfoBody += "\n\n\tPayment Method:\t" + slups.getValue(rsOrder.getInt("cc_type_id"));
				//ccInfoBody += "\n\tReference #:\t" + rsOrder.getString("cc_pn_ref_id"); 
				//ccInfoBody += "\n\tApproval Code:\t"+ rsOrder.getString("cc_auth_code");
				
				buildCustomerInfoSection(rsOrder.getInt("buyer_contact_id"));	
				buildProjectJobInfoSection(rsOrder.getInt("id"));
						
			}		

		}catch(SQLException sqle) {
			throw new Exception("sbpvendormail, order info: " + sqle.getMessage());
		}finally{
			try{
				conn.close();
			}catch(Exception e){
			}finally{				
				conn = null;
			}	
		}		
			
		return orderBody + customerBody + projectJobBody + ccInfoBody;
	}
	public void buildProjectJobInfoSection(int intOrderId) 
	throws Exception{
		DecimalFormat df = new DecimalFormat("0.00");  //format the dollars
	
		ResultSet rsOrderTotal;
		ResultSet rsProjects;
		ResultSet rsProjectTotals;
		ResultSet rsJobs;
		ResultSet rsCreativeJobSpecs;
		ResultSet rsCostJobSpecs;
		ResultSet rsOrder;

		try {
			selectProjects = conn.prepareStatement(selectProjectsText);
			selectJobs = conn.prepareStatement(selectJobsText);
			selectCreativeJobSpecs = conn.prepareStatement(selectCreativeJobSpecsText);
			selectCostJobSpecs = conn.prepareStatement(selectCostJobSpecsText);
			selectOrder = conn.prepareStatement(selectOrderText);
			
			//get all projects associated with this order id;
			selectProjects.clearParameters();
			selectProjects.setInt(1,intOrderId);
			rsProjects = selectProjects.executeQuery();
		
		    projectJobBody += "\nProject/Job Information:";
			
			double totalCost = 0;
			double totalMu = 0;
			double totalFee = 0;
			double totalPrice = 0;
			double orderTotal = 0;
			
			Hashtable projectTotals = new Hashtable();
			
			//loop through projects
			while(rsProjects.next()){
			
				totalCost = 0;
				totalMu = 0;
				totalFee = 0;
				totalPrice = 0;

				projectJobBody += "\nProjectId:\t\t\t" + rsProjects.getString("id");
				//projectJobBody += "\nProjectType:\t\t\t" + slups.getValue(rsProjects.getInt("project_type"));
				
				//loop through jobs
				selectJobs.clearParameters();	
				selectJobs.setInt(1,rsProjects.getInt("id"));
				rsJobs = selectJobs.executeQuery();

				while(rsJobs.next()){
				
					projectJobBody += "\n\nJobId:\t\t\t\t" + rsJobs.getString("id");
					projectJobBody += "\nService type:\t\t\t" + slups.getValue("lu_job_types","id",rsJobs.getString("service_type_id"),"value");
					projectJobBody += "\n\nProject/Job Specs:\n";
					
					selectCreativeJobSpecs.clearParameters();
					selectCreativeJobSpecs.setInt(1,rsJobs.getInt("id"));		
					rsCreativeJobSpecs = selectCreativeJobSpecs.executeQuery();
					
					while(rsCreativeJobSpecs.next()){
						projectJobBody += "\n\t" + rsCreativeJobSpecs.getString("label");
						projectJobBody += "\t\t\t" + rsCreativeJobSpecs.getString("value");
				   	}
					
				   	selectCostJobSpecs.clearParameters();
				   	selectCostJobSpecs.setInt(1,rsJobs.getInt("id"));		
				   	rsCostJobSpecs = selectCostJobSpecs.executeQuery();
				   	
					while(rsCostJobSpecs.next()){
				   		projectJobBody += "\n\t" + rsCostJobSpecs.getString("specname");

				   		projectJobBody += "\tcost: \t" + rsCostJobSpecs.getString("cost");
						totalCost = totalCost + Double.parseDouble(rsCostJobSpecs.getString("cost"));

				   		projectJobBody += "\tmu:   \t" + rsCostJobSpecs.getString("mu");
						totalMu = totalMu + Double.parseDouble(rsCostJobSpecs.getString("mu"));

				   		projectJobBody += "\tfee:  \t" + rsCostJobSpecs.getString("fee");
						totalFee = totalFee + Double.parseDouble(rsCostJobSpecs.getString("fee"));

				   		projectJobBody += "\tprice:\t" + rsCostJobSpecs.getString("price");
						totalPrice = totalPrice + Double.parseDouble(rsCostJobSpecs.getString("price"));
						
						orderTotal = orderTotal + totalPrice;
						projectTotals.put(rsJobs.getString("id"), new Double(totalPrice));		
				   	}
					
	
			  	}
				projectJobBody += "\n\nProject/Jobs Totals:\n";
				projectJobBody += "\n\tEstCost:\t\t\t\t$" + df.format(totalCost);
				projectJobBody += "\n\tReseller Markup: \t\t\t$" + df.format(totalMu);
				projectJobBody += "\n\t--------------------------------------------------------------";
				projectJobBody += "\n\tSubTotal:\t\t\t\t$" + df.format(totalCost + totalMu);
				projectJobBody += "\n\tMarComet Fee:\t\t\t$" + df.format(totalFee);
				projectJobBody += "\n\t--------------------------------------------------------------";
				projectJobBody += "\n\tTotal Price:\t\t\t$" + df.format(totalPrice);
				projectJobBody += "\n______________________________________________________________________\n";

			}	


			selectOrderDetails = conn.prepareStatement(selectOrderDetailsText);
			selectOrderDetails.clearParameters();
			selectOrderDetails.setInt(1,intOrderId);		
			ResultSet rsOrderDetails = selectOrderDetails.executeQuery();
			
			projectJobBody += "\n\nOrder Summary:";
			while(rsOrderDetails.next()){             //print a summary of each project
				String tempProjectTotal = (projectTotals.get(rsOrderDetails.getString("jobId"))==null)?"0":df.format(projectTotals.get(rsOrderDetails.getString("jobId")));
				projectJobBody += "\n\n\tProject: " + rsOrderDetails.getString("projectId") + "\t" + tempProjectTotal + "\t" + slups.getValue("lu_job_types","id",rsOrderDetails.getString("job_type_id"),"value") + "\t" + slups.getValue("lu_service_types","id",rsOrderDetails.getString("service_type_id"),"value");
			}
			projectJobBody += "\n\t--------------------------------------------------------------";
			projectJobBody += "\n\tOrder Total:\t$" + df.format(orderTotal);

		}catch(SQLException sqle) {
			throw new Exception("sbpvendormail, projectjob section sqle: " + sqle.getMessage());		
		}catch(Exception e){
			throw new Exception("Error Message: e: " + e.getMessage());
		}
	}
}
