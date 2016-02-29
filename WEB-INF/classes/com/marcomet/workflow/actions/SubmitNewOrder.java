package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class handles the processing of a new order. 
	If payment type is credit card or ach, check funds availability before creating /order/jobs
		If there is an error bounce back to the order checkout page, 
			else create the order, create the jobs. 
			After each job create the ar_invoice header and detail
			Create the ar_collections header and detail
	If payment type is 'on account' process the order normally
	If payment type is 'prepay by check' process the order but place it on hold (status='On hold')

**********************************************************************/
import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.ResourceBundle;
import java.util.Vector;
import javax.activation.MimetypesFileTypeMap;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.catalog.JobObject;
import com.marcomet.catalog.JobSpecObject;
import com.marcomet.catalog.ProjectObject;
import com.marcomet.catalog.ProxyOrderObject;
import com.marcomet.catalog.ShipmentBoxObject;
import com.marcomet.catalog.ShipmentObject;
import com.marcomet.catalog.ShoppingCart;
import com.marcomet.commonprocesses.ProcessARCollection;
import com.marcomet.commonprocesses.ProcessARCollectionDetail;
import com.marcomet.commonprocesses.ProcessARInvoice;
import com.marcomet.commonprocesses.ProcessARInvoiceDetail;
import com.marcomet.commonprocesses.ProcessJob1;
import com.marcomet.commonprocesses.ProcessJobSpec;
import com.marcomet.commonprocesses.ProcessOrder;
import com.marcomet.commonprocesses.ProcessProject;
import com.marcomet.commonprocesses.ProcessShipment;
import com.marcomet.commonprocesses.ProcessShipmentBox;
import com.marcomet.environment.SiteHostSettings;
import com.marcomet.files.FileManipulator;
import com.marcomet.files.FileMetaDataContainer;
import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.ProcessACHWithVerisignTool;
import com.marcomet.tools.ProcessCreditCardWithVerisignTool;
import com.marcomet.tools.SimpleLookups;
import com.marcomet.tools.StringTool;
import com.marcomet.workflow.actions.ProcessCollectionSubmission;
import com.marcomet.users.admin.UserRegistrationTool;
import com.marcomet.users.security.UserLoginTool;

public class SubmitNewOrder extends HttpServlet implements ActionInterface {

//***** Credit Card System *******
  //VSCCTransaction v = new  VSCCTransaction();
  SimpleLookups slups = new SimpleLookups();
  String ccErrorMessage = "";
  String authCode = "bogus";
  String pnRefId = "bogus";
  String buyerContactId = "";
  String buyerCompanyId = "";
  boolean isNewUser = false;

