package com.marcomet.commonprocesses;

/**********************************************************************
Description:	This class will be used to perform actions on jobs

Note:			Too many connections are being opened, trying to reuse 
connections already created by classes calling this class. 
 **********************************************************************/
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.*;

import java.sql.*;

public class ProcessJob {

  //varables
  private int id;
  private int projectId;
  private int jobTypeId;
  private String internalReferenceData = "";
  private String jobNotes = "";
  private String jobName = "";
  private int statusId;
  private int lastStatusId;
  private int serviceTypeId;
  private double cost;
  private double mu;
  private double fee;
  private double price;
  private double discount;
  private double escrowPercentage;
  private double escrowAmount;
  private double marcometFee;
  private double siteHostMarkup;
  private String cancelation_Date;
  private int vendorId;
  private int vendorCompanyId;
  private int vendorContactId;
  private int salesContactId;
  private int salesCompanyId;
  private int orderedById;
  private String promoCode;
  private int shipmentId;
  private int shipPricePolicy;
  private double stdShipPrice;
  private double percentageOfShipment;
  private String thumbnail;
  private String subvendorReferenceData;
  private String priorJobId;
  private int shipLocationId;
  private int orderId;

  public ProcessJob() {
  }

  protected void finalize() {
  }

  public final String getCancelation_Date() {
	    return cancelation_Date;
	  }
  public final String getSubvendorReferenceData() {
	    return ((subvendorReferenceData==null)?"":subvendorReferenceData);
	  }

  public final double getCost() {
    return cost;
  }

  public final double getEscrowAmount() {
    return escrowAmount;
  }

  public final double getEscrowPercentage() {
    return escrowPercentage;
  }

  public final double getFee() {
    return fee;
  }

  public final int getId() {
    return id;
  }

  public final String getInternalReferenceData() {
    return internalReferenceData;
  }

  public final String getJobName() {
    return jobName;
  }

  public final String getJobNotes() {
    return jobNotes;
  }

  public final int getJobTypeId() {
    return jobTypeId;
  }

  public final int getLastStatusId() {
    return lastStatusId;
  }

  public final double getMarcometFee() {
    return marcometFee;
  }

  public final double getMu() {
    return mu;
  }

  public final int getOrderedById() {
    return orderedById;
  }

  public final double getPercentageOfShipment() {
    return percentageOfShipment;
  }

  public final double getPrice() {
    return price;
  }

  public String getPriorJobId() {
    return priorJobId;
  }

  public final int getProjectId() {
    return projectId;
  }

  public final String getPromoCode() {
    return ((promoCode == null) ? "" : promoCode);
  }

  public final int getSalesCompanyId() {
    return salesCompanyId;
  }

  public final int getSalesContactId() {
    return salesContactId;
  }

  public final int getServiceTypeId() {
    return serviceTypeId;
  }

  public final int getShipmentId() {
    return shipmentId;
  }

  public final int getShipPricePolicy() {
    return shipPricePolicy;
  }

  public final double getSiteHostMarkup() {
    return siteHostMarkup;
  }

  public final int getStatusId() {
    return statusId;
  }

  public final double getStdShipPrice() {
    return stdShipPrice;
  }

  public String getThumbnail() {
    return thumbnail;
  }

  public final int getVendorCompanyId() {
    return vendorCompanyId;
  }

  public final int getVendorContactId() {
    return vendorContactId;
  }

  public final int getVendorId() {
    return vendorId;
  }
  //if no connection is sent

  public final int insert()
      throws SQLException {

    return processInsert();

  }
  //share connection from calling object

  public final int insert(Connection tempConn) throws SQLException, Exception {
    //conn = tempConn;
    int i = processInsert();
    //conn = null;
    return i;
  }
  //for legacy code will be phased out over time

  public final int insertJob() throws Exception {
    return insertJob();
  }

