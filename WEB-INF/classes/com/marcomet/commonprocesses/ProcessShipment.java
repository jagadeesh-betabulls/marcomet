package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ProcessShipment {

  private int id;
  private int orderId;
  private int projectId;
  private int noOfBoxes;
  private int useDiscPrice=0;
  private double shipmentWeight;
  private double calculatedPrice;
  private double calculatedPriceDisc;
  private double calculatedPriceFull;
  private double svFee;
  private double mcFee;
  private double shipmentPrice;
  private String notes="";

  public ProcessShipment() {
  }

  public double getCalculatedPrice() {
    return calculatedPrice;
  }

  public int getId() {
    return id;
  }

  public double getMCFee() {
    return mcFee;
  }

  public int getNoOfBoxes() {
    return noOfBoxes;
  }

  public int getOrderId() {
    return orderId;
  }

  public int getProjectId() {
    return projectId;
  }

  public double getShipmentPrice() {
    return shipmentPrice;
  }

  public double getShipmentWeight() {
    return shipmentWeight;
  }

  public double getSVFee() {
    return svFee;
  }

  public void setCalculatedPrice(double calculatedPrice) {
    this.calculatedPrice = calculatedPrice;
  }

  public void setId(int id) {
    this.id = id;
  }

  public void setMCFee(double mcFee) {
    this.mcFee = mcFee;
  }

  public void setNoOfBoxes(int noOfBoxes) {
    this.noOfBoxes = noOfBoxes;
  }

  public void setOrderId(int orderId) {
    this.orderId = orderId;
  }

  public void setProjectId(int projectId) {
    this.projectId = projectId;
  }

  public void setShipmentPrice(double shipmentPrice) {
    this.shipmentPrice = shipmentPrice;
  }

  public void setShipmentWeight(double shipmentWeight) {
    this.shipmentWeight = shipmentWeight;
  }

  public void setSVFee(double svFee) {
    this.svFee = svFee;
  }

  public final int insert() throws SQLException {
    return processInsert();
  }

  public final int insert(Connection conn) throws SQLException {
    int i = processInsert();
    return i;
  }

  public final int processInsert() throws SQLException {
    Connection conn = null;
    Statement st = null;
    String insertSQL = "INSERT INTO shipments(id, shipment_weight, calculated_price, sv_fee, mc_fee, shipment_price, number_of_boxes, order_id,nondiscounted_calculated_price,discounted_calculated_price,notes) VALUES(?,?,?,?,?,?,?,?,?,?,?)";
    try {
      conn = DBConnect.getConnection();
      st = conn.createStatement();
      st.execute("LOCK TABLES shipments WRITE");

      //if (getId() <= 0) {
      //  String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from shipments";
      //  ResultSet rs = st.executeQuery(getNextIdSQL);
     //   rs.next();
     //   setId(rs.getInt(1));
      //}

      PreparedStatement insert = conn.prepareStatement(insertSQL);
      insert.clearParameters();
      insert.setInt(1, getId());
      insert.setDouble(2, getShipmentWeight());
      if(getUseDiscPrice()==0){
    	  insert.setDouble(3, getCalculatedPrice());
      }else{
    	  insert.setDouble(3, getCalculatedPriceDisc());
      }
      insert.setDouble(4, getSVFee());
      insert.setDouble(5, getMCFee());
      insert.setDouble(6, getShipmentPrice());
      insert.setInt(7, getNoOfBoxes());
      insert.setInt(8, getOrderId());
      insert.setDouble(9, getCalculatedPriceFull());
      insert.setDouble(10, getCalculatedPriceDisc());
      insert.setString(11, getNotes());
      insert.execute();
    }
    catch (Exception ex) {
      throw new SQLException(ex.getMessage());
    }
    finally {
      try {
        st.execute("UNLOCK TABLES");
      }
      catch (Exception x) {
        st = null;
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

  public final void updateShipment(int id, String column, int value) throws SQLException {
    setId(id);
    updateShipment(column, value);
  }

  public final void updateShipment(int id, String column, String value) throws SQLException {
    setId(id);
    updateShipment(column, value);
  }

  public final void updateShipment(String column, int value) throws SQLException {
    Statement qs = null;
    Connection conn = null;

    try {
      conn = DBConnect.getConnection();
      qs = conn.createStatement();
      String sql = "update shipments set " + column + " = " + value + " where id = " + getId();
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

  public final void updateShipment(String column, String value) throws SQLException {
    Statement qs = null;
    Connection conn = null;

    try {
      conn = DBConnect.getConnection();
      qs = conn.createStatement();
      String sql = "update shipments set " + column + " = \'" + value + "\' where id = " + getId();
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

public double getCalculatedPriceDisc() {
	return calculatedPriceDisc;
}

public void setCalculatedPriceDisc(double calculatedPriceDisc) {
	this.calculatedPriceDisc = calculatedPriceDisc;
}

public double getCalculatedPriceFull() {
	return calculatedPriceFull;
}

public void setCalculatedPriceFull(double calculatedPriceFull) {
	this.calculatedPriceFull = calculatedPriceFull;
}

public int getUseDiscPrice() {
	return useDiscPrice;
}

public void setUseDiscPrice(int useDiscPrice) {
	this.useDiscPrice = useDiscPrice;
}

public String getNotes() {
	return notes;
}

public void setNotes(String notes) {
	this.notes = notes;
}
}
