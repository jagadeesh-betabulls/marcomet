package com.marcomet.catalog;

import com.marcomet.environment.SiteHostSettings;
import java.sql.*;
import java.text.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.*;

public class CatalogShipmentCreationServlet extends HttpServlet {

	  public String shipmentOption;
	  public String shipLocationId;
  public Vector vBuildtype = new Vector();
  public Vector vInvProdFlag = new Vector();
  public Vector vInvAmount = new Vector();
  public Vector vInvOnOrderAmount = new Vector();
  public Vector vZipFrom = new Vector();
  public Vector vZipFromState = new Vector();
  public Vector vZipFromCountry = new Vector();
  public Vector vZipTo = new Vector();
  public Vector vZipToState = new Vector();
  public Vector vZipToStateCode = new Vector();
  public Vector vZipToCountry = new Vector();
  public Vector vNumberOfBoxes = new Vector();
  public Vector vWeight = new Vector();
  public Vector vMaxWeight = new Vector();
  public Vector vHeight = new Vector();
  public Vector vMaxHeight = new Vector();
  public Vector vLength = new Vector();
  public Vector vMaxLength = new Vector();
  public Vector vWidth = new Vector();
  public Vector vMaxWidth = new Vector();
  public Vector vPaddingPercent = new Vector();
  public Vector vJobs = new Vector();
  public Vector vJobsQuantity = new Vector();
  public Vector vProjectId = new Vector();
  public Vector vShipper = new Vector();
  public Vector vShipperType = new Vector();
  public Vector vShipperAccountNumber = new Vector();
  public Vector vShipperUserName = new Vector();
  public Vector vShipperPassword = new Vector();
  public Vector vShipperXMLKey = new Vector();
  public Vector vShipperMeterNumber = new Vector();
  public Vector vDoNotBundleShipping = new Vector();
  public Vector vSVFee = new Vector();
  public Vector vWarehouseId = new Vector();
  

  public String getShipmentOption() {
    return this.shipmentOption;
  }

  public void setShipmentOption(String shipmentOption) {
    this.shipmentOption = shipmentOption;
  }

