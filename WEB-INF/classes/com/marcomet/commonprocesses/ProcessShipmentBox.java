package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ProcessShipmentBox {

  private int id;
  private int shipmentId;
  private int boxNumber;
  private double boxWeight;
  private double boxHeight;
  private double boxLength;
  private double boxDepth;
  private String boxContents;

  public String getBoxContents() {
    return boxContents;
  }

  public double getBoxDepth() {
    return boxDepth;
  }

  public double getBoxHeight() {
    return boxHeight;
  }

  public double getBoxLength() {
    return boxLength;
  }

  public int getBoxNumber() {
    return boxNumber;
  }

  public double getBoxWeight() {
    return boxWeight;
  }

  public int getId() {
    return id;
  }

  public int getShipmentId() {
    return shipmentId;
  }

  public void setBoxContents(String boxContents) {
    this.boxContents = boxContents;
  }

  public void setBoxDepth(double boxDepth) {
    this.boxDepth = boxDepth;
  }

  public void setBoxHeight(double boxHeight) {
    this.boxHeight = boxHeight;
  }

  public void setBoxLength(double boxLength) {
    this.boxLength = boxLength;
  }

  public void setBoxNumber(int boxNumber) {
    this.boxNumber = boxNumber;
  }

  public void setBoxWeight(double boxWeight) {
    this.boxWeight = boxWeight;
  }

  public void setId(int id) {
    this.id = id;
  }

  public void setShipmentId(int shipmentId) {
    this.shipmentId = shipmentId;
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
    String insertSQL = "INSERT INTO shipment_boxes(id, shipment_id, box_number, box_weight, box_height, box_length, box_depth, box_contents) VALUES(?,?,?,?,?,?,?,?)";
    try {
      conn = DBConnect.getConnection();
      st = conn.createStatement();
      st.execute("LOCK TABLES shipment_boxes WRITE");

      //if (getId() <= 0) {
        String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from shipment_boxes";
        ResultSet rs = st.executeQuery(getNextIdSQL);
        rs.next();
        setId(rs.getInt(1));
      //}

      PreparedStatement insert = conn.prepareStatement(insertSQL);
      insert.clearParameters();
      insert.setInt(1, getId());
      insert.setInt(2, getShipmentId());
      insert.setInt(3, getBoxNumber());
      insert.setDouble(4, getBoxWeight());
      insert.setDouble(5, getBoxHeight());
      insert.setDouble(6, getBoxLength());
      insert.setDouble(7, getBoxDepth());
      insert.setString(8, getBoxContents());
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
      String sql = "update shipment_boxes set " + column + " = " + value + " where id = " + getId();
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
      String sql = "update shipment_boxes set " + column + " = \'" + value + "\' where id = " + getId();
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
}