  private void createOrderEntries(HttpServletRequest request) throws Exception {

    //**********Added for file maintenance stuff********
    FileManipulator fm = new FileManipulator();

    ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
    String transfers = bundle.getString("transfers");
    //String host = bundle.getString("host");
    //**************************************************

    ShoppingCart shoppingCart = (ShoppingCart) request.getSession().getAttribute("shoppingCart");
    int shipLocationId=shoppingCart.getShippingLocationId();
    
    Vector projects = shoppingCart.getProjects();
    ProjectObject tempProject;
    int projectId;
    String taxState;
    Vector tempJobs;
    JobObject tempJob;
    int jobId;
    JobSpecObject tempJobSpec;
    int jobSpecId;
    Vector shipments = shoppingCart.getShipments();
    ShipmentObject tempShipment;
    int shipmentId;
    Vector tempBoxes;
    ShipmentBoxObject tempBox;
    int boxId;
    ProcessCollectionSubmission pcs = new ProcessCollectionSubmission();
    Connection conn = null;
    
    try {
      conn = DBConnect.getConnection();
      //*********************insert new order	****************************
      ProcessOrder po = new ProcessOrder();
      po.setBuyerContactId(buyerContactId);
      po.setBuyerCompanyId(buyerCompanyId);
      String customerPO="";
      if(request.getSession().getAttribute("customerPO")!=null){
    	 customerPO=request.getSession().getAttribute("customerPO").toString(); 
    	 request.getSession().removeAttribute("customerPO");
      }
      po.setCustomerPO(customerPO);
      po.setOrderedById(((request.getSession().getAttribute("proxyId") == null || request.getSession().getAttribute("proxyId").equals("")) ? buyerContactId : request.getSession().getAttribute("proxyId").toString()));
      po.setSiteHostId(((SiteHostSettings) request.getSession().getAttribute("siteHostSettings")).getSiteHostId());
      po.setSiteHostContactId(shoppingCart.getSiteHostContactId());
      po.insert(conn);
      if(request.getSession().getAttribute("subvendorReferenceData")!=null){
    	  request.getSession().removeAttribute("subvendorReferenceData");
      }
      int orderId = po.getId();

      request.setAttribute("orderId", orderId + "");  //set up for emails

      /*****************  Accounting Section *****************************
      java.text.DateFormat mysqlFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
      ProcessARCollection parc = new ProcessARCollection();
      
      if (request.getParameter("pay_type") != null && request.getParameter("pay_type").equals("cc") ) {
        parc.setContactId(buyerContactId);
        parc.setCheckNumber("CreditCard");
        parc.setCheckAmount(request.getParameter("dollarAmount"));
        parc.setCheckReference(pnRefId);
        parc.setCheckAuthCode(authCode);
        parc.setDepositDate(mysqlFormat.format(new java.util.Date()));
        parc.insert(conn);
      }
      ****************** end Accounting section *************************/

      for (int x = 0; x < projects.size(); x++) {
        //get project
        tempProject = (ProjectObject) projects.elementAt(x);
        projectId = tempProject.getId();

        try {
          ProcessProject pp = new ProcessProject();
          pp.setId(projectId);
          //pp.setProjectNumber(tempProject.getProjectNumber());
          pp.setProjectName(tempProject.getProjectName());
          //pp.setProjectTypeId(tempProject.getProjectTypeId());
          //pp.setNotes(tempProject.getNotes());
          //pp.setContactId(buyerContactId);
          //pp.setCompanyId(buyerCompanyId);
          pp.setOrderId(orderId);
          pp.insert(conn);

        }
        catch (SQLException sqle) {
          throw new Exception("ShoppingCart, insertProjectsAndJobs(String id) insertProject (sqle): " + sqle.getMessage());
        }

        //get Jobs
        tempJobs = tempProject.getJobs();

        for (int y = 0; y < tempJobs.size(); y++) {

          //getJob
          tempJob = (JobObject) tempJobs.elementAt(y);
          jobId = tempJob.getId();

          try {
            ProcessJob1 pj = new ProcessJob1();
            pj.setId(jobId);
            pj.setProjectId(projectId);
            pj.setOrderId(orderId);
            pj.setJobTypeId(tempJob.getJobTypeId());

            pj.setJobName(tempJob.getJobName());
            Statement st=conn.createStatement();
            ResultSet rsStats=st.executeQuery("select * from jobflowstates where shownstatus='Hold for Payment' or shownstatus='RFQ'");
            String statRFQ="16";
            String statHold="123";
            String statStr="2";
            while(rsStats.next()){
            	if(rsStats.getString("shownstatus").equals("Hold for Payment")){
            		statHold=rsStats.getString("statusnumber");
            	}else if(rsStats.getString("shownstatus").equals("RFQ")){
            		statRFQ=rsStats.getString("statusnumber");
            	}
            	
            }

            taxState="31";
            rsStats=st.executeQuery("select state from shipping_locations where id="+shoppingCart.getShippingLocationId());
            if(rsStats.next()){
            	taxState=rsStats.getString("state");
            }
            
            if (tempJob.isRFQ()) {
            	pj.setStatusId(statRFQ);
            } else if(request.getParameter("pay_type")!=null && request.getParameter("pay_type").equals("check")){
            	pj.setStatusId(statHold);
            }else {
            	pj.setStatusId(statStr);                				
            }

            pj.setLastStatusId("1");							
            pj.setServiceTypeId(tempJob.getServiceTypeId());
            pj.setDiscount(tempJob.getDiscount());
            pj.setEscrowPercentage(tempJob.getEscrowPercentage());
            pj.setVendorId(tempJob.getVendorId());
            pj.setVendorCompanyId(tempJob.getVendorCompanyId());
            pj.setVendorContactId(tempJob.getVendorContactId());

            pj.setOrderedById(((request.getSession().getAttribute("proxyId") == null || request.getSession().getAttribute("proxyId").equals("")) ? buyerContactId : request.getSession().getAttribute("proxyId").toString()));
            pj.setPromoCode(((tempJob.getPromoCode() == null) ? "" : tempJob.getPromoCode()));
            pj.setSalesContactId(tempJob.getVendorContactId());
            pj.setSalesCompanyId(getCompanyId(tempJob.getVendorContactId()));
            pj.setSubvendorReferenceData(tempJob.getSubvendorReferenceData());
            pj.setMarcometFee(tempJob.getMarcometFee());
            pj.setSiteHostMarkup(tempJob.getSiteHostMarkup());
            if (conn == null) {
              throw new Exception("connection when to null 1");
            }
            pj.setShipmentId(tempJob.getShipmentId());
            pj.setShipLocationId(shipLocationId);
            if(tempJob.getShippingPrice()==0 && tempJob.getShipPricePolicy()==2){
            	pj.setShipPricePolicy(0);
            }else{
            	pj.setShipPricePolicy(((tempJob.getShipPricePolicy()==4)?0:tempJob.getShipPricePolicy()));
            }
            pj.setStdShipPrice(tempJob.getShippingPrice());
            pj.setPercentageOfShipment(tempJob.getPercentageOfShipment());
            pj.insert(conn);
            
            request.getSession().removeAttribute("promoCode");
            //if there was a pdf file resulting from a template creation upload it as a new file and set status on the file to final print
            if (tempJob.getPreBuiltPDFFile() != null && !(tempJob.getPreBuiltPDFFile().equals(""))) {
              File fi = new File(tempJob.getPreBuiltPDFFile());
              File fiJpg = new File(tempJob.getPreBuiltFile());
              File dir = new File(transfers + buyerCompanyId + File.separatorChar);
              if (!dir.isDirectory()) {
                dir.mkdir();
              }
              double fileSize = fi.length();
              fi.renameTo(new File(dir, tempJob.getId() + "final_print.pdf"));
              fiJpg.renameTo(new File(dir, tempJob.getId() + "final_print.jpg"));
              pj.updateJob("thumbnail_file", "/transfers/" + buyerCompanyId + File.separatorChar + File.separatorChar + tempJob.getId() + "final_print.jpg");
              String filePath = transfers + buyerCompanyId + File.separatorChar;
              String fileType = "pdf";
              FileMetaDataContainer container = new FileMetaDataContainer(po.getBuyerContactId(), po.getBuyerCompanyId(), jobId, projectId, tempJob.getId() + "final_print.pdf", fileType, fileSize, filePath, "Pre-approved final print PDF, created by buyer in PDF Editor.", "", "Final", "Print", fm.getNextGroupId(),"1");
              fm.insertMetaData(container, "insert");
            //if there was a pdf file resulting from a template creation upload a proof for this as a new file and set status on the file to Accepted For Appvl
              fi = new File(tempJob.getPreBuiltPDFFile().replace(".pdf","_proof.pdf"));
              fileSize = fi.length();
              fi.renameTo(new File(dir, tempJob.getId() + "final_proof.pdf"));
              FileMetaDataContainer container2 = new FileMetaDataContainer(po.getBuyerContactId(), po.getBuyerCompanyId(), jobId, projectId, tempJob.getId() + "final_proof.pdf", fileType, fileSize, filePath, "Pre-approved final print proof PDF, created by buyer in PDF Editor..", "", "Accepted", "For Appvl", fm.getNextGroupId(),"1");
              fm.insertMetaData(container2, "insert");
            }
            
          }
          catch (SQLException sqle) {
            throw new Exception("ShoppingCart, insertJob job insertion part (sqle): " + sqle.getMessage());
          }

          //if this is a 'prepay by check' order create the AR Invoice record for the job.
          try {
            if (request.getParameter("pay_type") != null && request.getParameter("pay_type").equals("check")) {
              ProcessARInvoice pari = new ProcessARInvoice();
              pari.setDeposited(tempJob.getEscrowDollarAmount());
              pari.setInvoiceAmount(tempJob.getPrice()-tempJob.getDiscount()+tempJob.getShippingPrice()+tempJob.getSalesTax());
              pari.setInvoiceType(1);
              pari.setBillToCompanyId(buyerCompanyId);
              pari.setBillToContactId(buyerContactId);
              pari.setVendorId(tempJob.getVendorId());
              pari.setPurchaseAmount(tempJob.getPrice()-tempJob.getDiscount());
              pari.setSalesTax(tempJob.getSalesTax());
              pari.setShippingAmount(tempJob.getShippingPrice());
              pari.setSalesTaxEntityId(taxState);
              pari.setInvoiceMessage("Prepayment by Check");
              pari.insert(conn);

              ProcessARInvoiceDetail parid = new ProcessARInvoiceDetail();
              parid.setJobId(tempJob.getId());
              parid.setInvoiceId(pari.getId());
              parid.setDeposited(tempJob.getEscrowDollarAmount());
              parid.setInvoiceAmount(tempJob.getPrice()-tempJob.getDiscount()+tempJob.getShippingPrice()+tempJob.getSalesTax());
              parid.setPurchaseAmount(tempJob.getPrice()-tempJob.getDiscount());
              parid.setSalesTax(tempJob.getSalesTax());
              parid.setShippingAmount(tempJob.getShippingPrice());
              parid.insert(conn);

/**              
              ProcessARCollectionDetail parcd = new ProcessARCollectionDetail();
              parcd.setCollectionId(parc.getId());
              parcd.setInvoiceId(pari.getId());
              parcd.setPaymentAmount(tempJob.getEscrowDollarAmount());
              parcd.insert(conn);
            
**/
            }
		

          }
          catch (SQLException sqle) {
            throw new Exception("ShoppingCart, insertJob part part (sqle): " + sqle.getMessage());
          }
//***********************  End Accounting Section ******************************	
//****** Move the files to the real company folder and update metadata *****************

          Vector tempCompanies = null;
          try {
            tempCompanies = (Vector) request.getSession().getAttribute("tempCompanyVector");
          }
          finally {
            if (tempCompanies == null) {
              tempCompanies = new Vector();
            }
          }

//**************  filemetadatatext **********************
          String updateFileMetaDataText =
                 "update file_meta_data set company_id=?, user_id=?, path=? where job_id = ? and project_id = ?";
          PreparedStatement updateFileMetaData = conn.prepareStatement(updateFileMetaDataText);

//***************************************************************		

//hey Tom -----  if newuser
          if (tempCompanies.size() > 0) {
            if (x < tempCompanies.size()) {
              fm.swapCompany(Integer.parseInt((String) tempCompanies.elementAt(x)), Integer.parseInt(buyerCompanyId));

              updateFileMetaData.clearParameters();
              updateFileMetaData.setString(1, buyerCompanyId);
              updateFileMetaData.setString(2, buyerContactId);
              updateFileMetaData.setString(3, transfers + File.separatorChar + buyerCompanyId + File.separatorChar);
              updateFileMetaData.setInt(4, jobId);
              updateFileMetaData.setInt(5, projectId);
              updateFileMetaData.execute();
            }
          }

//**************************************************************************************

          Hashtable tempJobSpecs = tempJob.getJobSpecs();

          Enumeration keys = tempJobSpecs.keys();

          while (keys.hasMoreElements()) {

            //increment to next key
            tempJobSpec = (JobSpecObject) tempJobSpecs.get((String) keys.nextElement());

            ProcessJobSpec pjs = new ProcessJobSpec();
            pjs.setCatSpecId(tempJobSpec.getCatSpecId());
            pjs.setValue(tempJobSpec.getValue());
            //pjs.setValueType(tempJobSpec.getValueType());
            pjs.setJobId(jobId);
            pjs.setCost(tempJobSpec.getCost());
            pjs.setEscrowPercentage(tempJobSpec.getEscrowPercentage());
            pjs.setFee(tempJobSpec.getFee());
            pjs.setMu(tempJobSpec.getMu());
            pjs.setPrice(tempJobSpec.getPrice());
            if (conn == null) {
              throw new Exception("connecion when to null 2");
            }
            pjs.insert(conn);
          }

//************ update job table with sums ***********************
          CalculateJobCosts cjc = new CalculateJobCosts();
          cjc.calculate(jobId);

//************ end of update ************************************			
        }
      }

      //get Shipments
      for (int i = 0; i < shipments.size(); i++) {
        tempShipment = (ShipmentObject) shipments.elementAt(i);
        shipmentId = tempShipment.getId();

        try {
          ProcessShipment ps = new ProcessShipment();
          ps.setId(shipmentId);
          
          ps.setNoOfBoxes(tempShipment.getShipmentBoxes().size());
          ps.setOrderId(orderId);
          //ps.setProjectId(projectId);
          ps.setShipmentPrice(tempShipment.getShippingPrice());
          ps.setShipmentWeight(tempShipment.getWeight());
          
          ps.setCalculatedPrice(tempShipment.getCalculatedShipPrice());
          ps.setCalculatedPriceFull(tempShipment.getCalculatedShipPriceFull());
          ps.setCalculatedPriceDisc(tempShipment.getCalculatedShipPriceDisc());
          ps.setNotes(tempShipment.getShipmentNotes());
          ps.setSVFee(tempShipment.getSVFee());
          ps.setMCFee(tempShipment.getMCFee());
          ps.insert(conn);
        }
        catch (SQLException sqle) {
          throw new Exception("ShoppingCart, insertShipments&Boxes insertShipment (sqle): " + sqle.getMessage());
        }

        //get Shipment Boxes
        tempBoxes = tempShipment.getShipmentBoxes();
        for (int j = 0; j < tempBoxes.size(); j++) {
          tempBox = (ShipmentBoxObject) tempBoxes.elementAt(j);
          boxId = tempBox.getId();

          try {
            ProcessShipmentBox psb = new ProcessShipmentBox();
            psb.setId(boxId);
            psb.setShipmentId(shipmentId);
            psb.setBoxNumber(tempBox.getBoxNumber());
            psb.setBoxWeight(tempBox.getWeight());
            psb.setBoxHeight(tempBox.getHeight());
            psb.setBoxLength(tempBox.getLength());
            psb.setBoxDepth(tempBox.getWidth());
            psb.setBoxContents(tempBox.getContents());
            psb.insert(conn);
          }
          catch (SQLException sqle) {
            throw new Exception("ShoppingCart, insertBox (sqle): " + sqle.getMessage());
          }
        }
      }

      request.getSession().removeAttribute("tempCompanyVector");
    }
    finally {
      try {
        conn.close();
      }
      catch (Exception x) {
        conn = null;
      }
    }
  }