  public void createShipment(HttpSession session) {
    try {
      String productId = null;
      String contactId = null;
      String amount = "0";
      int shipLocationId=0;

      Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
      Statement st = conn.createStatement();
      String query = "";
      String sitehostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();
      ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("shoppingCart");
      shipLocationId=shoppingCart.getShippingLocationId();
      Vector shipments = shoppingCart.getShipments();
      if (shipments.size() > 0) {
        for (int i = 0; i < shipments.size(); i++) {
          shoppingCart.removeShipment(0);
        }
      }
      shipLocationId=shoppingCart.getShippingLocationId();
      Vector projects = shoppingCart.getProjects();
      if (projects.size() > 0) {
        for (int i = 0; i < projects.size(); i++) {
          int ii = i + 1;
          System.out.println("project count: " + ii);
          ProjectObject po = (ProjectObject) projects.elementAt(i);
          int projectId = po.getId();
          Vector jobs = po.getJobs();
          for (int j = 0; j < jobs.size(); j++) {
            int jj = j + 1;
            JobObject jo = (JobObject) jobs.elementAt(j);
            JobSpecObject jsoProductCode = (JobSpecObject) jo.getJobSpecs().get("9001");
            query = "SELECT id FROM products WHERE prod_code='" + jsoProductCode.getValue() + "'";
            ResultSet rs = st.executeQuery(query);
            if (rs.next()) {
              productId = rs.getString("id");
            }
            rs.close();
            contactId = (String) session.getAttribute("contactId");
            JobSpecObject jsoQuantity = (JobSpecObject) jo.getJobSpecs().get("705");
            amount = ((jsoQuantity==null || jsoQuantity.getValue()==null || jsoQuantity.getValue().equals("") || jsoQuantity.getValue().equals("NA"))?"0":jsoQuantity.getValue());

            //query = "SELECT cl.zip 'zipFrom', p.build_type, w.ship_box_max_weight 'maxWeight', w.ship_box_height 'maxHeight', w.ship_box_length 'maxLength', w.ship_box_width 'maxWidth' FROM company_locations cl, warehouses w, products p WHERE cl.id=w.location_id AND w.id=p.default_warehouse_id AND p.id=" + productId + " AND p.do_not_bundle_shipping!=1 ORDER BY cl.zip, p.build_type";
            //query = "SELECT cl.zip 'zipFrom', lus.state_abreviation 'zipFromState', luc.value 'zipFromCountry', p.build_type, w.ship_box_max_weight 'maxWeight', w.ship_box_height 'maxHeight', w.ship_box_length 'maxLength', w.ship_box_width 'maxWidth', w.box_padding_percent 'paddingPercent' FROM company_locations cl, warehouses w, lu_states lus, lu_countries luc, products p left join product_price_codes ppc on ppc.prod_price_code=p.prod_price_code left join vendors v on v.id=ppc.dropship_vendor WHERE cl.id=w.location_id AND if(p.default_warehouse_id is not null and p.default_warehouse_id>0, w.id=p.default_warehouse_id,w.id=v.default_warehouse_id) AND p.id=" + productId + " AND p.do_not_bundle_shipping!=1 AND cl.state=lus.id AND cl.country_id=luc.id ORDER BY cl.zip, p.build_type";
            query = "SELECT cl.zip 'zipFrom', lus.state_abreviation 'zipFromState', luc.value 'zipFromCountry', p.build_type 'buildType', p.inventory_product_flag 'invProdFlag', p.inventory_amount 'invAmount', p.inv_on_order_amount 'invOnOrderAmount', p.do_not_bundle_shipping 'doNotBundle', w.ship_box_max_weight 'maxWeight', w.ship_box_height 'maxHeight', w.ship_box_length 'maxLength', w.ship_box_width 'maxWidth', w.box_padding_percent 'paddingPercent',w.id as warehouseId FROM company_locations cl, warehouses w, lu_states lus, lu_countries luc, products p left join product_price_codes ppc on ppc.prod_price_code=p.prod_price_code left join vendors v on v.id=ppc.dropship_vendor WHERE cl.id=w.location_id AND if(p.default_warehouse_id is not null and p.default_warehouse_id>0, w.id=p.default_warehouse_id,w.id=v.default_warehouse_id) AND p.id=" + productId + " AND cl.state=lus.id AND cl.country_id=luc.id ORDER BY cl.zip, p.build_type,p.do_not_bundle_shipping";
            ResultSet rs1 = st.executeQuery(query);
            if (rs1.next()) {
              vZipFrom.addElement(rs1.getString("zipFrom"));
              vZipFromState.addElement(rs1.getString("zipFromState"));
              vZipFromCountry.addElement(rs1.getString("zipFromCountry"));
              vBuildtype.addElement(rs1.getString("buildType"));
              vInvProdFlag.addElement(rs1.getString("invProdFlag"));
              vInvAmount.addElement(rs1.getString("invAmount"));
              vInvOnOrderAmount.addElement(rs1.getString("invOnOrderAmount"));
              vDoNotBundleShipping.addElement(rs1.getString("doNotBundle"));
              vMaxWeight.addElement(rs1.getString("maxWeight"));
              vMaxHeight.addElement(rs1.getString("maxHeight"));
              vMaxLength.addElement(rs1.getString("maxLength"));
              vMaxWidth.addElement(rs1.getString("maxWidth"));
              vPaddingPercent.addElement(rs1.getString("paddingPercent"));
              vJobs.addElement(jo);
              vJobsQuantity.addElement(jo.getQuantity());
              vProjectId.addElement(projectId);
              vWarehouseId.addElement(rs1.getString("warehouseId"));
            }
            rs1.close();
            
            query = "SELECT l.zip 'zipTo', l.state 'zipToStateCode', lus.state_abreviation 'zipToState', luc.value 'zipToCountry' FROM shipping_locations l, contacts c, lu_states lus, lu_countries luc WHERE l.id="+shipLocationId+"  AND l.state=lus.id AND l.country_id=luc.id";
            ResultSet rs2 = st.executeQuery(query);
            if (rs2.next()) {
              vZipTo.addElement(rs2.getString("zipTo"));
              vZipToState.addElement(rs2.getString("zipToState"));
              vZipToStateCode.addElement(rs2.getInt("zipToStateCode"));
              vZipToCountry.addElement(rs2.getString("zipToCountry"));
            }
            rs2.close();

            query = "SELECT pp.weight_per_box 'weight', pp.length, pp.width, pp.height, pp.number_of_boxes 'boxes' FROM product_prices pp, products p WHERE pp.quantity=" + ((amount==null || amount.equals("") )?"0":amount) + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
            ResultSet rs3 = st.executeQuery(query);
            if (rs3.next()) {
              vWeight.addElement(rs3.getString("weight"));
              vLength.addElement(rs3.getString("length"));
              vWidth.addElement(rs3.getString("width"));
              vHeight.addElement(rs3.getString("height"));
              vNumberOfBoxes.addElement(rs3.getString("boxes"));
            }
            rs3.close();

            query = "SELECT DISTINCT sa.account_number, sa.user_name, sa.password, sa.xml_key, sa.meter_number FROM shipping_accounts sa, product_prices pp, products p WHERE sa.shipper_type='UPS' AND sa.vendor_id=pp.ds_vendor AND pp.quantity=" + amount + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
            ResultSet rs41 = st.executeQuery(query);
            if (rs41.next()) {
              vShipperAccountNumber.addElement(rs41.getString("account_number"));
              vShipperUserName.addElement(rs41.getString("user_name"));
              vShipperPassword.addElement(rs41.getString("password"));
              vShipperXMLKey.addElement(rs41.getString("xml_key"));
              vShipperMeterNumber.addElement(rs41.getString("meter_number"));
            }
            else {
              query = "SELECT DISTINCT account_number, user_name, password, xml_key, meter_number FROM shipping_accounts WHERE shipper_type='UPS' AND vendor_id=105";
              ResultSet rs42 = st.executeQuery(query);
              if (rs42.next()) {
                vShipperAccountNumber.addElement(rs42.getString("account_number"));
                vShipperUserName.addElement(rs42.getString("user_name"));
                vShipperPassword.addElement(rs42.getString("password"));
                vShipperXMLKey.addElement(rs42.getString("xml_key"));
                vShipperMeterNumber.addElement(rs42.getString("meter_number"));
              }
            }
            rs41.close();

            query = "SELECT MAX(pp.std_subvendor_hand) 'std_subvendor_hand' FROM product_prices pp, products p WHERE pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
            ResultSet rs5 = st.executeQuery(query);
            if(rs5.next()) {
              vSVFee.addElement(rs5.getString("std_subvendor_hand"));
            }
          }
        }
      }

      String shipper = "UPS";
      String shipType = "GROUND";
      String zipFrom = "";
      String zipFromState = "";
      String zipFromCountry = "";
      String zipTo = "";
      String zipToState = "";
      int zipToStateCode = 0;
      String zipToCountry = "";
      int id = 0;
      int quantity = 1;
      int numberOfBoxes = 0;
      int jobsQuantity = 0;
      int doNotBundleShipping = 0;
      int buildType = 0;
      int invProdFlag = 0;
      double invAmount = 0;
      double invOnOrderAmount = 0;
      double weight = 0;
      double maxWeight = 0;
      double height = 0;
      double maxHeight = 0;
      double length = 0;
      double maxLength = 0;
      double width = 0;
      double maxWidth = 0;
      double volume = 0;
      double maxVolume = 0;
      double paddingPercent = 0;
      double svFee = 0;
      ShipmentObject so = null;
      JobObject jo = null;


      // loop through warehouse & other vectors, create Shipment Objects & add them to Shopping Cart..
      for (int j = 0; j < vZipFrom.size(); j++) {
        // create Shipment Objects having non-zero weight..
        boolean sameWarehouse = false;
        zipFrom = (String) vZipFrom.get(j);
        zipFromState = (String) vZipFromState.get(j);
        zipFromCountry = (String) vZipFromCountry.get(j);
        zipTo = (String) vZipTo.get(j);
        zipToState = (String) vZipToState.get(j);
        zipToStateCode = (Integer) vZipToStateCode.get(j);
        zipToCountry = (String) vZipToCountry.get(j);
        jobsQuantity = (Integer) vJobsQuantity.get(j);
        //shipper = ?
        //shipType = ?
        try {
          doNotBundleShipping = Integer.parseInt((String) vDoNotBundleShipping.get(j));
          
        }
        catch (Exception e) {
          doNotBundleShipping = 0;
          System.out.println(e);
        }

        try {
          buildType = Integer.parseInt((String) vBuildtype.get(j));
        }
        catch (Exception e) {
          buildType = 0;
        }

        try {
          invProdFlag = Integer.parseInt((String) vInvProdFlag.get(j));
        }
        catch (Exception e) {
          invProdFlag = 0;
        }

        try {
          invAmount = Integer.parseInt((String) vInvAmount.get(j));
        }
        catch (Exception e) {
          invAmount = 0;
        }

        try {
          invOnOrderAmount = Integer.parseInt((String) vInvOnOrderAmount.get(j));
        }
        catch (Exception e) {
          invOnOrderAmount = 0;
        }

        shipments = shoppingCart.getShipments();
        boolean defaultOption = true;
        System.out.println("buildType : " + buildType);
        System.out.println("invAmount : " + invAmount);
        System.out.println("invOnOrderAmount : " + invOnOrderAmount);
        System.out.println("jobsQuantity : " + jobsQuantity);
        System.out.println("invProdFlag : " + invProdFlag);
        if (doNotBundleShipping == 1 || (getShipmentOption().equals("2") && ((buildType != 1) || ((invAmount - (invOnOrderAmount + jobsQuantity) <= 0) && invProdFlag == 1)))) {
          System.out.println("ship as they become available..");
          sameWarehouse = false;
          defaultOption = true;
          doNotBundleShipping=1;
        }
        else {  // shipmentOption = 1
          if (doNotBundleShipping == 1) {
            sameWarehouse = false;
          }
          else if (shipments.size() > 0) {
            id = shoppingCart.getCurrentShipment().getId();
            for (int jj = 0; jj < shipments.size(); jj++) {
                    so = (ShipmentObject) shipments.elementAt(jj);
                    if (so.getDoNotBundle() != 1) {
                        if (so.getWeight() == 0.00) {
                            Vector jobs = so.getJobs();
                            if (jobs.size() > 0) {
                              for (int jjj = 0; jjj < jobs.size(); jjj++) {
                                if (jobs.elementAt(jjj).equals(vJobs.get(j))) {
                                  sameWarehouse = true;
                                  break;
                                }
                              }
                            }
                            break;
                          }
                          else if (zipFrom.equals(so.getZipFrom())) {
                            // same warehouse..
                            sameWarehouse = true;
                            boolean sameJob = false;
                            Vector jobs = so.getJobs();
                            if (jobs.size() > 0) {
                              for (int jjj = 0; jjj < jobs.size(); jjj++) {
                                if (jobs.elementAt(jjj).equals(vJobs.get(j))) {
                                  sameJob = true;
                                  break;
                                }
                                else {
                                  continue;
                                }
                              }
                            }

                            if (!sameJob) {

                              numberOfBoxes = Integer.parseInt((String) vNumberOfBoxes.get(j));
                              so.setWeight(so.getWeight() + (numberOfBoxes * Double.parseDouble((String) vWeight.get(j))));
                              height = Double.parseDouble((String) vHeight.get(j));
                              width = Double.parseDouble((String) vWidth.get(j));
                              length = Double.parseDouble((String) vLength.get(j));
                              so.setVolume(so.getVolume() + (numberOfBoxes * height * width * length));
                              so.addJob((JobObject) vJobs.get(j));
                              ((JobObject) vJobs.get(j)).setShipmentId(so.getId());
                              double svFee1 = Double.parseDouble((String) vSVFee.get(j));
                              so.setSVFee(Math.max(svFee1, so.getSVFee()));
                              so.addProjectId((Integer) vProjectId.get(j));
                            }
                            break;
                          }
                          }else{
                             	sameWarehouse=false;
               
                          }

                  }
                }
        }
        if (!sameWarehouse) {
          // different warehouse..
          numberOfBoxes = Integer.parseInt((String) vNumberOfBoxes.get(j));
          weight = numberOfBoxes * Double.parseDouble((String) vWeight.get(j));
          height = Double.parseDouble((String) vHeight.get(j));
          width = Double.parseDouble((String) vWidth.get(j));
          length = Double.parseDouble((String) vLength.get(j));
          volume = (numberOfBoxes * height * width * length);
          so = new ShipmentObject(com.marcomet.tools.Indexer.getNextId("shipments"), zipFrom, zipFromState, zipFromCountry, zipTo, zipToState, zipToStateCode, zipToCountry, quantity, weight, height, length, width, volume, shipper, shipType, svFee);
          shoppingCart.addShipment(so);
          so.setDoNotBundle(doNotBundleShipping);
          so.addJob((JobObject) vJobs.get(j));
          ((JobObject) vJobs.get(j)).setShipmentId(so.getId());
          so.addProjectId((Integer) vProjectId.get(j));
          so.setSVFee(Double.parseDouble((String) vSVFee.get(j)));
          so.setMaxWeight(Double.parseDouble((String) vMaxWeight.get(j)));
          so.setMaxHeight(Double.parseDouble((String) vMaxHeight.get(j)));
          so.setMaxWidth(Double.parseDouble((String) vMaxWidth.get(j)));
          so.setMaxLength(Double.parseDouble((String) vMaxLength.get(j)));
          so.setMaxVolume(so.getMaxHeight() * so.getMaxWidth() * so.getMaxLength());
          so.setPaddingPercent(Double.parseDouble((String) vPaddingPercent.get(j)));
          so.setShipperAccountNumber((String) vShipperAccountNumber.get(j));
          so.setShipperMeterNumber((String) vShipperMeterNumber.get(j));
          so.setShipperPassword((String) vShipperPassword.get(j));
          so.setShipperUserName((String) vShipperUserName.get(j));
          so.setWarehouseId((String) vWarehouseId.get(j));
          so.setShipperXMLKey((String) vShipperXMLKey.get(j));
        }
      }

      // calculate the shipping cost for individual Shipment Objects..
      for (int jj = 0; jj < shoppingCart.getShipments().size(); jj++) {
        so = (ShipmentObject) shoppingCart.getShipments().elementAt(jj);
        if (so.getWeight() != 0.00) {
          so.setHeight(so.getMaxHeight());
          so.setWidth(so.getMaxWidth());
          so.setLength(so.getMaxLength());
          createShipmentBox(so);
        }
      //so.calculateShippingCost();
      }
    }
    catch (ClassNotFoundException ex) {
      Logger.getLogger(CatalogShipmentCreationServlet.class.getName()).log(Level.SEVERE, null, ex);
    }
    catch (Exception ex) {
      Logger.getLogger(CatalogShipmentCreationServlet.class.getName()).log(Level.SEVERE, null, ex);
    }
  }

