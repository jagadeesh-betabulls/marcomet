package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class handles the processing of a new DIY submission.

 1. Save Order, Project, Job and Job Specs (Job is saved as a closed job.)
 2. Move temp files to final files
 3. Create file metadata.

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
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.catalog.JobObject;
import com.marcomet.catalog.JobSpecObject;
import com.marcomet.catalog.ProjectObject;
import com.marcomet.catalog.ProxyOrderObject;
import com.marcomet.catalog.ShoppingCart;
import com.marcomet.commonprocesses.ProcessJob1;
import com.marcomet.commonprocesses.ProcessJobSpec;
import com.marcomet.commonprocesses.ProcessOrder;
import com.marcomet.commonprocesses.ProcessProject;
import com.marcomet.environment.SiteHostSettings;
import com.marcomet.files.FileManipulator;
import com.marcomet.files.FileMetaDataContainer;
import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.SimpleLookups;

public class SubmitNewDIY extends HttpServlet implements ActionInterface {

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
    //Get the DIY Shopping Cart (leave the regular shopping cart untouched)
    ShoppingCart shoppingCart = (ShoppingCart) request.getSession().getAttribute("DIYshoppingCart");
    System.err.println("sdiy before vector"); 
    if (shoppingCart == null){
        System.err.println("sc is null");  
		shoppingCart = (ShoppingCart) request.getSession().getAttribute("shoppingCart");
	    if (shoppingCart == null){
	        System.err.println("sc2 is null");  			
	    }
    } 
    Vector projects = shoppingCart.getProjects();
    ProjectObject tempProject;
    int projectId;
    Vector tempJobs;
    JobObject tempJob;
    int jobId;
    JobSpecObject tempJobSpec;
    int jobSpecId;
    Connection conn = null;
    try {
      conn = DBConnect.getConnection();
      //*********************insert new order	****************************
      ProcessOrder po = new ProcessOrder();
      po.setBuyerContactId(buyerContactId);
      po.setBuyerCompanyId(buyerCompanyId);
      po.setOrderedById(((request.getSession().getAttribute("proxyId") == null || request.getSession().getAttribute("proxyId").equals("")) ? buyerContactId : request.getSession().getAttribute("proxyId").toString()));
      po.setSiteHostId(((SiteHostSettings) request.getSession().getAttribute("siteHostSettings")).getSiteHostId());
      po.setSiteHostContactId(shoppingCart.getSiteHostContactId());
      po.insert(conn);

      int orderId = po.getId();

      request.setAttribute("orderId", orderId + "");  //set up for emails
      System.err.println("sdiy before for projects, orderid="+orderId+" projects="+projects.size());
      for (int x = 0; x < projects.size(); x++) {
        //get project
        tempProject = (ProjectObject) projects.elementAt(x);
		if (tempProject==null){
		    System.err.println("sdiy tp is null");
		}
        projectId = tempProject.getId();
        System.err.println("project id= "+projectId);
        try {
          ProcessProject pp = new ProcessProject();
          pp.setId(projectId);
          pp.setProjectName(tempProject.getProjectName());
          pp.setOrderId(orderId);
          System.err.println("sdiy before pp.insert");
          pp.insert(conn);

        }
        catch (SQLException sqle) {
          throw new Exception("DIY ShoppingCart, insertProjectsAndJobs(String id) insertProject (sqle): " + sqle.getMessage());
        } catch (Exception ex) {
			throw new ServletException("SubmitDIY Error: " + ex.getMessage());
        }
        //get Jobs
        tempJobs = tempProject.getJobs();

        for (int y = 0; y < tempJobs.size(); y++) {

          //getJob
          tempJob = (JobObject) tempJobs.elementAt(y);
          jobId = tempJob.getId();
          System.err.println("sdiy before processjob try");
          try {
            ProcessJob1 pj = new ProcessJob1();
            pj.setId(jobId);
            pj.setProjectId(projectId);
            pj.setOrderId(orderId);
            pj.setJobTypeId(tempJob.getJobTypeId());

            pj.setJobName(tempJob.getJobName());
            Statement st=conn.createStatement();

            //Close the job and mark it complete
            pj.setStatusId("120");

            pj.setLastStatusId("1");							
			pj.setServiceTypeId(tempJob.getServiceTypeId());
			
			pj.setEscrowPercentage(tempJob.getEscrowPercentage());
			pj.setVendorId(tempJob.getVendorId());
			pj.setVendorCompanyId(tempJob.getVendorCompanyId());
			pj.setVendorContactId(tempJob.getVendorContactId());
			
			pj.setOrderedById(((request.getSession().getAttribute("proxyId")==null || request.getSession().getAttribute("proxyId").equals(""))?buyerContactId:request.getSession().getAttribute("proxyId").toString()));
			pj.setPromoCode(((request.getSession().getAttribute("promoCode")==null)?"":request.getSession().getAttribute("promoCode").toString()));
			pj.setPriorJobId(((tempJob.getPriorJobId()==null)?"":tempJob.getPriorJobId()));
			pj.setSalesContactId(tempJob.getVendorContactId());
			pj.setSalesCompanyId(getCompanyId(tempJob.getVendorContactId()));
			
			pj.setMarcometFee(tempJob.getMarcometFee());
			pj.setSiteHostMarkup(tempJob.getSiteHostMarkup());	
			if(conn==null) throw new Exception("connection when to null 1");
			boolean orderFromSelfDesigned=((request.getParameter("orderFromSelfDesigned")!=null && request.getParameter("orderFromSelfDesigned").equals("true"))?true:false);					
		    System.err.println("sdiy before pj.insert");
			pj.insert(conn);
			String priorJobId=((tempJob.getPriorJobId()==null)?"":tempJob.getPriorJobId());
			String productId=((request.getParameter("productId")==null)?"":request.getParameter("productId"));
			String fileUse=((request.getParameter("printFileType")==null?"":((request.getParameter("printFileType").equals("Laser"))?"Laser Printer ready file":"Pre-press ready file")));
			int source = ((request.getParameter("printFileType")==null)?1:2);
			boolean selfDesigned=((request.getSession().getAttribute("selfDesigned")!=null && request.getSession().getAttribute("selfDesigned").toString().equals("true") )?true:false);
			String printFileType=((request.getParameter("printFileType")==null)?"Print":request.getParameter("printFileType"));
		    System.err.println("printfile type: "+printFileType);
			boolean reviewRequired=false;
			String qry="Select dp_review_required from products where id='"+productId+"'";
			ResultSet rs = st.executeQuery(qry);
			if (rs.next()) {
				reviewRequired=((rs.getString("dp_review_required").equals("0"))?false:true);
			}
			String fileStatus=((selfDesigned)?"Final":((reviewRequired)?"Accepted":"Final"));
			String fileCategory=((selfDesigned)?printFileType:((reviewRequired)?"Accepted":"Print"));
			
			String fileDescription=((selfDesigned)?fileUse+", created in the Do-It_Yourself Design Center.":"Pre-approved final print PDF, created by buyer in PDF Editor.");
			String finalFileName=jobId+"_"+printFileType+".pdf";
			String finalProofName=jobId+"_Proof.pdf";

			//if there was a pdf file resulting from a template creation upload it as a new file and set status on the file to final print
		    System.err.println(tempJob.getId()+", pbpdf: "+tempJob.getPreBuiltPDFFile());
			if (tempJob.getPreBuiltPDFFile() != null && !(tempJob.getPreBuiltPDFFile().equals(""))){
				File fi=new File(tempJob.getPreBuiltPDFFile());
				File fiJpg=new File(tempJob.getPreBuiltFile());
				File fiProof=new File(tempJob.getPreBuiltPDFFile().replace(".pdf","_proof.pdf"));
				File dir = new File(transfers + buyerCompanyId + File.separatorChar);
			    System.err.println("pbpdf: "+tempJob.getPreBuiltPDFFile());
				if (!dir.isDirectory()) {
					dir.mkdir();
				}
				double fileSize=fi.length();
				fi.renameTo(new File(dir, jobId+"_"+printFileType+".pdf"));
				fiJpg.renameTo(new File(dir, jobId+"_"+printFileType+".jpg"));
				String filePath=transfers + buyerCompanyId + File.separatorChar;
				String fileType= new MimetypesFileTypeMap().getContentType(fi);
				if (fiProof.exists()){
					fiProof.renameTo(new File(dir, jobId+"_Proof.pdf"));
					FileMetaDataContainer pContainer = new FileMetaDataContainer(po.getBuyerContactId(), po.getBuyerCompanyId(), jobId, projectId, finalProofName, fileType, fileSize, filePath, "Pre-approved final print proof PDF, created by buyer in PDF Editor.", "", "Accepted", "For Appvl", fm.getNextGroupId(),source+"");		             
					
					fm.insertMetaData(pContainer, "insert");
				}
				pj.updateJob("thumbnail_file","/transfers/"+ buyerCompanyId + File.separatorChar+jobId+"_"+printFileType+".jpg");

				String productCode=((request.getParameter("productCode")==null)?"":request.getParameter("productCode"));
				
				//If this job was the result of a reprint from a prior job use the print file from the prior job as the final print for this job.
				request.setAttribute("finalFileAddress","/transfers/" + buyerCompanyId + File.separatorChar+finalFileName);
				request.setAttribute("jobId",jobId);
				
				FileMetaDataContainer container = new FileMetaDataContainer(po.getBuyerContactId(), po.getBuyerCompanyId(), jobId, projectId, finalFileName, fileType, fileSize, filePath, fileDescription, "", fileStatus, fileCategory, fm.getNextGroupId(),source+"");
				fm.insertMetaData(container, "insert");

			    System.err.println("sdiy before set closed.");				 
				//Set the job status to closed if the file is a self-designed file and run the jobcost calc on it.
				if(request.getParameter("selfDesigned")!=null && request.getParameter("selfDesigned").equals("true")){
					CalculateJobCosts cjc = new CalculateJobCosts();
					cjc.calculate(jobId); 
					pj.updateJob("status_id", "120");
					pj.updateJob("last_status_id", "120");
					pj.updateJob("job_notes", "Self-Designed");
					pj.updateJob("product_id", productId);
					pj.updateJob("product_code", productCode);
					//request.getSession().removeAttribute("selfDesigned");
				}

			}
			if (!priorJobId.equals("")){
				qry="Select * from file_meta_data where job_id='"+priorJobId+"' and status='Final'";
				st = conn.createStatement();
				rs = st.executeQuery(qry);
				if (rs.next()) {
					FileMetaDataContainer container = new FileMetaDataContainer(po.getBuyerContactId(), po.getBuyerCompanyId(), jobId, projectId, rs.getString("file_name"), rs.getString("file_type"), rs.getDouble("file_size"), rs.getString("path"), rs.getString("description"), "", fileStatus, fileCategory, fm.getNextGroupId(),source+"");
					fm.insertMetaData(container, "insert");	
				}
				if (request.getSession().getAttribute("priorJobId")!=null){request.getSession().removeAttribute("priorJobId");}
				request.getSession().removeAttribute("reprintJob");
			}
			
		} catch(SQLException sqle){
			throw new Exception("ShoppingCart, insertJob job insertion part (sqle): " + sqle.getMessage());
		}
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

//if new user
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
	    Connection conn = null;
	    try {
		      conn = DBConnect.getConnection();
		      //should be available
		      try {
		          ProxyOrderObject poo = (ProxyOrderObject) request.getSession().getAttribute("ProxyOrderObject");
		          buyerContactId = new Integer(poo.getProxyContactId()).toString();
		          buyerCompanyId = new Integer(poo.getProxyCompanyId()).toString();
		      } catch (Exception ex) {
		          buyerContactId = (String) request.getSession().getAttribute("contactId");
		          buyerCompanyId = request.getParameter("companyId");
		      }
		      Hashtable results = new Hashtable();
		      request.setAttribute("errorMessage", (String) results.get("errorMessage"));
		      createOrderEntries(request);
		      request.getSession().removeAttribute("DIYshoppingCart");
		}finally {
		      try {
		        conn.close();
		      } catch (Exception x) {
		        conn = null;
		      }
		}   
}

  private Hashtable processOrder(HttpServletRequest request) {
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
		return returnResults;
  }
}