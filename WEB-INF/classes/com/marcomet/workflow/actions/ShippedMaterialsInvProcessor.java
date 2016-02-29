package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will process a shipment and apply a deduction from the inventory.

 **********************************************************************/
import java.sql.Connection;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;
import java.sql.ResultSet;

public class ShippedMaterialsInvProcessor implements ActionInterface {

  public ShippedMaterialsInvProcessor() {
  }

  public Hashtable execute(MultipartRequest mr, HttpServletResponse res) throws Exception {

    return new Hashtable();

  }

  public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
    if (!(request.getParameter("cost").equals("")) && !(request.getParameter("cost") == null)) {
      Connection conn = null;
      
      try {
        conn = DBConnect.getConnection();
        Statement st = conn.createStatement();

        String jobId = request.getParameter("jobId");
        double cost = Double.parseDouble(request.getParameter("cost"));
        double price = Double.parseDouble(request.getParameter("price"));


        /*
        String query = "SELECT ship_price_policy, std_ship_price, percentage_of_shipment FROM jobs WHERE id=" + jobId;
        ResultSet rs = st.executeQuery(query);
        if (rs.next()) {
          int shipPricePolicy = Integer.parseInt(rs.getString("ship_price_policy"));
          double stdShipPrice = Double.parseDouble(rs.getString("std_ship_price"));
          double percentageOfShipment = Double.parseDouble(rs.getString("percentage_of_shipment"));
          if (stdShipPrice == 0 && shipPricePolicy == 0) {
            price = price * (percentageOfShipment / 100);
          }
          cost = cost * (percentageOfShipment / 100);
        }
        rs.close();
	*/

        HttpSession session = request.getSession();
        String userid = (String) session.getAttribute("contactId");
        String query = "insert into shipping_data (date, method, reference, cost, mu, fee, price, job_id, user_id, shipped_to, shipped_from, description, status,shipping_quantity,product_id,warehouse_id,handling,subvendor_handling,shipping_account_vendor_id,subvendor_id,shipping_vendor_id,adjustment_flag" + ((request.getParameter("job_post_date").equals("0")) ? "" : ",accrued_date") + ",allowance) values (?,?,?,?,?,?,?,?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?" + ((request.getParameter("job_post_date").equals("0")) ? "" : ",?") + ",?)";
        PreparedStatement shipping = conn.prepareStatement(query);
        shipping.clearParameters();
        shipping.setString(1, request.getParameter("adjdate"));
        shipping.setString(2, request.getParameter("method"));
        shipping.setString(3, request.getParameter("reference"));
        //shipping.setString(4, request.getParameter("cost"));
        shipping.setString(4, Double.toString(cost));
        shipping.setString(5, request.getParameter("mu"));
        shipping.setString(6, request.getParameter("fee"));
        //shipping.setString(7, request.getParameter("price"));
        shipping.setString(7, Double.toString(price));
        shipping.setString(8, request.getParameter("jobId"));
        shipping.setString(9, userid);
        shipping.setString(10, request.getParameter("shippedTo"));
        shipping.setString(11, request.getParameter("shippedFrom"));
        shipping.setString(12, request.getParameter("description"));
        shipping.setString(13, request.getParameter("shippingStatus"));
        shipping.setString(14, request.getParameter("quantity"));
        shipping.setString(15, request.getParameter("productId"));
        shipping.setString(16, request.getParameter("warehouse_id"));
        shipping.setString(17, request.getParameter("handling"));
        shipping.setString(18, request.getParameter("svhandling"));
        shipping.setString(19, request.getParameter("shippingAccountVendorId"));
        shipping.setString(20, request.getParameter("subvendorId"));
        shipping.setString(21, request.getParameter("shippingVendorId"));
        shipping.setString(22, request.getParameter("adjustment_flag"));
        if (!(request.getParameter("job_post_date").equals("0"))) {
          shipping.setString(23, request.getParameter("adjdate"));
          shipping.setString(24, (request.getParameter("allowance") != null) ? request.getParameter("allowance") : "0");
        }
        else {
          shipping.setString(23, (request.getParameter("allowance") != null) ? request.getParameter("allowance") : "0");
        }
        shipping.execute();
      }
      catch (Exception ex) {
        throw new Exception("Error in ProcessShippedMaterials " + ex.getMessage());
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
    return new Hashtable();
  }

  public void finalize() {
  }
}