  public void createShipment(String contactId, ShoppingCart shoppingCart, String sitehostId) {
	    try {
	      String productId = null;
	      //String contactId = null;
	      String amount = "0";

	      Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
	      Statement st = conn.createStatement();
	      String query = "";
	      //String sitehostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();
	      //ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("shoppingCart");
	      Vector shipments = shoppingCart.getShipments();
	      System.out.println("shipment size : " + shipments.size());
	      if (shipments.size() > 0) {
	        for (int i = 0; i < shipments.size(); i++) {
	          shoppingCart.removeShipment(0);
	        }
	      }
	      Vector projects = shoppingCart.getProjects();
	      if (projects.size() > 0) {
	        for (int i = 0; i < projects.size(); i++) {
	          int ii = i + 1;
	          System.out.println("project count: " + ii);
	          ProjectObject po = (ProjectObject) projects.elementAt(i);
	          int projectId = po.getId();
	          Vector jobs = po.getJobs();
	          for (int j = 0; j < jobs.size(); j++) {
	            int jj = j + 1;
	            System.out.println("job count: " + jj);
	            JobObject jo = (JobObject) jobs.elementAt(j);
	            JobSpecObject jsoProductCode = (JobSpecObject) jo.getJobSpecs().get("9001");
	            query = "SELECT id FROM products WHERE prod_code='" + jsoProductCode.getValue() + "'";
	            ResultSet rs = st.executeQuery(query);
	            if (rs.next()) {
	              productId = rs.getString("id");
	            }
	            rs.close();
	            //contactId = (String) session.getAttribute("contactId");
	            JobSpecObject jsoQuantity = (JobSpecObject) jo.getJobSpecs().get("705");
	            amount = jsoQuantity.getValue();

	            //query = "SELECT cl.zip 'zipFrom', p.build_type, w.ship_box_max_weight 'maxWeight', w.ship_box_height 'maxHeight', w.ship_box_length 'maxLength', w.ship_box_width 'maxWidth' FROM company_locations cl, warehouses w, products p WHERE cl.id=w.location_id AND w.id=p.default_warehouse_id AND p.id=" + productId + " AND p.do_not_bundle_shipping!=1 ORDER BY cl.zip, p.build_type";
	            //query = "SELECT cl.zip 'zipFrom', lus.state_abreviation 'zipFromState', luc.value 'zipFromCountry', p.build_type, w.ship_box_max_weight 'maxWeight', w.ship_box_height 'maxHeight', w.ship_box_length 'maxLength', w.ship_box_width 'maxWidth', w.box_padding_percent 'paddingPercent' FROM company_locations cl, warehouses w, lu_states lus, lu_countries luc, products p left join product_price_codes ppc on ppc.prod_price_code=p.prod_price_code left join vendors v on v.id=ppc.dropship_vendor WHERE cl.id=w.location_id AND if(p.default_warehouse_id is not null and p.default_warehouse_id>0, w.id=p.default_warehouse_id,w.id=v.default_warehouse_id) AND p.id=" + productId + " AND p.do_not_bundle_shipping!=1 AND cl.state=lus.id AND cl.country_id=luc.id ORDER BY cl.zip, p.build_type";
	            query = "SELECT cl.zip 'zipFrom', lus.state_abreviation 'zipFromState', luc.value 'zipFromCountry', p.build_type 'buildType', p.inventory_product_flag 'invProdFlag', p.inventory_amount 'invAmount', p.inv_on_order_amount 'invOnOrderAmount', p.do_not_bundle_shipping 'doNotBundle', w.ship_box_max_weight 'maxWeight', w.ship_box_height 'maxHeight', w.ship_box_length 'maxLength', w.ship_box_width 'maxWidth', w.box_padding_percent 'paddingPercent' FROM company_locations cl, warehouses w, lu_states lus, lu_countries luc, products p left join product_price_codes ppc on ppc.prod_price_code=p.prod_price_code left join vendors v on v.id=ppc.dropship_vendor WHERE cl.id=w.location_id AND if(p.default_warehouse_id is not null and p.default_warehouse_id>0, w.id=p.default_warehouse_id,w.id=v.default_warehouse_id) AND p.id=" + productId + " AND cl.state=lus.id AND cl.country_id=luc.id ORDER BY cl.zip, p.build_type,do_not_bundle_shipping";
	            ResultSet rs1 = st.executeQuery(query);
	            if (rs1.next()) {
	              vZipFrom.addElement(rs1.getString("zipFrom"));
	              vZipFromState.addElement(rs1.getString("zipFromState"));
	              vZipFromCountry.addElement(rs1.getString("zipFromCountry"));
	              vBuildtype.addElement(rs1.getString("buildType"));
	              vInvProdFlag.addElement(rs1.getString("invProdFlag"));
	              vInvAmount.addElement(rs1.getString("invAmount"));
	              vInvOnOrderAmount.addElement(rs1.getString("invOnOrderAmount"));
	              vDoNotBundleShipping.addElement(rs1.getString("doNotBundle"));
	              vMaxWeight.addElement(rs1.getString("maxWeight"));
	              vMaxHeight.addElement(rs1.getString("maxHeight"));
	              vMaxLength.addElement(rs1.getString("maxLength"));
	              vMaxWidth.addElement(rs1.getString("maxWidth"));
	              vPaddingPercent.addElement(rs1.getString("paddingPercent"));
	              vJobs.addElement(jo);
	              vJobsQuantity.addElement(jo.getQuantity());
	              vProjectId.addElement(projectId);
	              System.out.println("projectId in shipment object : " + po.getId());
	            }
	            rs1.close();

	            query = "SELECT l.zip 'zipTo', l.state 'zipToStateCode', lus.state_abreviation 'zipToState', luc.value 'zipToCountry' FROM shipping_locations l, contacts c, lu_states lus, lu_countries luc WHERE l.id="+shipLocationId+" AND l.contactid=c.id AND c.id=" + contactId + " AND l.state=lus.id AND l.country_id=luc.id";
	            ResultSet rs2 = st.executeQuery(query);
	            if (rs2.next()) {
	              vZipTo.addElement(rs2.getString("zipTo"));
	              vZipToState.addElement(rs2.getString("zipToState"));
	              vZipToStateCode.addElement(rs2.getInt("zipToStateCode"));
	              vZipToCountry.addElement(rs2.getString("zipToCountry"));
	            }
	            rs2.close();

	            query = "SELECT pp.weight_per_box 'weight', pp.length, pp.width, pp.height, pp.number_of_boxes 'boxes' FROM product_prices pp, products p WHERE pp.quantity=" + amount + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
	            ResultSet rs3 = st.executeQuery(query);
	            if (rs3.next()) {
	              vWeight.addElement(rs3.getString("weight"));
	              vLength.addElement(rs3.getString("length"));
	              vWidth.addElement(rs3.getString("width"));
	              vHeight.addElement(rs3.getString("height"));
	              vNumberOfBoxes.addElement(rs3.getString("boxes"));
	            }
	            rs3.close();

	            query = "SELECT DISTINCT sa.account_number, sa.user_name, sa.password, sa.xml_key, sa.meter_number FROM shipping_accounts sa, product_prices pp, products p WHERE sa.shipper_type='UPS' AND sa.vendor_id=pp.ds_vendor AND pp.quantity=" + amount + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
	            ResultSet rs41 = st.executeQuery(query);
	            if (rs41.next()) {
	              vShipperAccountNumber.addElement(rs41.getString("account_number"));
	              vShipperUserName.addElement(rs41.getString("user_name"));
	              vShipperPassword.addElement(rs41.getString("password"));
	              vShipperXMLKey.addElement(rs41.getString("xml_key"));
	              vShipperMeterNumber.addElement(rs41.getString("meter_number"));
	            }
	            else {
	              query = "SELECT DISTINCT account_number, user_name, password, xml_key, meter_number FROM shipping_accounts WHERE shipper_type='UPS' AND vendor_id=105";
	              ResultSet rs42 = st.executeQuery(query);
	              if (rs42.next()) {
	                vShipperAccountNumber.addElement(rs42.getString("account_number"));
	                vShipperUserName.addElement(rs42.getString("user_name"));
	                vShipperPassword.addElement(rs42.getString("password"));
	                vShipperXMLKey.addElement(rs42.getString("xml_key"));
	                vShipperMeterNumber.addElement(rs42.getString("meter_number"));
	              }
	            }
	            rs41.close();

	            query = "SELECT MAX(pp.std_subvendor_hand) 'std_subvendor_hand' FROM product_prices pp, products p WHERE pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
	            ResultSet rs5 = st.executeQuery(query);
	            if(rs5.next()) {
	              vSVFee.addElement(rs5.getString("std_subvendor_hand"));
	            }
	          }
	        }
	      }

	      String shipper = "UPS";
	      String shipType = "GROUND";
	      String zipFrom = "";
	      String zipFromState = "";
	      String zipFromCountry = "";
	      String zipTo = "";
	      String zipToState = "";
	      int zipToStateCode = 0;
	      String zipToCountry = "";
	      int id = 0;
	      int quantity = 1;
	      int numberOfBoxes = 0;
	      int jobsQuantity = 0;
	      int doNotBundleShipping = 0;
	      int buildType = 0;
	      int invProdFlag = 0;
	      double invAmount = 0;
	      double invOnOrderAmount = 0;
	      double weight = 0;
	      double maxWeight = 0;
	      double height = 0;
	      double maxHeight = 0;
	      double length = 0;
	      double maxLength = 0;
	      double width = 0;
	      double maxWidth = 0;
	      double volume = 0;
	      double maxVolume = 0;
	      double paddingPercent = 0;
	      double svFee = 0;
	      ShipmentObject so = null;
	      JobObject jo = null;

	      // loop through warehouse & other vectors, create Shipment Objects & add them to Shopping Cart..
	      for (int j = 0; j < vZipFrom.size(); j++) {
	    	 int doNotBundle=0;
	        // create Shipment Objects having non-zero weight..
	        boolean sameWarehouse = false;
	        zipFrom = (String) vZipFrom.get(j);
	        zipFromState = (String) vZipFromState.get(j);
	        zipFromCountry = (String) vZipFromCountry.get(j);
	        zipTo = (String) vZipTo.get(j);
	        zipToState = (String) vZipToState.get(j);
	        zipToStateCode = (Integer) vZipToStateCode.get(j);
	        zipToCountry = (String) vZipToCountry.get(j);
	        jobsQuantity = (Integer) vJobsQuantity.get(j);
	        //shipper = ?
	        //shipType = ?
	        try {
	          doNotBundleShipping = Integer.parseInt((String) vDoNotBundleShipping.get(j));
	        }
	        catch (Exception e) {
	          doNotBundleShipping = 0;
	        }

	        try {
	          buildType = Integer.parseInt((String) vBuildtype.get(j));
	        }
	        catch (Exception e) {
	          buildType = 0;
	        }

	        try {
	          invProdFlag = Integer.parseInt((String) vInvProdFlag.get(j));
	        }
	        catch (Exception e) {
	          invProdFlag = 0;
	        }

	        try {
	          invAmount = Integer.parseInt((String) vInvAmount.get(j));
	        }
	        catch (Exception e) {
	          invAmount = 0;
	        }

	        try {
	          invOnOrderAmount = Integer.parseInt((String) vInvOnOrderAmount.get(j));
	        }
	        catch (Exception e) {
	          invOnOrderAmount = 0;
	        }

	        shipments = shoppingCart.getShipments();
	        boolean defaultOption = true;

	        System.out.println("buildType : " + buildType);
	        System.out.println("invAmount : " + invAmount);
	        System.out.println("invOnOrderAmount : " + invOnOrderAmount);
	        System.out.println("jobsQuantity : " + jobsQuantity);
	        System.out.println("invProdFlag : " + invProdFlag);
	        if (doNotBundleShipping == 1 || (getShipmentOption().equals("2") && ((buildType != 1) || ((invAmount - (invOnOrderAmount + jobsQuantity) <= 0) && invProdFlag == 1)))) {
	          System.out.println("ship as they become available..");
	          sameWarehouse = false;
	          doNotBundle=1;
	          defaultOption = true;
	        } else {  // shipmentOption = 1
	        	if (doNotBundleShipping == 1) {
		            sameWarehouse = false;
		            doNotBundle = 1;
		          } else if (shipments.size() > 0) {
		            id = shoppingCart.getCurrentShipment().getId();
		            for (int jj = 0; jj < shipments.size(); jj++) {
		              so = (ShipmentObject) shipments.elementAt(jj);
		  	          System.out.println("Do not bundle:"+so.getDoNotBundle());
		              if(so.getDoNotBundle()==1){
		            	  sameWarehouse=false;
		            	  break;
		              }
		              if (so.getWeight() == 0.00) {
		                Vector jobs = so.getJobs();
		                if (jobs.size() > 0) {
		                  for (int jjj = 0; jjj < jobs.size(); jjj++) {
		                    if (jobs.elementAt(jjj).equals(vJobs.get(j))) {
		                      sameWarehouse = true;
		                      break;
		                    }
		                  }
		                }
		                break;
		              } else if (zipFrom.equals(so.getZipFrom())) {
			                // same warehouse..
			                sameWarehouse = true;
			                boolean sameJob = false;
			                Vector jobs = so.getJobs();
			                if (jobs.size() > 0) {
			                  for (int jjj = 0; jjj < jobs.size(); jjj++) {
			                    if (jobs.elementAt(jjj).equals(vJobs.get(j))) {
			                      sameJob = true;
			                      break;
			                    } else {
			                      continue;
			                    }
			                  }
			                }

	                if (!sameJob) {
	                	if(so.getDoNotBundle()==1){
	                		sameWarehouse=false;
	                		break;
	                	}
	                  numberOfBoxes = Integer.parseInt((String) vNumberOfBoxes.get(j));
	                  so.setWeight(so.getWeight() + (numberOfBoxes * Double.parseDouble((String) vWeight.get(j))));
	                  height = Double.parseDouble((String) vHeight.get(j));
	                  width = Double.parseDouble((String) vWidth.get(j));
	                  length = Double.parseDouble((String) vLength.get(j));
	                  so.setVolume(so.getVolume() + (numberOfBoxes * height * width * length));
	                  so.addJob((JobObject) vJobs.get(j));
	                  ((JobObject) vJobs.get(j)).setShipmentId(so.getId());
	                  double svFee1 = Double.parseDouble((String) vSVFee.get(j));
	                  so.setSVFee(Math.max(svFee1, so.getSVFee()));
	                  so.addProjectId((Integer) vProjectId.get(j));
	                }
	                break;
	              }
	            }
	          }
	        }
	        if (!sameWarehouse) {
	          // different warehouse..
	          numberOfBoxes = Integer.parseInt((String) vNumberOfBoxes.get(j));
	          weight = numberOfBoxes * Double.parseDouble((String) vWeight.get(j));
	          height = Double.parseDouble((String) vHeight.get(j));
	          width = Double.parseDouble((String) vWidth.get(j));
	          length = Double.parseDouble((String) vLength.get(j));
	          volume = (numberOfBoxes * height * width * length);
	          so = new ShipmentObject(com.marcomet.tools.Indexer.getNextId("shipments"), zipFrom, zipFromState, zipFromCountry, zipTo, zipToState, zipToStateCode, zipToCountry, quantity, weight, height, length, width, volume, shipper, shipType, svFee);
	          shoppingCart.addShipment(so);
	          so.setDoNotBundle(doNotBundle);
	          so.addJob((JobObject) vJobs.get(j));
	          ((JobObject) vJobs.get(j)).setShipmentId(so.getId());
	          so.addProjectId((Integer) vProjectId.get(j));
	          so.setSVFee(Double.parseDouble((String) vSVFee.get(j)));
	          so.setMaxWeight(Double.parseDouble((String) vMaxWeight.get(j)));
	          so.setMaxHeight(Double.parseDouble((String) vMaxHeight.get(j)));
	          so.setMaxWidth(Double.parseDouble((String) vMaxWidth.get(j)));
	          so.setMaxLength(Double.parseDouble((String) vMaxLength.get(j)));
	          so.setMaxVolume(so.getMaxHeight() * so.getMaxWidth() * so.getMaxLength());
	          so.setPaddingPercent(Double.parseDouble((String) vPaddingPercent.get(j)));
	          so.setShipperAccountNumber((String) vShipperAccountNumber.get(j));
	          so.setShipperMeterNumber((String) vShipperMeterNumber.get(j));
	          so.setShipperPassword((String) vShipperPassword.get(j));
	          so.setShipperUserName((String) vShipperUserName.get(j));
	          so.setShipperXMLKey((String) vShipperXMLKey.get(j));
	        }
	      }

	      // calculate the shipping cost for individual Shipment Objects..
	      for (int jj = 0; jj < shoppingCart.getShipments().size(); jj++) {
	        so = (ShipmentObject) shoppingCart.getShipments().elementAt(jj);
	        if (so.getWeight() != 0.00) {
	          so.setHeight(so.getMaxHeight());
	          so.setWidth(so.getMaxWidth());
	          so.setLength(so.getMaxLength());

	          createShipmentBox(so);
	        }
	      //so.calculateShippingCost();
	      }
	    }
	    catch (ClassNotFoundException ex) {
	      Logger.getLogger(CatalogShipmentCreationServlet.class.getName()).log(Level.SEVERE, null, ex);
	    }
	    catch (Exception ex) {
	      Logger.getLogger(CatalogShipmentCreationServlet.class.getName()).log(Level.SEVERE, null, ex);
	    }
	  }
  