  public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {

    if (1 == 1) {
      throw new Exception("No file uploads on check, please!");
    }
    return new Hashtable();
  }

  public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

    processCheckOut(request, response);
    return new Hashtable();
  }
  //from contact id

  private int getCompanyId(int id) throws SQLException {

    Connection conn = null;

    try {
      conn = DBConnect.getConnection();
      Statement qs1 = conn.createStatement();
      ResultSet rs1 = qs1.executeQuery("SELECT c.companyid FROM contacts c WHERE c.id = " + id);
      if (rs1.next()) {
        return rs1.getInt("companyid");
      }
      else {
        throw new SQLException("no company id returned from contacts table, contact id: " + id);
      }
    }
    catch (Exception x) {
      throw new SQLException(x.getMessage());
    }
    finally {
      try {
        conn.close();
      }
      catch (Exception x) {
        conn = null;
      }
    }

  }
  //****** Supporting functions ***********

  private int getVendorCompanyId(String id) throws SQLException {

    Connection conn = null;

    try {
      conn = DBConnect.getConnection();
      Statement qs1 = conn.createStatement();
      ResultSet rs1 = qs1.executeQuery("SELECT v.company_id FROM vendors v WHERE v.id = " + id);
      if (rs1.next()) {
        return rs1.getInt("companyid");
      }
      else {
        throw new SQLException("no company id returned from vendors table");
      }
    }
    catch (Exception x) {
      throw new SQLException(x.getMessage());
    }
    finally {
      try {
        conn.close();
      }
      catch (Exception x) {
        conn = null;
      }
    }
  }

  private void processCheckOut(HttpServletRequest request, HttpServletResponse response) throws Exception {

	  //if there was a prior authorization request that hadn't been cleared, remove the reference id
      if(request.getSession().getAttribute("lastCCRef")!=null){request.getSession().removeAttribute("lastCCRef");}

      //Process The Credit Card if site host is set to accept credit cards,
		String pastACRef=((request.getParameter("pastACref")==null || request.getParameter("pastACref").equals("") || request.getParameter("pastACref").equals("NEW"))?"":request.getParameter("pastACref"));
		//System.out.println("pastACRef is "+pastACRef);
    if (request.getParameter("pay_type") != null && (request.getParameter("pay_type").equals("cc") || (pastACRef.equals("") && request.getParameter("pay_type").equals("ach")))) {
      Hashtable returnResult = processOrder(request);

      //check to see if the process was valid/completed
      if (((Boolean) returnResult.get("processed")).booleanValue()) {
        authCode = (String) returnResult.get("authCode");
        pnRefId = (String) returnResult.get("pnRefId");
        if(request.getParameter("pay_type").equals("cc")){request.getSession().setAttribute("lastCCRef", pnRefId);}
      }
      else {
        request.setAttribute("errorMessage", (String) returnResult.get("ccErrorMessage"));
        throw new ActionException();
      }
    }

    Connection conn = null;

    try {
      conn = DBConnect.getConnection();
      UserRegistrationTool urt = new UserRegistrationTool();


      if (request.getSession().getAttribute("contactId") == null) {
        isNewUser = true;									//for file swapping

        //Register user
        Hashtable results = new Hashtable();
        urt.addNewUserInformation(request, response, results);

        //if an error message is return, then stop further action and throw new Exception
        if (!((String) results.get("errorMessage")).equals("")) {
          request.setAttribute("errorMessage", (String) results.get("errorMessage"));
          throw new ActionException();
        }

        buyerCompanyId = (String) results.get("companyId");
        buyerContactId = (String) results.get("contactId");

        //login user
        UserLoginTool ult = new UserLoginTool();
        ult.logUserIntoSystem(request, response, Integer.parseInt(buyerContactId));
      }
      else {
        //should be available
        try {
          ProxyOrderObject poo = (ProxyOrderObject) request.getSession().getAttribute("ProxyOrderObject");
          buyerContactId = new Integer(poo.getProxyContactId()).toString();
          System.out.println("buyerContactId is "+buyerContactId);
          buyerCompanyId = new Integer(poo.getProxyCompanyId()).toString();
          System.out.println("buyerCompanyId is "+buyerCompanyId);
        }
        catch (Exception ex) {
          buyerContactId = (String) request.getSession().getAttribute("contactId");
          buyerCompanyId = request.getParameter("companyId");
        }

        Hashtable results = new Hashtable();

        urt.updateUserInformation(request, results);

        request.setAttribute("errorMessage", (String) results.get("errorMessage"));

      }

      createOrderEntries(request);

      request.getSession().removeAttribute("shoppingCart");
    }
    finally {
      try {
        conn.close();
      }
      catch (Exception x) {
        conn = null;
      }
    }
  }

  private Hashtable processOrder(HttpServletRequest request) {
	  
		StringTool st = new StringTool();
		Hashtable returnResults = new Hashtable();
		String orderId="";
		//if this is being called from an order process get the orderid
		if(request.getParameter("jobId")==null){
			Statement qs = null;
			Connection conn = null; 

			try {			
				conn = DBConnect.getConnection();
				qs = conn.createStatement();
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from orders;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				orderId=rs1.getString(1);
			} catch (Exception x) {
				try {
					throw new SQLException(x.getMessage());
				} catch (SQLException e) {
					e.printStackTrace();
				}
			} finally {
				try { conn.close(); } catch ( Exception x) { conn = null; }
			}
		}
		String payType=((request.getParameter("pay_type")==null || request.getParameter("pay_type").equals(""))?"cc":request.getParameter("pay_type"));
		String pastACRef=((request.getParameter("pastACref")==null || request.getParameter("pastACref").equals("") || request.getParameter("pastACref").equals("NEW"))?"":request.getParameter("pastACref"));
		if(payType.equals("cc")){
			String ccnumber = st.replaceSubstring(request.getParameter("ccNumber")," ","");
			ccnumber = st.replaceSubstring(ccnumber,"-","");
			
			//send info to Verisign-Marcomet tool
			ProcessCreditCardWithVerisignTool vProcess = new ProcessCreditCardWithVerisignTool();		
			vProcess.setOrderId(orderId);
			String trType="A";
			returnResults= vProcess.processTransaction(ccnumber, request.getParameter("ccMonth")+request.getParameter("ccYear"), request.getParameter("dollarAmount"),trType,request);					
		} else if(payType.equals("ach") && pastACRef.equals("")){
		    String accountNumber=((request.getParameter("accountNumber")==null)?"":request.getParameter("accountNumber"));
		    accountNumber  = st.replaceSubstring(accountNumber," ","");
		    accountNumber = st.replaceSubstring(accountNumber,"-","");
			
			String acctType=request.getParameter("acct_type");
			String firstName=((request.getParameter("accountName")==null)?"":request.getParameter("accountName"));
		    String bankName=((request.getParameter("bankName")==null)?"":request.getParameter("bankName"));
		    String aba=((request.getParameter("routingNumber")==null)?"":request.getParameter("routingNumber"));
		    String bankCity=((request.getParameter("bankCity")==null)?"":request.getParameter("bankCity"));
		    String bankState=((request.getParameter("bankState")==null)?"":request.getParameter("bankState"));
			
			
			//send info to Verisign-Marcomet tool
			ProcessACHWithVerisignTool vProcess = new ProcessACHWithVerisignTool();
	
			vProcess.setOrderId(orderId);
			String trType="S";
			String preNote="Y";
			returnResults= vProcess.processTransaction(preNote, firstName, aba, accountNumber,  acctType,  bankName, bankCity, bankState, "0",  trType,  request);			
		}
		return returnResults;
  }
}