  public final int processInsert() throws SQLException {


    StringTool st = new StringTool();
    //String insertSQL = "INSERT INTO jobs(id,project_id,job_type_id, internal_reference_data, job_notes,job_name,status_id,service_type_id,cost,mu,fee,price,cancelation_date,escrow_amount,escrow_percentage,last_status_id, vendor_id,vendor_contact_id, vendor_company_id, sales_contact_id, sales_company_id, marcomet_global_fee, site_host_global_markup,ordered_by_id,promo_code,reprinted_from_jobid,subvendor_reference_data) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    String insertSQL = "INSERT INTO jobs(id,cancelation_date,project_id,job_type_id,job_notes,internal_reference_data,promo_code,job_name,last_status_id,status_id,service_type_id,cost,mu,site_host_global_markup,fee,marcomet_global_fee,ship_price_policy,std_ship_price,price,escrow_amount,escrow_percentage,ordered_by_id,vendor_id,vendor_company_id,vendor_contact_id,sales_contact_id,sales_company_id,shipment_id,percentage_of_shipment,reprinted_from_jobid,ship_location_id,discount,jorder_id,subvendor_reference_data) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    Statement qs = null;
    Connection conn = null;

    try {
      conn = DBConnect.getConnection();
      qs = conn.createStatement();
      //lock table
      qs.execute("LOCK TABLES jobs WRITE");

      //set id if it is 0/null
      if (getId() <= 0) {
        String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from jobs;";
        ResultSet rs1 = qs.executeQuery(getNextIdSQL);
        rs1.next();
        setId(rs1.getInt(1));
      }

      PreparedStatement insert = conn.prepareStatement(insertSQL);

      insert.clearParameters();
      insert.setInt(1, getId());
      insert.setString(2, getCancelation_Date());
      insert.setInt(3, getProjectId());
      insert.setInt(4, getJobTypeId());
      insert.setString(5, getJobNotes());
      insert.setString(6, getInternalReferenceData());
      insert.setString(7, getPromoCode());
      insert.setString(8, getJobName());
      insert.setInt(9, getLastStatusId());
      insert.setInt(10, getStatusId());
      insert.setInt(11, getServiceTypeId());
      insert.setDouble(12, getCost());
      insert.setDouble(13, getMu());
      insert.setDouble(14, getSiteHostMarkup());
      insert.setDouble(15, getFee());
      insert.setDouble(16, getMarcometFee());
      System.out.println("shipPricePolicy while processing Job: " + getShipPricePolicy());
      insert.setInt(17, getShipPricePolicy());
      insert.setDouble(18, getStdShipPrice());
      insert.setDouble(19, getPrice());
      insert.setDouble(20, getEscrowAmount());
      insert.setDouble(21, getEscrowPercentage());
      insert.setInt(22, getOrderedById());
      insert.setInt(23, getVendorId());
      insert.setInt(24, getVendorCompanyId());
      insert.setInt(25, getVendorContactId());
      insert.setInt(26, getSalesContactId());
      insert.setInt(27, getSalesCompanyId());
      insert.setInt(28, getShipmentId());
      insert.setDouble(29, getPercentageOfShipment());
      insert.setString(30, getPriorJobId());
      insert.setInt(31, getShipLocationId());
      insert.setDouble(32, getDiscount());
      insert.setDouble(33, getOrderId());
      insert.setString(34, getSubvendorReferenceData());
      insert.execute();

    //if there is a pdf resulting from a template on this job

    }
    catch (Exception x) {
      throw new SQLException(x.getMessage());
    }
    finally {
      try {
        qs.execute("UNLOCK TABLES");
      }
      catch (Exception x) {
        qs = null;
      }
      try {
        conn.close();
      }
      catch (Exception x) {
        conn = null;
      }
    }

    return getId();
  }

  public final void setCancelation_Date(String temp) {
	    cancelation_Date = temp;
	  }
  public final void setSubvendorReferenceData(String temp) {
	  subvendorReferenceData = temp;
	  }

  public final void setCost(double temp) {
    cost = temp;
  }

  public final void setCost(String temp) {
    setCost(Double.parseDouble(temp));
  }

  public final void setEscrowAmount(double temp) {
    escrowAmount = temp;
  }

  public final void setEscrowAmount(String temp) {
    try {
      setEscrowAmount(Double.parseDouble(temp));
    }
    catch (NullPointerException npe) {
    }
  }

  public final void setEscrowPercentage(double temp) {
    escrowPercentage = temp;
  }

  public final void setEscrowPercentage(String temp) {
    try {
      setEscrowPercentage(Double.parseDouble(temp));
    }
    catch (NullPointerException npe) {
    }
  }

  public final void setFee(double temp) {
    fee = temp;
  }

  public final void setFee(String temp) {
    setFee(Double.parseDouble(temp));
  }

  public final void setId(int temp) {
    id = temp;
  }

  public final void setId(String temp) {
    setId(Integer.parseInt(temp));
  }

  public final void setInternalReferenceData(String temp) {
    internalReferenceData = temp;
  }

  public final void setJobName(String temp) {
    jobName = temp;
  }

  public final void setJobNotes(String temp) {
    jobNotes = temp;
  }

  public final void setJobTypeId(int temp) {
    jobTypeId = temp;
  }

  public final void setJobTypeId(String temp) {
    setJobTypeId(Integer.parseInt(temp));
  }

  public final void setLastStatusId(int temp) {
    lastStatusId = temp;
  }