  public void createShipmentBox(ShipmentObject so) {
    try {
      String productId = null;
      String warehouseId="";
      String amount = "0";
      double units=1;
      Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
      Statement st = conn.createStatement();
      String query = "";
      double[][] packs;
      String[] jobName;
      double weight = 0, length = 0, height = 0, width = 0, volume = 0, numberOfBoxes = 0;

      // create packs array..
      Vector jobs = so.getJobs();
      packs = new double[jobs.size()][4];
      jobName = new String[jobs.size()];
      for (int i = 0; i < jobs.size(); i++) {
        JobObject jo = (JobObject) jobs.elementAt(i);

        JobSpecObject jsoProductCode = (JobSpecObject) jo.getJobSpecs().get("9001");
        query = "SELECT id FROM products WHERE prod_code='" + jsoProductCode.getValue() + "'";
        ResultSet rs = st.executeQuery(query);
        if (rs.next()) {
          productId = rs.getString("id");
        }
        rs.close();
        JobSpecObject jsoQuantity = (JobSpecObject) jo.getJobSpecs().get("705");
        amount = jsoQuantity.getValue();

        query = "SELECT pp.weight_per_box 'weight', pp.length, pp.height, pp.width, pp.number_of_boxes 'boxes',pp.units_per_box 'units',concat('Build Type: ',p.build_type) as 'buildType',if(p.inventory_product_flag=0 || (inv_on_order_amount - inventory_amount - " + amount + ")>0,'BO Status: Shipping','BO Status: On Backorder') as backOrderStatus FROM product_prices pp, products p WHERE pp.quantity=" + amount + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
        ResultSet rs1 = st.executeQuery(query);
        if (rs1.next()) {
          weight = Double.parseDouble(rs1.getString("weight"));
          length = Double.parseDouble(rs1.getString("length"));
          height = Double.parseDouble(rs1.getString("height"));
          width = Double.parseDouble(rs1.getString("width"));
          numberOfBoxes = Integer.parseInt(rs1.getString("boxes"));
          units = ((rs1.getString("units")==null || rs1.getString("units").equals("0"))?(Integer.parseInt(amount)/numberOfBoxes):rs1.getDouble("units"));
          volume = length * height * width;
        }
        rs1.close();

        packs[i][0] = weight;
        packs[i][1] = volume;
        packs[i][2] = numberOfBoxes;
        packs[i][3] = units;
        jobName[i] = jo.getJobName();
      }

      // sort packs array by weight..
      double[][] tempPacks = new double[packs.length][packs[0].length];
      String[] tempJobName = new String[jobName.length];
      boolean done = false;
      while (!done) {
        done = true;
        for (int i = 0; i < packs.length - 1; i++) {
          if (packs[i][0] < packs[i + 1][0]) {
            for (int j = 0; j < packs[i].length; j++) {
              tempPacks[i][j] = packs[i][j];
              packs[i][j] = packs[i + 1][j];
              packs[i + 1][j] = tempPacks[i][j];
              if (j == 0) {
                tempJobName[i] = jobName[i];
                jobName[i] = jobName[i + 1];
                jobName[i + 1] = tempJobName[i];
              }
            }
            done = false;
          }
        }
      }

      ShipmentBoxObject sbo = null;
      int qty1 = (int) Math.ceil(so.getVolume() / so.getMaxVolume());
      int qty2 = (int) Math.ceil(so.getWeight() / so.getMaxWeight());
      int quantity = Math.max(qty1, qty2);
      if (quantity < so.getShipmentBoxes().size()) {
        quantity = so.getShipmentBoxes().size();
      }

      // create shipment box object..
      for (int k = 0; k < quantity; k++) {
        boolean sameBox = false;
        Vector boxes = so.getShipmentBoxes();
        warehouseId=so.getWarehouseId();
        if (boxes.size() > 0) {
          for (int kk = 0; kk < boxes.size(); kk++) {
            sbo = (ShipmentBoxObject) boxes.elementAt(kk);
            if (sbo.getBoxNumber() == (k + 1)) {
              sameBox = true;
              sbo.setVolume(0);
              sbo.setWeight(0);
              sbo.setContents("");
              break;
            }
            else {
              continue;
            }
          }
        }
        if (!sameBox) {
          sbo = new ShipmentBoxObject();
          sbo.setId( com.marcomet.tools.Indexer.getNextId("shipment_boxes"));
          sbo.setBoxNumber(k + 1);
          sbo.setShipmentId(so.getId());
          sbo.setHeight(0);
          sbo.setWidth(0);
          sbo.setLength(0);
          sbo.setVolume(0);
          sbo.setWeight(0);
          sbo.setContents("");
          sbo.setPaddingPercent(so.getPaddingPercent());
          so.addShipmentBox(sbo);
        }
      }

      int qty = 1;
      int[] counter = new int[quantity];
      for (int i = 0; i < counter.length; i++) {
        counter[i] = 1;
      }

      for (int i = 0; i < packs.length; i++) {      // No. of Jobs..
        for (int j = 0; j < packs[i][2]; j++) {     // No. of Packs of a particular Job..
          boolean needMoreBox = true;

          //assign weight & contents to box..
          for (int k = qty - 1; k < quantity; k++) {
            sbo = so.getShipmentBox(k + 1);

            if (((sbo.getWeight() + packs[i][0]) < so.getMaxWeight()) && ((sbo.getVolume() + packs[i][1]) < so.getMaxVolume())) {
              qty = k + 1;
              needMoreBox = false;
              sbo.setVolume(sbo.getVolume() + packs[i][1]);
              sbo.setWeight(sbo.getWeight() + packs[i][0]);
              double variableSize = sbo.getVolume() + (sbo.getVolume() * (sbo.getPaddingPercent() / 100));
              double dimension = Math.cbrt(variableSize);
              String dim = new DecimalFormat("#0.00").format(dimension);
              dimension = Double.parseDouble(dim);
              sbo.setHeight(dimension);
              sbo.setWidth(dimension);
              sbo.setLength(dimension);

              if (sbo.getContents() != null && sbo.getContents().contains(jobName[i])) {
                if (sbo.getContents().contains("Warehouse ID:"+warehouseId+" | " + counter[k] + " Pack(s) of " + packs[i][3]+" " + jobName[i])) {
                  sbo.setContents(sbo.getContents().replace("Warehouse ID:"+warehouseId+" | " + counter[k] + " Pack(s) of " + packs[i][3]+" " + jobName[i], ""));
                }
                else if (sbo.getContents().contains("Warehouse ID:"+warehouseId+" | " + counter[k] + " | Pack(s) of " + packs[i][3]+" " + jobName[i])) {
                  sbo.setContents(sbo.getContents().replace("Warehouse ID:"+warehouseId+" | " + counter[k] + " | Pack(s) of " + packs[i][3]+" " + jobName[i], ""));
                }
                counter[k]++;
              }

              if (sbo.getContents() != null && !(sbo.getContents().equals(""))) {
                sbo.setContents(sbo.getContents() + " | Warehouse ID:"+warehouseId+" | " + counter[k] + " Pack(s) of " + packs[i][3]+" "+jobName[i]);
              }
              else {
                sbo.setContents("Warehouse ID:"+warehouseId+" | "+counter[k] +" Pack(s) of " + packs[i][3]+" " + jobName[i]);
              }
              break;
            }
            else {
              continue;
            }
          }

          if (needMoreBox) {
            int boxNumber = so.getCurrentShipmentBox().getBoxNumber();
            quantity++;
            qty = quantity;
            int[] newCounter = new int[quantity];
            System.arraycopy(counter, 0, newCounter, 0, counter.length);
            for (int l = counter.length; l < quantity; l++) {
              newCounter[l] = 1;
            }
            counter = newCounter;
            sbo = new ShipmentBoxObject();
            sbo.setId( com.marcomet.tools.Indexer.getNextId("shipment_boxes"));
            sbo.setBoxNumber(boxNumber + 1);
            sbo.setShipmentId(so.getId());
            sbo.setHeight(so.getHeight());
            sbo.setWidth(so.getWidth());
            sbo.setLength(so.getLength());
            sbo.setWeight(0);
            sbo.setContents("");
            sbo.setPaddingPercent(so.getPaddingPercent());
            so.addShipmentBox(sbo);

            if (((sbo.getWeight() + packs[i][0]) < so.getMaxWeight()) && ((sbo.getVolume() + packs[i][1]) < so.getMaxVolume())) {
              sbo.setVolume(sbo.getVolume() + packs[i][1]);
              sbo.setWeight(sbo.getWeight() + packs[i][0]);
              double variableSize = sbo.getVolume() + (sbo.getVolume() * (sbo.getPaddingPercent() / 100));
              double dimension = Math.cbrt(variableSize);
              String dim = new DecimalFormat("#0.00").format(dimension);
              dimension = Double.parseDouble(dim);
              sbo.setHeight(dimension);
              sbo.setWidth(dimension);
              sbo.setLength(dimension);

              if (sbo.getContents() != null && sbo.getContents().contains(jobName[i])) {
                if (sbo.getContents().contains("Warehouse ID:"+warehouseId+" | " + counter[qty - 1] + " Pack(s) of " + packs[i][3]+" " + jobName[i])) {
                  sbo.setContents(sbo.getContents().replace("Warehouse ID:"+warehouseId+" | " + counter[qty - 1] + " Pack(s) of " + packs[i][3]+" " + jobName[i], ""));
                }
                else if (sbo.getContents().contains("Warehouse ID:"+warehouseId+" | "+counter[qty - 1] + " Pack(s) of " + packs[i][3]+" " + jobName[i])) {
                  sbo.setContents(sbo.getContents().replace("Warehouse ID:"+warehouseId+" | "+counter[qty - 1] + " Pack(s) of " + packs[i][3]+" " + jobName[i], ""));
                }
                counter[qty - 1]++;
              }

              if (sbo.getContents() != null && !(sbo.getContents().equals(""))) {
                sbo.setContents(sbo.getContents() + "Warehouse ID:"+warehouseId+" | " + counter[qty - 1] + " Pack(s) of " + packs[i][3]+" " + jobName[i]);
              }
              else {
                sbo.setContents("Warehouse ID:"+warehouseId+" | "+counter[qty - 1] + " Pack(s) of " + packs[i][3]+" " + jobName[i]);
              }
            }
          }

          if (qty < quantity) {
            qty++;
          }
          else {
            qty = 1;
          }
        }
      }

      // single-pack shipment..
      Vector boxes = so.getShipmentBoxes();
      if (boxes.size() > 0) {
        for (int i = 0; i < boxes.size(); i++) {
          sbo = (ShipmentBoxObject) boxes.elementAt(i);
          String contents = sbo.getContents();
          String str = "Pack(s) of";
          int strCnt = 0, strLen = str.length();
          if (strLen > 0) {
            int start = contents.indexOf(str);
            while (start != -1) {
              strCnt++;
              start = contents.indexOf(str, start + strLen);
            }
          }
          if (strCnt == 1) {
            // Box has Packs of only 1 Job..
            int count = Integer.parseInt(contents.substring(("Warehouse ID:"+warehouseId+" | ").length(), contents.indexOf("Pack(s) of")).trim());
            if (count == 1) {
              // Box has only 1 Pack of Job..
              String prodCode = contents.substring(contents.indexOf("Pack(s) of") + 11, contents.indexOf(" - "));
              query = "SELECT DISTINCT pp.length, pp.height, pp.width FROM product_prices pp, products p WHERE pp.weight_per_box=" + sbo.getWeight() + " AND pp.prod_price_code=p.prod_price_code AND p.prod_code='" + prodCode + "'";
              ResultSet rs = st.executeQuery(query);
              if (rs.next()) {
                sbo.setLength(Double.parseDouble(rs.getString("length")));
                sbo.setHeight(Double.parseDouble(rs.getString("height")));
                sbo.setWidth(Double.parseDouble(rs.getString("width")));
              }
              rs.close();
            }
          }
        }
      }
    }
    catch (ClassNotFoundException ex) {
      Logger.getLogger(CatalogShipmentCreationServlet.class.getName()).log(Level.SEVERE, null, ex);
    }
    catch (Exception ex) {
      Logger.getLogger(CatalogShipmentCreationServlet.class.getName()).log(Level.SEVERE, null, ex);
    }
  }

  public void doPost(HttpServletRequest request, HttpServletResponse response) {
    createShipment(request.getSession());
  }
}
