package com.vgl.payment;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Vector;

import com.marcomet.jdbc.DBConnect;

public class CustomerPaymentDAO {   
    private static Connection g_conn; 
    public final static int COMP_TYPE = 1;
    public final static int INVOICE_TYPE = 2;
    public final static int JOB_TYPE = 3;
    public final static int CUST_TYPE = 4;
    public final static int ORDER_TYPE = 5;
   
    private static Connection getConnection() throws Exception{
         if(g_conn == null) {           
           g_conn = DBConnect.getConnection();
        }
         return g_conn;
    }

    private static void clean(ResultSet rs, Statement pstmt, Connection conn) {
        try {
            if (rs != null) rs.close();
        } catch(Exception ignoreEx) {}
        try {
            if (pstmt != null) pstmt.close();
        } catch(Exception ignoreEx) {}
       
        try {
             conn.close();
        } catch(Exception ignoreEx) {}
     
        g_conn = null;            
        //try {
        //    if (conn != null) conn.close();
        //} catch(Exception ignoreEx) {}
    }

    public static Vector getCompanies() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector compInfo = new Vector();

        try {
            conn = DBConnect.getConnection();;
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            String selectCompanies = "select id,company_name from companies order by company_name";
            pstmt = conn.prepareStatement(selectCompanies);
            rs = pstmt.executeQuery();

            while(rs.next()) {
                int id = rs.getInt("ID");
                String name = rs.getString("COMPANY_NAME");
                System.out.println("name : " + name);
                System.out.println("id "+id);
      compInfo.add(name + "##" + (new Integer(id)).toString());
     // compInfo.put(name + "#" + (new Integer(id)).toString(),new Integer(id));
            }
        } catch(Exception ex) {
            ex.printStackTrace();
            throw new RuntimeException(ex.getMessage());
        }finally {
            clean(rs, pstmt, conn);
        }
        return compInfo;
    }

    public static String getCompanyName(int compId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String name = null;
        try {
            conn =DBConnect.getConnection();
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            String selectCompany = "select company_name from companies where id=? order by company_name";
            pstmt = conn.prepareStatement(selectCompany);
            pstmt.setInt(1, compId);
            rs = pstmt.executeQuery();
            while(rs.next()) {
                name = rs.getString("COMPANY_NAME");
            }
        } catch(Exception ex) {
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        return name;
    }

    public static int getCollectionId(String check_number) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int collId = 0;
       //  int contactId = getContactId((new Integer(check_number.substring(0,check_number.indexOf("#")-1))).intValue());
        // check_number = check_number.substring(check_number.indexOf("#")+1, check_number.length());
        try {
            conn =DBConnect.getConnection();
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            String selectCollId = "select id from ar_collections where "+
                           " check_number =? ";
            pstmt = conn.prepareStatement(selectCollId);
            pstmt.setString(1, check_number);
          //  pstmt.setInt(2,contactId);
            rs = pstmt.executeQuery();
            while(rs.next()) {
                collId = rs.getInt("id");
            }
        } catch(Exception ex) {
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        return collId;
    }

    public static int getContactId(int compId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int contId = 0;
        try {
            conn =DBConnect.getConnection();
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            String selectContId = "select id from contacts where "+
                           " companyid =?";
            pstmt = conn.prepareStatement(selectContId);
            pstmt.setInt(1, compId);
            rs = pstmt.executeQuery();
            while(rs.next()) {
                contId = rs.getInt("id");
            }
        } catch(Exception ex) {
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        return contId;
    }

    public static String getCollectionIds(String invoiceIds) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String collIds = "";
        try {
            if(invoiceIds == null || invoiceIds.trim().length() ==0) {
                return collIds;
            }
            conn =DBConnect.getConnection();
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            String selectCollId = "select ar_collectionid from ar_collection_details where "+
                           " (ar_invoiceid) IN ("+ invoiceIds + ") order by ar_collectionid";
            pstmt = conn.prepareStatement(selectCollId);
            rs = pstmt.executeQuery();
            StringBuffer sb = new StringBuffer("");
            while(rs.next()) {
                sb.append(rs.getInt("ar_collectionid") + ",");
            }
            collIds = sb.toString();
            if(sb.toString().trim().endsWith(",")){
                return collIds.substring(0,collIds.length()-1);
            }
        } catch(Exception ex) {
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        return collIds;
    }

     public static int getCompID(String id, int idType) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList invoices = null;
        int compId = -1;
        String job=null;
        System.out.println("id is "+id);
        try {
        	
            conn =DBConnect.getConnection();
            String selectCompID = null;
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            if(idType == COMP_TYPE) {
                return (new Integer(id)).intValue();
            } else if(idType == INVOICE_TYPE) {
                selectCompID = "select bill_to_companyid " +
                                 " from ar_invoices where invoice_number=?";
            } else if(idType == JOB_TYPE) {
                selectCompID = "select distinct(ar_invoices.bill_to_companyid) bill_to_companyid "+
                               " from ar_invoices, ar_invoice_details "+
                               " where ar_invoices.id=ar_invoice_details.ar_invoiceid "+
                               " AND ar_invoice_details.jobid =?";
            } else if(idType == CUST_TYPE) {
				selectCompID = "select companyid as bill_to_companyid " +
							   " from contacts where id =?";
            } else if(idType == ORDER_TYPE) {	
            	PreparedStatement pstmt1 = null;
            	ResultSet rs1 = null;
            	System.out.println("id is "+id);
            	String com="SELECT  j.id 'job_id', j.job_name 'job_name', ljt.value 'job_type', lst.value 'service_type', j.status_id 'status_id', j.billable 'invoice', j.billed, j.collected 'collected', j.escrow_amount 'escrow', jfs.shownstatus 'shown_status', CONCAT(c.firstname,' ',c.lastname) 'customer', j.balance_to_vendor 'vendorbalance', j.balance_to_site_host 'sitehostbalance', consolereseller, consolecustomer, actionform, whosaction, sh.abbreviation 'sitehost',c2.company_name 'sitehostname', p.id 'projectnumber', c.default_site_number sitenumber, c.default_pm_site_number pmsitenumber, c.id 'customerid', o.site_host_contact_id 'sitehostcontactid', j.vendor_company_id 'vendor_company_id', if(j.vendor_notes is null,'',j.vendor_notes) 'internalref', j.subvendor_reference_data 'subvendorref', j.vendor_contact_id 'vendorcontactid', c1.company_name 'vendor', j.buyer_internal_reference_data, j.job_link, o.buyer_contact_id, o.buyer_company_id, c3.company_name 'buyercompany', j.root_prod_code, if(j.quantity  is null,'',j.quantity) 'quantity',if(j.dropship_vendor is null,'0',j.dropship_vendor) 'dropship_vendor',if(prod.inv_on_order_amount>prod.inventory_amount and prod.inventory_product_flag=1,1,0) 'bo_status',prod.inv_on_order_amount 'on_order',prod.inventory_amount 'inv_amount',prod.backorder_notes 'bo_notes',j.jwarehouse_id 'wh_number',shipto.st_address1 'st_address1',shipto.st_address2 'st_address2',shipto.st_city 'st_city',shipto.st_state 'st_state',shipto.st_zip 'st_zip',shipto.st_country 'st_country' FROM orders o, projects p, contacts c, jobflowstates jfs, lu_job_types ljt, lu_service_types lst, vendors v, companies c1, companies c2, companies c3, site_hosts sh, job_specs js,jobs j   LEFT JOIN vendors sv on j.dropship_vendor=sv.id LEFT JOIN products prod ON j.product_id = prod.id LEFT JOIN v_ship_to_location shipto on j.ship_location_id=shipto.id  WHERE  o.id = p.order_id AND p.id = j.project_id AND o.buyer_contact_id = c.id AND j.status_id = jfs.statusnumber AND j.service_type_id = lst.id AND j.job_type_id = ljt.id AND o.site_host_id = sh.id AND v.company_id = c1.id AND sh.company_id = c2.id AND c.companyid=c3.id AND j.vendor_id = v.id AND js.job_id=j.id AND (o.id = ?) group by o.id";

            	pstmt1 = conn.prepareStatement(com);
            	pstmt1.setString(1, id);
            	rs1 = pstmt1.executeQuery();
            	
                if(rs1.next()) {
                    //compId = rs1.getInt("bill_to_companyid");
                    job=rs1.getString("job_id");
                }
            	
                selectCompID ="select distinct(ar_invoices.bill_to_companyid) bill_to_companyid from ar_invoices, ar_invoice_details where ar_invoices.id=ar_invoice_details.ar_invoiceid  AND ar_invoice_details.jobid =?";
                System.out.println("job is "+job);
                
            } else {
                throw new RuntimeException("Invalid id type.");
            }
            System.out.println("selectCompID is "+selectCompID);
            System.out.println("id is "+id);
            pstmt = conn.prepareStatement(selectCompID);
            if(idType == INVOICE_TYPE) {
                pstmt.setString(1, id);
            } else if(idType == JOB_TYPE) {
                pstmt.setInt(1, (new Integer(id)).intValue());
            } else if(idType == CUST_TYPE) {
                pstmt.setInt(1, (new Integer(id)).intValue());
            } else if(idType == ORDER_TYPE) {
            	pstmt.setInt(1, (new Integer(job)).intValue());
            } else {
                throw new RuntimeException("Invalid id type.");
            }            
            rs = pstmt.executeQuery();
            while(rs.next()) {
                compId = rs.getInt("bill_to_companyid");
            }
        } catch(Exception ex) {
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        System.out.println("compId : " + compId);
        return compId;
    }


    public static int getInvoiceID(int invoiceNo) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int invoiceId = 0;
        try {
            conn =DBConnect.getConnection();
            String selectInvoiceID = null;
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            selectInvoiceID = "select id " +
                             " from ar_invoices where invoice_number=?";
            pstmt = conn.prepareStatement(selectInvoiceID);
            pstmt.setInt(1, invoiceNo);
            rs = pstmt.executeQuery();
            while(rs.next()) {
                invoiceId = rs.getInt("id");
            }
        } catch(Exception ex) {
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        return invoiceId;
    }

    public static ArrayList getCheckedInvoices(int collectionId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        PreparedStatement pstmt1 = null;
        ResultSet rs = null;
        ResultSet rs1 = null;
        int invoiceId = 0;
        double amt = 0.00;
        double payment = 0.00;
        ArrayList invoices = null;
        try {
            conn =DBConnect.getConnection();
            String selectCheckedInvoices = null;
            String totalCollectionForInvoice = null;
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            selectCheckedInvoices = "select ar_collections.id collId,"+
                        "ar_collection_details.ar_collectionID,"+
                        "ar_collection_details.ar_invoiceid,"+
                        "ar_collection_details.payment_amount,"+
                        "ar_invoices.id invoiceId,"+
                        "ar_invoices.invoice_number,"+
                        "DATE_FORMAT(ar_invoices.record_creation_timestamp, '%m-%d-%Y') record_creation_timestamp,"+
                        "ar_invoices.ar_invoice_amount "+
                        //"ar_invoices.ar_invoice_amount invoice_amount "+
                        "from  "+
                        "ar_collections, ar_collection_details,ar_invoices "+
                        "where "+
                        "ar_collection_details.ar_collectionid = ar_collections.id "+
                        "and ar_collections.id=? "+
                        "and ar_invoices.id=ar_collection_details.ar_invoiceid order by ar_invoices.id";
            totalCollectionForInvoice = "select ar_invoices.ar_invoice_amount, ar_invoices.ar_invoice_amount - sum(ar_collection_details.payment_amount) bal from ar_invoices,ar_collection_details " +
                                        " where ar_invoices.id= ar_collection_details.ar_invoiceid and ar_collection_details.ar_invoiceid=? group by ar_invoices.id";           
            //System.out.println(selectCheckedInvoices);
            pstmt = conn.prepareStatement(selectCheckedInvoices);
            //System.out.println(totalCollectionForInvoice);
            pstmt1 = conn.prepareStatement(totalCollectionForInvoice);
            pstmt.setInt(1,collectionId);      
            
            rs = pstmt.executeQuery();
            //
            invoices = new ArrayList();
            StringBuffer invoiceIds = new StringBuffer("");
            int comp_id = 0;
            while(rs.next()) {            	
            	invoiceId = rs.getInt("invoiceId");       
                pstmt1.setInt(1,invoiceId);
                rs1 = pstmt1.executeQuery();
                amt=-1.0;
                if(rs1.next()){                
                 //if(rs1.first()){                 
                  amt = rs1.getDouble("bal");
                 }
                 double invoiceAmt = rs.getDouble("ar_invoice_amount");
                //if((invoiceAmt-amt) > 0)
                //{
                	System.out.println("--Yes it is " + amt);                
                	Map invoiceInfo = new HashMap();
                	int collId = rs.getInt("collId");
                	System.out.print("Bal:" + amt);
                	invoiceIds.append(""+invoiceId+",");
                	invoiceInfo.put("ID", new Integer(invoiceId));
                	String invoiceNo = rs.getString("Invoice_Number");
                	comp_id = getCompID(invoiceNo, INVOICE_TYPE);
                	invoiceInfo.put("INVOICE_NUMBER", invoiceNo);
                	String invoiceDate = rs.getString("record_creation_timestamp");
                	invoiceInfo.put("INVOICE_DATE", invoiceDate);
                	invoiceInfo.put("INVOICE_AMT", new Double(invoiceAmt));
                	if((new Double(amt)).toString().equals("-1.0"))
                	   invoiceInfo.put("INVOICE_BAL_AMT", new Double(invoiceAmt));
                	else
                	   invoiceInfo.put("INVOICE_BAL_AMT", new Double(amt));
                	payment   = rs.getDouble("payment_amount");
                	invoiceInfo.put("PAYMENT", new Double(payment));              
                	invoices.add(invoiceInfo);
               //} 	
            }

            String strInvoiceIds = null;
            if(invoiceIds.toString().trim().endsWith(",")){
                strInvoiceIds = invoiceIds.toString().substring(0,invoiceIds.toString().length()-1);
            }
            System.out.println("invoices.size() : " + invoices.size());
            ArrayList nonZeroBalInvoices = null;
            if(strInvoiceIds != null) {
                nonZeroBalInvoices = getInvoicesExcept(strInvoiceIds, comp_id);
                System.out.println("comp_id : " + comp_id +" , nonZeroBalInvoices.size() : " + nonZeroBalInvoices.size());
            }
            if(nonZeroBalInvoices !=null)
             invoices.addAll(nonZeroBalInvoices);
            System.out.println("invoices.size() :"+ invoices.size());
        } catch(Exception ex) {
        	ex.printStackTrace();         	       	
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        return invoices;
    }
   public static String getChequeList(int compId)
   {
      Connection conn = null;
      PreparedStatement pstmt = null;
      ResultSet rs = null;
      String cheques = "";
      try{
         conn= DBConnect.getConnection();
         StringBuffer allCheques = new StringBuffer("select check_number from ar_collections ar, contacts c "+
         											" where ar.contactid = c.id and c.companyid =?");
          pstmt = conn.prepareStatement(allCheques.toString());
          pstmt.setInt(1,compId);
          rs = pstmt.executeQuery();
          while(rs.next())
         {
          String __check = rs.getString("check_number");
           if(cheques.equals(""))
              cheques = __check;
           else
             cheques = cheques + "##" + __check;
         }
       } catch(Exception ex) {}
      finally {clean(rs,pstmt,conn);}
       return cheques;
   }
    public static ArrayList getCheques(String cId, String invoiceNo,
                                       String checkNumber,
                                       String checkDateFrom, String checkDateTo) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList cheques = null;
        String collIds = "";
        try {
            conn =DBConnect.getConnection();
            StringBuffer selectCheques = new StringBuffer("select ar_collections.contactid,"+
                                                          " ar_collections.check_number,"+
                                                          " DATE_FORMAT(ar_collections.check_date, '%m-%d-%Y') check_date, "+
                                                          " ar_collections.check_amount, "+
                                                          " DATE_FORMAT(ar_collections.deposit_date, '%m-%d-%Y') deposit_date,"+
                                                          " contacts.companyid cId, "+
                                                          " companies.company_name cName "+
                                                          " from  ar_collections,contacts, "+
                                                          " companies  "+
                                                          " where "+
                                                          " contacts.id = ar_collections.contactid "+
                                                          " and companies.id = contacts.companyid ");
//            StringBuffer selectCheques = new StringBuffer("select contactid,check_number, check_date, check_amount,deposit_date "+
//                             " from ar_collections ");
			//System.out.println("getAllInvoices0" + cId);
            ArrayList invoices = getAllInvoices(Integer.parseInt(cId));
            //System.out.println("getAllInvoices" + cId);
            StringBuffer invoiceIds = new StringBuffer("");
            for(int ii=0; ii< invoices.size(); ii++) {
                Map invoiceInfo = (HashMap)invoices.get(ii);
                Integer id = (Integer)invoiceInfo.get("ID");
                invoiceIds.append(""+id.intValue());
                if(ii != invoices.size()-1) {
                    invoiceIds.append(",");
                    System.out.println("Invoices : " + invoices.toString());
                }
            }
           System.out.println("getAllInvoices1 "  + invoices.size()); 
            if(!(invoiceNo == null || invoiceNo.trim().length() == 0)) {
				int compInvId = getCompID(invoiceNo, INVOICE_TYPE);
				System.out.println("compInvId : " + compInvId);
				if(Integer.parseInt(cId) == 0) {
					ArrayList tempInvoices = getAllInvoices(compInvId);
					invoiceIds = new StringBuffer("");
					System.out.println("Temp Invoices : " + tempInvoices.toString());
					for(int ii=0; ii< tempInvoices.size(); ii++) {
					    Map tInvoiceInfo = (HashMap)tempInvoices.get(ii);
					    Integer tId = (Integer)tInvoiceInfo.get("ID");
					    invoiceIds.append(""+tId.intValue());
					    if(ii != tempInvoices.size()-1) {
					         invoiceIds.append(",");
					    }
					}
					//invoiceIds = new StringBuffer(""+ getInvoiceID(Integer.parseInt(invoiceNo)));
				} else if(compInvId != Integer.parseInt(cId)) {
					 invoiceIds = new StringBuffer("0");
				}
            }
            collIds = getCollectionIds(invoiceIds.toString());
            System.out.println("collIds : " + collIds);
            if(!((invoiceIds.toString().equals("")) || collIds == null || collIds.trim().length() == 0)) {
				System.out.println("collIds if: " + collIds);
                //selectCheques.append(" where (id) IN ("+ collIds+") ");
                selectCheques.append(" AND (ar_collections.id) IN ("+ collIds+") ");
                if(!(checkNumber == null || checkNumber.trim().length() == 0) ){
                    selectCheques.append("AND ar_collections.check_number='"+checkNumber +"' ");
                }
                if(!(checkDateFrom == null || checkDateFrom.trim().length() == 0)) {
                    selectCheques.append("AND ar_collections.check_date >='"+checkDateFrom +"' ");
                }
                if(!(checkDateTo == null || checkDateTo.trim().length() == 0)) {
                    selectCheques.append("AND ar_collections.check_date <='"+checkDateTo +"' ");
                }
            } else {
				System.out.println("collIds else : " + collIds);
                selectCheques.append(" And (ar_collections.id) IN (0) ");
            }
	    selectCheques.append(" order by ar_collections.check_number");

            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            System.out.println(selectCheques.toString());
            pstmt = conn.prepareStatement(selectCheques.toString());
            rs = pstmt.executeQuery();
            Map chequeInfo = null;
            cheques = new ArrayList();
            while(rs.next()) {
                chequeInfo = new HashMap();
                int comp_Id = rs.getInt("cId");
                chequeInfo.put("COMP_ID", ""+comp_Id);
                String comp_Name = rs.getString("cName");
                chequeInfo.put("COMP_NAME", comp_Name);
                String check_number = rs.getString("check_number");
                chequeInfo.put("CHECK_NUMBER", ""+check_number);
                String check_date = rs.getString("check_date");
                chequeInfo.put("CHECK_DATE", check_date);
                String check_amount = rs.getString("check_amount");
                chequeInfo.put("CHECK_AMOUNT", check_amount);
                String deposit_date = rs.getString("deposit_date");
                chequeInfo.put("DEPOSIT_DATE", deposit_date);
                cheques.add(chequeInfo);
            }
        } catch(Exception ex) {
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        return cheques;
    }
	public static ArrayList getCheques() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList cheques = null;
        try {
            conn =DBConnect.getConnection();
            String selectCheques = null;
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            selectCheques = "select check_number, DATE_FORMAT(check_date, '%m-%d-%Y'), check_amount, "+
                             " DATE_FORMAT(deposit_date, '%m-%d-%Y') from ar_collections order by check_number";
            pstmt = conn.prepareStatement(selectCheques);
            rs = pstmt.executeQuery();
            Map chequeInfo = null;
            cheques = new ArrayList();
            while(rs.next()) {
                chequeInfo = new HashMap();
                String check_number = rs.getString("check_number");
                chequeInfo.put("CHECK_NUMBER", ""+check_number);
                String check_date = rs.getString("check_date");
                chequeInfo.put("CHECK_DATE", check_date);
                String check_amount = rs.getString("check_amount");
                chequeInfo.put("CHECK_AMOUNT", check_amount);
                String deposit_date = rs.getString("deposit_date");
                chequeInfo.put("DEPOSIT_DATE", deposit_date);
                cheques.add(chequeInfo);
            }
        } catch(Exception ex) {
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        return cheques;
    }

    public static ArrayList getInvoicesExcept(String invoiceIds, int cId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        PreparedStatement pstmt1 = null;
        ResultSet rs1 = null;        
        ArrayList invoices = null;
        try {
            conn =DBConnect.getConnection();
            String selectInvoices = null;
            String totalCollectionForInvoice = null;
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            if(!(invoiceIds == null || invoiceIds.trim().length() == 0)) {
                selectInvoices = "select id, invoice_number, DATE_FORMAT(ar_invoices.record_creation_timestamp, '%m-%d-%Y') record_creation_timestamp,"+
                             "ar_invoice_amount " + 
                             //,ar_invoice_amount-deposited bal_amount " +
                             " from ar_invoices where ar_invoice_amount-deposited > 0 " +
                             " AND (ID) not in ("+ invoiceIds + ") "+
                             " AND bill_to_companyid=? order by id";
                 totalCollectionForInvoice = "select ar_invoices.ar_invoice_amount, ar_invoices.ar_invoice_amount - sum(payment_amount) amt from ar_invoices, ar_collection_details " +
                                              "where ar_invoices.id= ar_collection_details.ar_invoiceid and ar_invoiceid=? group by ar_invoices.id";            
            } else {
                return null;
            }
            pstmt = conn.prepareStatement(selectInvoices);
            pstmt1 = conn.prepareStatement(totalCollectionForInvoice);
            pstmt.setInt(1, cId);
            
            rs = pstmt.executeQuery();
            Map invoiceInfo = null;
            invoices = new ArrayList();
            while(rs.next()) {
                invoiceInfo = new HashMap();
                int invoiceId = rs.getInt("ID");
                pstmt1.setInt(1, invoiceId);
                rs1 = pstmt1.executeQuery();
                double amt = -1.0;
                double invoiceAmt = rs.getDouble("ar_invoice_amount");
                if(rs1.next()){
                 //if(rs1.first())                
                   amt = rs1.getDouble("amt");
                   System.out.println(" Balance " + rs1.getDouble("ar_invoice_amount"));
                 }  
                if(!(new Double(amt)).toString().equals("0.0"))  
                {                
                	invoiceInfo.put("ID", new Integer(invoiceId));
                	String invoiceNo = rs.getString("Invoice_Number");
                	invoiceInfo.put("INVOICE_NUMBER", invoiceNo);
                	String invoiceDate = rs.getString("record_creation_timestamp");
                	invoiceInfo.put("INVOICE_DATE", invoiceDate);
                	//double invoiceAmt = rs.getDouble("ar_invoice_amount");
                	invoiceInfo.put("INVOICE_AMT", new Double(invoiceAmt));
                	if(amt == -1.0)
                	 invoiceInfo.put("INVOICE_BAL_AMT", new Double(invoiceAmt));
                	else
                	 invoiceInfo.put("INVOICE_BAL_AMT", new Double(amt));
                	invoiceInfo.put("PAYMENT", new Double(0));
                	invoices.add(invoiceInfo);
                }	
            }
        } catch(Exception ex) {
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        return invoices;
    }

    public static ArrayList getAllInvoices(int compId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        PreparedStatement pstmt1 = null;
        ResultSet rs1 = null;
        ArrayList invoices = null;
        try {
            conn =DBConnect.getConnection();
            String selectInvoices = null;
            String totalCollectionForInvoice = null;
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            if(compId == 0) {
                //selectInvoices = "select id, invoice_number, DATE_FORMAT(record_creation_timestamp, '%m-%d-%Y') record_creation_timestamp,"+
                  //           "ar_invoice_amount,ar_invoice_amount-deposited bal_amount " +
                  //           " from ar_invoices order by invoice_number";
            } else {
                selectInvoices = "select id, invoice_number, DATE_FORMAT(record_creation_timestamp, '%m-%d-%Y') record_creation_timestamp,"+
                                 "ar_invoice_amount" + 
                                 //,ar_invoice_amount-deposited bal_amount " +
                                 " from ar_invoices where "+
                                 " bill_to_companyid = ? order by id";
                totalCollectionForInvoice = "select sum(payment_amount) amt from ar_collection_details" +
                                            " where ar_invoiceid=?";                 
            }
            pstmt = conn.prepareStatement(selectInvoices);
            pstmt1 = conn.prepareStatement(totalCollectionForInvoice);
            if(compId != 0) {
                pstmt.setInt(1, compId);                
            }
            rs = pstmt.executeQuery();
            Map invoiceInfo = null;
            invoices = new ArrayList();
            while(rs.next()) {
                invoiceInfo = new HashMap();
                int invoiceId = rs.getInt("ID");
                pstmt1.setInt(1, invoiceId);
                rs1 = pstmt1.executeQuery();
                double amt = 0.00;
                if(rs1.next())
                   amt  = rs1.getDouble("amt");
                invoiceInfo.put("ID", new Integer(invoiceId));
                String invoiceNo = rs.getString("Invoice_Number");
                invoiceInfo.put("INVOICE_NUMBER", invoiceNo);
                String invoiceDate = rs.getString("record_creation_timestamp");
                invoiceInfo.put("INVOICE_DATE", invoiceDate);
                double invoiceAmt = rs.getDouble("ar_invoice_amount");
                invoiceInfo.put("INVOICE_AMT", new Double(invoiceAmt));
                invoiceInfo.put("INVOICE_BAL_AMT", new Double(invoiceAmt-amt));
                invoices.add(invoiceInfo);
            }
        } catch(Exception ex) {
        	ex.printStackTrace();
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        return invoices;
    }
    public static ArrayList getInvoices(int compId, boolean showAll) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        PreparedStatement pstmt1 = null;
        ResultSet rs1 = null;
        ArrayList invoices = null;
        try {
            conn =DBConnect.getConnection();
            String selectInvoices = null;
            String totalCollectionForInvoice = null;
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            if(compId == 0) {
                selectInvoices = "select i.id, i.invoice_number, DATE_FORMAT(i.record_creation_timestamp, '%m-%d-%Y') record_creation_timestamp,"+
                             "i.ar_invoice_amount, id.jobid" +
                             //,ar_invoice_amount-deposited bal_amount " +
                             " from ar_invoices i, ar_invoice_details id " +
							 "where i.id = id.ar_invoiceid and i.ar_invoice_amount-i.deposited != 0 order by i.id";
            } else {
                selectInvoices = "select i.id, i.invoice_number, DATE_FORMAT(i.record_creation_timestamp, '%m-%d-%Y') record_creation_timestamp,"+
                				"i.ar_invoice_amount, id.jobid" +
								//,ar_invoice_amount-deposited bal_amount " +
                				" from ar_invoices i, ar_invoice_details id " +
                                 " where i.id = id.ar_invoiceid and i.ar_invoice_amount-i.deposited != 0 and "+
                                 " i.bill_to_companyid = ? order by i.id";
            }
            totalCollectionForInvoice = "select ar_invoices.ar_invoice_amount, ar_invoices.ar_invoice_amount - "  + 
                                      " sum(ar_collection_details.payment_amount) amt " +
                                       "from ar_invoices,ar_collection_details" +
                                        " where ar_invoices.id= ar_collection_details.ar_invoiceid and ar_invoiceid=? group by ar_invoices.id";
            pstmt1 = conn.prepareStatement(totalCollectionForInvoice);
            pstmt = conn.prepareStatement(selectInvoices);
            if(compId != 0) {
                pstmt.setInt(1, compId);
            }
            rs = pstmt.executeQuery();
            Map invoiceInfo = null;
            invoices = new ArrayList();
            while(rs.next()) {
            	double amt = -1.00;
            	double invoiceAmt = rs.getDouble("ar_invoice_amount");
            	int invoiceId = rs.getInt("ID");
                pstmt1.setInt(1,invoiceId);
                rs1 = pstmt1.executeQuery();
                System.out.println("INvoice Id-->" + invoiceId);                
                try
                {
                  while(rs1.next()){
                    //if(rs1.first())  
                     System.out.println("Test 3");
                     double invAmt  = rs1.getDouble("ar_invoice_amount");                  
                     amt  = rs1.getDouble("amt");
                     System.out.println("Balll " + invoiceId + " " + amt + " " + invAmt);
                    }
                    
                } catch(Exception ex){
                  ex.printStackTrace();	
                }  
              if(!((new Double(amt)).toString().equals("0.0"))||showAll) {              
                invoiceInfo = new HashMap();                                  
                invoiceInfo.put("ID", new Integer(invoiceId));
                String invoiceNo = rs.getString("Invoice_Number");
                invoiceInfo.put("INVOICE_NUMBER", invoiceNo);
                String jobNo = rs.getString("jobid");
                invoiceInfo.put("JOB_NUMBER", jobNo);
                String invoiceDate = rs.getString("record_creation_timestamp");
                invoiceInfo.put("INVOICE_DATE", invoiceDate);
                //double invoiceAmt = rs.getDouble("ar_invoice_amount");
                invoiceInfo.put("INVOICE_AMT", new Double(invoiceAmt));
                System.out.println((new Double(amt)).toString());
                if(((new Double(amt)).toString().equals("-1.0")))
                 invoiceInfo.put("INVOICE_BAL_AMT", new Double(invoiceAmt));
                else
                  invoiceInfo.put("INVOICE_BAL_AMT", new Double(amt));
                invoices.add(invoiceInfo);
              }  
            }
        } catch(Exception ex) {
        	ex.printStackTrace();
            throw new RuntimeException(ex.getMessage());
        } finally {
            clean(rs, pstmt, conn);
        }
        return invoices;
    }

    public static ArrayList getInvoices(String id, int idType, boolean showAll){
        int compId = getCompID(id, idType);
        return getInvoices(compId, showAll);
    }

    public static ArrayList getEditableInvoices(String checkNumber){
        int collId = getCollectionId(checkNumber);
        return getCheckedInvoices(collId);
    }

    public static void insertCustomerPayment(Map checkInfo, ArrayList invoiceDetails) {
        String check_number = insertCheckInfo(checkInfo);
        int collId = 0;
        if(check_number != null) {
            updateInvoicePayment(check_number, invoiceDetails);
        }
    }
    public static String insertCheckInfo(Map checkInfo) {
        Connection conn=  null;
        ResultSet rs = null;
        PreparedStatement pstmt = null;
        String  check_number;
        try {
            conn =DBConnect.getConnection();
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            int cId = Integer.parseInt((String)checkInfo.get("COMP_ID"));
            int contId = getContactId(cId);
            check_number = (String)checkInfo.get("CHECK_NUMBER");
            String check_date = (String)checkInfo.get("CHECK_DATE");
            double check_amount = Double.parseDouble((String)checkInfo.get("CHECK_AMOUNT"));
            String deposit_date = (String)checkInfo.get("DEPOSIT_DATE");
            System.out.println("check_date " + check_date);
            System.out.println("deposit_date " +deposit_date );
            String insertCheckInfo = "insert into ar_collections(contactid,check_number, check_date,check_amount,deposit_date) values (?,?,?,?,?)";
            pstmt = conn.prepareStatement(insertCheckInfo);
            pstmt.setInt(1, contId);
            pstmt.setString(2, check_number);
            pstmt.setString (3, check_date);
            pstmt.setDouble(4, check_amount);
            pstmt.setString(5, deposit_date);
            System.out.println("Check Number " + check_number);
            pstmt.executeUpdate();
            return check_number;
        } 
         catch(Exception ex) 
         {
             ex.printStackTrace();
            throw new RuntimeException(ex.getMessage());
         }
           finally 
         {
            clean(null, pstmt, conn);
         }
    }
    
     public static String updateCheckInfo(Map checkInfo) {
        Connection conn=  null;
        ResultSet rs = null;
        PreparedStatement pstmt = null;
        String  check_number;
        String   old_check_number;
        try {
            conn =DBConnect.getConnection();
            if (conn == null) {
                throw new RuntimeException("connection failed.");
            }
            int cId = Integer.parseInt((String)checkInfo.get("COMP_ID"));
            int contId = getContactId(cId);
            
            old_check_number = (String)checkInfo.get("OLD_CHECK_NUMBER");
            check_number = (String)checkInfo.get("CHECK_NUMBER");
            String check_date = (String)checkInfo.get("CHECK_DATE");
            double check_amount = Double.parseDouble((String)checkInfo.get("CHECK_AMOUNT"));
            String deposit_date = (String)checkInfo.get("DEPOSIT_DATE");
            System.out.println("check_date " + check_date);
            System.out.println("deposit_date " +deposit_date );
            String insertCheckInfo = "update ar_collections set check_number=?,"+
                                     " check_date=?,check_amount=?,deposit_date=? " +
                                     " where contactid=? and check_number=?";
            pstmt = conn.prepareStatement(insertCheckInfo);
            
            pstmt.setString(1, check_number);
            pstmt.setString (2, check_date);
            pstmt.setDouble(3, check_amount);
            pstmt.setString(4, deposit_date);
            pstmt.setInt(5, contId);
            pstmt.setString(6, old_check_number);
            System.out.println("check Number " + check_number);
            System.out.println("Comp Id " +contId);
            pstmt.executeUpdate();
            return check_number;
        } 
         catch(Exception ex) 
         {
             ex.printStackTrace();
            throw new RuntimeException(ex.getMessage());
         }
           finally 
         {
            clean(null, pstmt, conn);
         }
    }

    public static int updateInvoicePayment(String check_number, ArrayList invoiceDetails) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        PreparedStatement pstmt1 = null;
        int count=0;
        try {
            conn = DBConnect.getConnection();
            String insertCollectionDetails = "insert into ar_collection_details(ar_collectionid,"+
                                     " ar_invoiceid, payment_amount) values" +
                                     " (?,?,?)";
            String updateInvoicePayment = "UPDATE ar_invoices SET DEPOSITED = deposited+"+
                                          "? WHERE ID=?";
            pstmt = conn.prepareStatement(insertCollectionDetails);
            //pstmt1 = conn.prepareStatement(updateInvoicePayment);
            int collectionId = getCollectionId(check_number);
            System.out.println("collectionId : "+ collectionId);

            for(int ii=0; ii<invoiceDetails.size(); ii++) {
                HashMap invoiceInfo = (HashMap)invoiceDetails.get(ii);
                int invoiceId = (new Integer((String)invoiceInfo.get("ID"))).intValue();
                System.out.println("invoiceId : "+ invoiceId);
                double payAmt = (new Double((String)invoiceInfo.get("PAYMENT_AMOUNT"))).doubleValue();
                System.out.println("Test --> payAmt : "+ payAmt);
                // common statements for batch and non batch update
                pstmt.setInt(1, collectionId);
                pstmt.setInt(2, invoiceId);
                pstmt.setDouble(3, payAmt);
                //statement for batch update
                System.out.println("Test ---A");
                //pstmt.addBatch();
                pstmt.executeUpdate();
                // System.out.println("Test --B");
                //pstmt1.setDouble(1, payAmt);
                //pstmt1.setInt(2, invoiceId);
                //pstmt1.addBatch();
            }
             System.out.println("Test--0 executeBatch()");
             //int[] insertColl = pstmt.executeBatch();             
             
             //pstmt1.executeQuery();
            //int[] upupdateQuerydInvoices = pstmt1.executeBatch();
            //count = insertColl.length;
            
        } catch(Exception ex) {
            ex.printStackTrace();
            //throw new RuntimeException(ex.getMessage());
        }finally {
            clean(null, pstmt, null);
            clean(null, pstmt1, conn);
        }
        return 0;
    }

    public static int EditInvoicePayment(String check_number, ArrayList updatedInvoices) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        int count=0;
        try {
            conn = DBConnect.getConnection();

            String updateCollectionDetails = "UPDATE ar_collection_details SET payment_amount = "+
                                     "payment_amount+? where ar_collectionid=? AND " +
                                     " ar_invoiceid=?";
            String updateInvoicePayment = "UPDATE ar_invoices SET DEPOSITED = deposited+"+
                                          "? WHERE ID=?";
            String deleteZeroPayment = "DELETE FROM ar_collection_details WHERE payment_amount = 0";
            pstmt = conn.prepareStatement(updateCollectionDetails);
            pstmt1 = conn.prepareStatement(updateInvoicePayment);
            pstmt2 = conn.prepareStatement(deleteZeroPayment);
            int collectionId = getCollectionId(check_number);
            System.out.println("collectionId : "+ collectionId);

            for(int ii=0; ii<updatedInvoices.size(); ii++) {
                HashMap invoiceInfo = (HashMap)updatedInvoices.get(ii);
                int invoiceId = (new Integer((String)invoiceInfo.get("ID"))).intValue();
                System.out.println("invoiceId : "+ invoiceId);
                double payAmt = (new Double((String)invoiceInfo.get("PAYMENT_AMOUNT"))).doubleValue();
                System.out.println("payAmt : "+ payAmt);
                // common statements for batch and non batch update
                pstmt.setDouble(1, payAmt);
                pstmt.setInt(2, collectionId);
                pstmt.setInt(3, invoiceId);
                //statement for batch update
                //pstmt.addBatch();
                 pstmt.executeUpdate();
                //pstmt1.setDouble(1, payAmt);
                //pstmt1.setInt(2, invoiceId);
                //pstmt1.addBatch();
            }
            //int[] updateColl = pstmt.executeBatch();
            //int[] updInvoices = pstmt1.executeBatch();
            //pstmt.executeUpdate();
            pstmt2.executeUpdate();
            //count = updateColl.length;
        } catch(Exception ex) {
            throw new RuntimeException(ex.getMessage());
        }finally {

            clean(null, pstmt, null);
            clean(null, pstmt1, conn);
        }
        return 0;
    }

    public static int DeleteCheckEntry(String check_number, ArrayList updatedInvoices) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        int count=0;
        try {
            conn = DBConnect.getConnection();

            String updateInvoicePayment = "UPDATE ar_invoices SET DEPOSITED = deposited+" + "? WHERE ID=?";
            String deleteCollectionDetails = "DELETE FROM ar_collection_details WHERE ar_collectionid=?";
            String deleteCheckEntry = "DELETE FROM ar_collections WHERE check_number = '" + check_number + "'";

            pstmt1 = conn.prepareStatement(updateInvoicePayment);
            pstmt = conn.prepareStatement(deleteCollectionDetails);
            pstmt2 = conn.prepareStatement(deleteCheckEntry);

            int collectionId = getCollectionId(check_number);
            System.out.println("collectionId : "+ collectionId);
            pstmt.setInt(1,collectionId);

            for(int ii=0; ii<updatedInvoices.size(); ii++) {
                HashMap invoiceInfo = (HashMap)updatedInvoices.get(ii);
                int invoiceId = (new Integer((String)invoiceInfo.get("ID"))).intValue();
                System.out.println("DeleteCheckEntry::invoiceId : "+ invoiceId);
                double payAmt = (new Double((String)invoiceInfo.get("PAYMENT_AMOUNT"))).doubleValue();
                System.out.println("DeleteCheckEntry::payAmt : "+ payAmt);
                // common statements for batch and non batch update
                pstmt1.setDouble(1, payAmt);
                // pstmt1.setDouble(1,0);
                pstmt1.setInt(2, invoiceId);
                //pstmt1.addBatch();
            }
            //int[] updInvoices = pstmt1.executeBatch();
            pstmt.executeUpdate();
            pstmt2.executeUpdate();
            //count = updInvoices.length;
        } catch(Exception ex) {
            throw new RuntimeException(ex.getMessage());
        }finally {
            clean(null, pstmt, null);
            clean(null, pstmt2, null);
            clean(null, pstmt1, conn);
        }
        return 0;
    }
/****************************************************************/
/* Method call few class for job recalculation */
/* Sanjay */
/************************************************************/
public static void jobRecalculate(String invoiceId){
  System.out.println("jobCalculation");
  Connection conn=null;
  PreparedStatement pstmt =null;
  ResultSet rs =null;
  int inId = (new Integer(invoiceId)).intValue();
  try{ 
	  String querySql = "select jobId from ar_invoice_details where ar_invoiceId=?";   conn = DBConnect.getConnection();
	  pstmt = conn.prepareStatement(querySql);
	  pstmt.setInt(1,inId);
	  rs = pstmt.executeQuery(); 
	  while(rs.next()){
		   int jobId = rs.getInt("jobId");
		   System.out.println("JOB-ID->" +jobId);
		   // call com.marcomet.workflow.actions.CalculateJobCosts
		
		   com.marcomet.workflow.actions.CalculateJobCosts __jobCal=null;
		  __jobCal = new com.marcomet.workflow.actions.CalculateJobCosts();
		   __jobCal.calculate(jobId);
	  }
  }catch(Exception ex){
  	ex.printStackTrace();
  }finally{
      clean(rs, pstmt, conn);
  }
 }
}