  public final void setLastStatusId(String temp) {
    setLastStatusId(Integer.parseInt(temp));
  }

  public final void setMarcometFee(double temp) {
    marcometFee = temp;
  }

  public final void setMu(double temp) {
    mu = temp;
  }

  public final void setMu(String temp) {
    setMu(Double.parseDouble(temp));
  }

  public final void setOrderedById(int temp) {
    orderedById = temp;
  }

  public final void setOrderedById(String temp) {
    setOrderedById(Integer.parseInt(temp));
  }

  public final void setPercentageOfShipment(double temp) {
    percentageOfShipment = temp;
  }

  public final void setPrice(double temp) {
    price = temp;
  }

  public final void setPrice(String temp) {
    setPrice(Double.parseDouble(temp));
  }

  public void setPriorJobId(String priorJobId) {
    this.priorJobId = priorJobId;
  }

  public final void setProjectId(int temp) {
    projectId = temp;
  }

  public final void setProjectId(String temp) {
    setProjectId(Integer.parseInt(temp));
  }

  public final void setPromoCode(String temp) {
    promoCode = temp;
  }

  public final void setSalesCompanyId(int temp) {
    salesCompanyId = temp;
  }

  public final void setSalesCompanyId(String temp) {
    setSalesCompanyId(Integer.parseInt(temp));
  }

  public final void setSalesContactId(int temp) {
    salesContactId = temp;
  }

  public final void setSalesContactId(String temp) {
    setSalesContactId(Integer.parseInt(temp));
  }

  public final void setServiceTypeId(int temp) {
    serviceTypeId = temp;
  }

  public final void setServiceTypeId(String temp) {
    setServiceTypeId(Integer.parseInt(temp));
  }

  public final void setShipmentId(int temp) {
    shipmentId = temp;
  }

  public final void setShipPricePolicy(int temp) {
    shipPricePolicy = temp;
  }

  public final void setSiteHostMarkup(double temp) {
    siteHostMarkup = temp;
  }

  public final void setStatusId(int temp) {
    statusId = temp;
  }

  public final void setStatusId(String temp) {
    setStatusId(Integer.parseInt(temp));
  }

  public final void setStdShipPrice(double temp) {
    stdShipPrice = temp;
  }

  public void setThumbnail(String thumbnail) {
    this.thumbnail = thumbnail;
  }

  public final void setVendorCompanyId(int temp) {
    vendorCompanyId = temp;
  }

  public final void setVendorCompanyId(String temp) {
    setVendorCompanyId(Integer.parseInt(temp));
  }

  public final void setVendorContactId(int temp) {
    vendorContactId = temp;
  }

  public final void setVendorContactId(String temp) {
    setVendorContactId(Integer.parseInt(temp));
  }

  public final void setVendorId(int temp) {
    vendorId = temp;
  }

  public final void setVendorId(String temp) {
    setVendorId(Integer.parseInt(temp));
  }

  public final void updateJob(int id, String column, int value) throws SQLException {
    setId(id);
    updateJob(column, value);
  }

  public final void updateJob(int id, String column, String value) throws SQLException {
    setId(id);
    updateJob(column, value);
  }

  public final void updateJob(String column, int value) throws SQLException {
    Statement qs = null;
    Connection conn = null;

    try {
      conn = DBConnect.getConnection();
      qs = conn.createStatement();
      String sql = "update jobs set " + column + " = " + value + " where id = " + getId();
      qs.execute(sql);
    }
    catch (Exception x) {
      throw new SQLException(x.getMessage());
    }
    finally {
      try {
        qs.close();
      }
      catch (Exception x) {
        qs = null;
      }
      try {
        conn.close();
      }
      catch (Exception x) {
        conn = null;
      }
    }
  }

  public final void updateJob(String column, String value) throws SQLException {
    Statement qs = null;
    Connection conn = null;

    try {
      conn = DBConnect.getConnection();
      qs = conn.createStatement();
      String sql = "update jobs set " + column + " = \'" + value + "\' where id = " + getId();
      qs.execute(sql);
    }
    catch (Exception x) {
      throw new SQLException(x.getMessage());
    }
    finally {
      try {
        qs.close();
      }
      catch (Exception x) {
        qs = null;
      }
      try {
        conn.close();
      }
      catch (Exception x) {
        conn = null;
      }
    }
  }

public int getShipLocationId() {
	return shipLocationId;
}

public void setShipLocationId(int shipLocationId) {
	this.shipLocationId = shipLocationId;
}

public double getDiscount() {
	return discount;
}

public void setDiscount(double discount) {
	this.discount = discount;
}

public int getOrderId() {
	return orderId;
}

public void setOrderId(int orderId) {
	this.orderId = orderId;
}
}
