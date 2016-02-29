package com.marcomet.catalog;

import com.marcomet.commonprocesses.ProcessShippingCost;
import com.marcomet.environment.SiteHostSettings;
import java.sql.*;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.lang.*;
import java.text.DecimalFormat;
import javax.servlet.http.HttpServletRequest;

public class ShipmentObject {

  private String zipFrom,  zipFromState,  zipFromCountry,  zipTo,  zipToState,  zipToCountry,  shipper,  shipType,  shipperAccountNumber,  shipperUserName,  shipperPassword,  shipperXMLKey,  shipperMeterNumber,  handlingQuery,warehouseId,shipmentNotes;
  private int id,  quantity,  zipToStateCode,doNotBundle;
  private int svFeeSplit=0;
  private double weight,  maxWeight,  height,  maxHeight,  length,  maxLength,  width,  maxWidth,  volume,  maxVolume,  paddingPercent,  calculatedShipPrice,calculatedShipPriceFull,calculatedShipPriceDisc,  handlingCost,  svFee,  mcFee, shippingPrice;
  private Vector jobs,  shipmentBoxes,  projectIds;

  public ShipmentObject() {
    jobs = new Vector();
    shipmentBoxes = new Vector();
    projectIds = new Vector();
  }

  public ShipmentObject(int id, String zipFrom, String zipFromState, String zipFromCountry, String zipTo, String zipToState, int zipToStateCode, String zipToCountry, int quantity, double weight, double height, double length, double width, double volume, String shipper, String shipType, double svFee) {
    this.id = id;
    this.zipFrom = zipFrom;
    this.zipFromState = zipFromState;
    this.zipFromCountry = zipFromCountry;
    this.zipTo = zipTo;
    this.zipToState = zipToState;
    this.zipToStateCode = zipToStateCode;
    this.zipToCountry = zipToCountry;
    this.quantity = quantity;
    this.weight = weight;
    this.height = height;
    this.length = length;
    this.width = width;
    this.volume = volume;
    this.shipper = shipper;
    this.shipType = shipType;
    this.svFee = svFee;
    this.svFeeSplit = svFeeSplit;
    jobs = new Vector();
    shipmentBoxes = new Vector();
    projectIds = new Vector();
  }

  public void addJob(JobObject jo) {
    if (jobs == null) {
      jobs = new Vector();
    }
    jobs.addElement(jo);
  }

  public void addShipmentBox(ShipmentBoxObject sbo) {
    if (shipmentBoxes == null) {
      shipmentBoxes = new Vector();
    }
    shipmentBoxes.addElement(sbo);
  }

  public void addProjectId(int pId) {
    if (projectIds == null) {
      projectIds = new Vector();
    }
    projectIds.addElement(pId);
  }

  public Vector getJobs() {
    return (Vector) jobs.clone();
  }

  public Vector getShipmentBoxes() {
    return (Vector) shipmentBoxes.clone();
  }

  public JobObject getJob(int id) {
    for (int i = 0; i < jobs.size(); i++) {
      JobObject jo = (JobObject) jobs.elementAt(i);
      if (jo.getId() == id) {
        return jo;
      }
    }
    return null;
  }

  public ShipmentBoxObject getShipmentBox(int boxNumber) {
    for (int i = 0; i < shipmentBoxes.size(); i++) {
      ShipmentBoxObject sbo = (ShipmentBoxObject) shipmentBoxes.elementAt(i);
      if (sbo.getBoxNumber() == boxNumber) {
        return sbo;
      }
    }
    return null;
  }

  public int getProjectId(int index) {
    return (Integer) projectIds.elementAt(index);
  }

  public JobObject getCurrentJob() {
    if (jobs.size() > 0) {
      return (JobObject) jobs.lastElement();
    }
    else {
      return null;
    }
  }

  public ShipmentBoxObject getCurrentShipmentBox() {
    if (shipmentBoxes.size() > 0) {
      return (ShipmentBoxObject) shipmentBoxes.lastElement();
    }
    else {
      return null;
    }
  }

  public double getCalculatedShipPrice() {
    return calculatedShipPrice;
  }

  public double getHeight() {
    return height;
  }

  public int getId() {
    return id;
  }

  public double getLength() {
    return length;
  }

  public double getMaxHeight() {
    return maxHeight;
  }

  public double getMaxLength() {
    return maxLength;
  }

  public double getMaxVolume() {
    return maxVolume;
  }

  public double getMaxWeight() {
    return maxWeight;
  }

  public double getMaxWidth() {
    return maxWidth;
  }

  public double getPaddingPercent() {
    return paddingPercent;
  }

  public int getQuantity() {
    return quantity;
  }

  public String getShipType() {
    return shipType;
  }

  public String getShipper() {
    return shipper;
  }

  public String getShipperAccountNumber() {
    return shipperAccountNumber;
  }

  public String getShipperMeterNumber() {
    return shipperMeterNumber;
  }

  public String getShipperPassword() {
    return shipperPassword;
  }

  public String getShipperUserName() {
    return shipperUserName;
  }

  public String getShipperXMLKey() {
    return shipperXMLKey;
  }

  public double getShippingPrice() {
    return shippingPrice;
  }

  public double getHandlingCost() {
    return handlingCost;
  }

  public String getHandlingQuery() {
    return handlingQuery;
  }

  public double getMCFee() {
    return mcFee;
  }

  public double getSVFee() {
    return svFee;
  }

  public double getVolume() {
    return volume;
  }

  public double getWeight() {
    return weight;
  }

  public double getWidth() {
    return width;
  }

  public String getZipFrom() {
    return zipFrom;
  }

  public String getZipFromState() {
    return zipFromState;
  }

  public String getZipFromCountry() {
    return zipFromCountry;
  }

  public String getZipTo() {
    return zipTo;
  }

  public String getZipToState() {
    return zipToState;
  }

  public int getZipToStateCode() {
    return zipToStateCode;
  }

  public String getZipToCountry() {
    return zipToCountry;
  }

  public void removeJob(int index) {
    jobs.removeElementAt(index);
  }

  public void removeShipmenBox(int index) {
    shipmentBoxes.removeElementAt(index);
  }

  public void setCalculatedShipPrice(double calculatedShipPrice) {
    this.calculatedShipPrice = calculatedShipPrice;
  }

  public void setHeight(double height) {
    this.height = height;
  }

  public void setId(int id) {
    this.id = id;
  }

  public void setLength(double length) {
    this.length = length;
  }

  public void setMaxHeight(double maxHeight) {
    this.maxHeight = maxHeight;
  }

  public void setMaxLength(double maxLength) {
    this.maxLength = maxLength;
  }

  public void setMaxVolume(double maxVolume) {
    this.maxVolume = maxVolume;
  }

  public void setMaxWeight(double maxWeight) {
    this.maxWeight = maxWeight;
  }

  public void setMaxWidth(double maxWidth) {
    this.maxWidth = maxWidth;
  }

  public void setPaddingPercent(double paddingPercent) {
    this.paddingPercent = paddingPercent;
  }

  public void setQuantity(int quantity) {
    this.quantity = quantity;
  }

  public void setShipType(String shipType) {
    this.shipType = shipType;
  }

  public void setShipper(String shipper) {
    this.shipper = shipper;
  }

  public void setShipperAccountNumber(String shipperAccountNumber) {
    this.shipperAccountNumber = shipperAccountNumber;
  }

  public void setShipperMeterNumber(String shipperMeterNumber) {
    this.shipperMeterNumber = shipperMeterNumber;
  }

  public void setShipperPassword(String shipperPassword) {
    this.shipperPassword = shipperPassword;
  }

  public void setShipperUserName(String shipperUserName) {
    this.shipperUserName = shipperUserName;
  }

  public void setShipperXMLKey(String shipperXMLKey) {
    this.shipperXMLKey = shipperXMLKey;
  }

  public void setShippingPrice(double shippingPrice) {
    this.shippingPrice = shippingPrice;
  }

  public void setHandlingCost(double handlingCost) {
    this.handlingCost = handlingCost;
  }

  public void setMCFee(double mcFee) {
    this.mcFee = mcFee;
  }

  public void setSVFee(double svFee) {
    this.svFee = svFee;
  }

  public void setVolume(double volume) {
    this.volume = volume;
  }

  public void setWeight(double weight) {
    this.weight = weight;
  }

  public void setWidth(double width) {
    this.width = width;
  }

  public void setZipFrom(String zipFrom) {
    this.zipFrom = zipFrom;
  }

  public void setZipFromState(String zipFromState) {
    this.zipFromState = zipFromState;
  }

  public void setZipFromCountry(String zipFromCountry) {
    this.zipFromCountry = zipFromCountry;
  }

  public void setZipTo(String zipTo) {
    this.zipTo = zipTo;
  }

  public void setZipToState(String zipToState) {
    this.zipToState = zipToState;
  }

  public void setZipToStateCode(int zipToStateCode) {
    this.zipToStateCode = zipToStateCode;
  }

  public void setZipToCountry(String zipToCountry) {
    this.zipToCountry = zipToCountry;
  }

  public void calculateShippingCost(HttpServletRequest request) {
		System.out.println("Step 1");
    ProcessShippingCost shipping = new ProcessShippingCost();

    shipping.setShipperAccountNumber(this.shipperAccountNumber);
    if (this.shipper.equalsIgnoreCase("UPS")) {
      shipping.setUpsXMLAccessKey(this.shipperXMLKey);
      shipping.setUpsUserName(this.shipperUserName);
      shipping.setUpsPassword(this.shipperPassword);
    }
    else if (this.shipper.equalsIgnoreCase("FEDEX")) {
      shipping.setFdxMeterNumber(this.shipperMeterNumber);
    }
    shipping.setZipFrom(this.zipFrom);
    shipping.setZipFromState(this.zipFromState);
    shipping.setZipFromCountry(this.zipFromCountry);
    shipping.setZipTo(this.zipTo);
    shipping.setZipToState(this.zipToState);
    shipping.setZipToCountry(this.zipToCountry);
    String sitehostid=((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId();
    shipping.setSitehostid(sitehostid);

    this.calculatedShipPrice = 0.00;
    this.calculatedShipPriceFull = 0.00;
    this.calculatedShipPriceDisc = 0.00;
    ShipmentBoxObject sbo = null;
    Vector boxes = this.getShipmentBoxes();
    if (boxes.size() > 0) {
      for (int i = 0; i < boxes.size(); i++) {
        sbo = (ShipmentBoxObject) boxes.elementAt(i);
        shipping.setWeight(String.valueOf(sbo.getWeight()));
        shipping.setQuantity(String.valueOf(1));
        shipping.setLength(String.valueOf(sbo.getLength()));
        shipping.setWidth(String.valueOf(sbo.getWidth()));
        shipping.setHeight(String.valueOf(sbo.getHeight()));
        try {
			shipping.getShippingCost(this.shipper);
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        if (this.shipType.equalsIgnoreCase("Ground")) {
            this.calculatedShipPrice += shipping.getGroundCost();
            this.calculatedShipPriceFull += shipping.getFullGroundCost();
            this.calculatedShipPriceDisc += shipping.getDiscGroundCost();
        }
        else if (this.shipType.equalsIgnoreCase("NextDay")) {
            this.calculatedShipPrice += shipping.getNextDayCost();
            this.calculatedShipPriceFull += shipping.getFullNextDayCost();
            this.calculatedShipPriceDisc += shipping.getDiscNextDayCost();
        }
        else if (this.shipType.equalsIgnoreCase("2Day")) {
            this.calculatedShipPrice += shipping.getSecondDayCost();
            this.calculatedShipPriceFull += shipping.getFullSecondDayCost();
            this.calculatedShipPriceDisc += shipping.getDiscSecondDayCost();
        }
        else if (this.shipType.equalsIgnoreCase("3Day")) {
            this.calculatedShipPrice += shipping.getThreeDayCost();
            this.calculatedShipPriceFull += shipping.getFullThreeDayCost();
            this.calculatedShipPriceDisc += shipping.getDiscThreeDayCost();
        }
      }
    }
    else {
      shipping.setWeight(String.valueOf(this.weight));
      shipping.setQuantity(String.valueOf(this.quantity));
      shipping.setLength(String.valueOf(this.length));
      shipping.setWidth(String.valueOf(this.width));
      shipping.setHeight(String.valueOf(this.height));
      try {
		shipping.getShippingCost(this.shipper);
	} catch (ClassNotFoundException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	} catch (Exception e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
      if (this.shipType.equalsIgnoreCase("Ground")) {
          this.calculatedShipPrice = shipping.getGroundCost();
          this.calculatedShipPriceFull = shipping.getFullGroundCost();
          this.calculatedShipPriceDisc = shipping.getDiscGroundCost();
      }
      else if (this.shipType.equalsIgnoreCase("NextDay")) {
          this.calculatedShipPrice = shipping.getNextDayCost();
          this.calculatedShipPriceFull = shipping.getFullNextDayCost();
          this.calculatedShipPriceDisc = shipping.getDiscNextDayCost();
      }
      else if (this.shipType.equalsIgnoreCase("2Day")) {
          this.calculatedShipPrice = shipping.getSecondDayCost();
          this.calculatedShipPriceFull = shipping.getFullSecondDayCost();
          this.calculatedShipPriceDisc = shipping.getDiscSecondDayCost();
      }
      else if (this.shipType.equalsIgnoreCase("3Day")) {
          this.calculatedShipPrice = shipping.getThreeDayCost();
          this.calculatedShipPriceFull = shipping.getFullThreeDayCost();
          this.calculatedShipPriceDisc = shipping.getDiscThreeDayCost();
      }
    }

    if (this.calculatedShipPrice != 0.00) {
      //calculateSVFee(request);
      calculateHandlingCost(shipping, request);
      this.shippingPrice = this.calculatedShipPrice + this.svFee + this.mcFee;
      this.shipmentNotes=((this.shippingPrice > getCalculatedShipPriceFull())?"Full ship price was less than ship plus fees, full retail ship price used.":"Full ship price was more than ship plus fees, ship plus feed used.");   
      this.shippingPrice = ((this.shippingPrice > getCalculatedShipPriceFull())?getCalculatedShipPriceFull():this.shippingPrice);      
    }
    else {
      this.shippingPrice = this.calculatedShipPrice;
    }
  }

  public void calculateHandlingCost(ProcessShippingCost shipping, HttpServletRequest request) {
    try {
      Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
      Statement st = conn.createStatement();
      String query = "";

      String sitehostId = ((SiteHostSettings) request.getSession().getAttribute("siteHostSettings")).getSiteHostId();

      String productId = "", contactId = "", amount = "";
      double totalJobPrice = 0.00;
      double maxPercentJobPrice = 0, maxPercentShipPrice = 0, macFee = 0;

      JobObject jo = null;
      Vector vJobs = this.getJobs();

      if (vJobs.size() > 0) {
        for (int i = 0; i < vJobs.size(); i++) {
          jo = (JobObject) vJobs.elementAt(i);
          totalJobPrice += jo.getPrice();

          JobSpecObject jsoProductCode = (JobSpecObject) jo.getJobSpecs().get("9001");
          query = "SELECT id FROM products WHERE prod_code='" + jsoProductCode.getValue() + "'";
          ResultSet rs = st.executeQuery(query);
          if (rs.next()) {
            if (!(productId.contains("p.id=" + rs.getString("id")))) {
              if (i == 0) {
                productId += "p.id=" + rs.getString("id");
              }
              else {
                productId += " OR p.id=" + rs.getString("id");
              }
            }
          }
          rs.close();
          //contactId = (String) session.getAttribute("contactId");
          JobSpecObject jsoQuantity = (JobSpecObject) jo.getJobSpecs().get("705");
          if (!(amount.contains("pp.quantity=" + jsoQuantity.getValue()))) {
            if (i == 0) {
              amount += "pp.quantity=" + jsoQuantity.getValue();
            }
            else {
              amount += " OR pp.quantity=" + jsoQuantity.getValue();
            }
          }
        }

        //query = "SELECT MAX(max_percent_jobprice) 'max_percent_jobprice', MAX(max_percent_shipprice) 'max_percent_shipprice', MAX(std_subvendor_hand) 'std_subvendor_hand', MAX(std_vend_hand) 'std_vend_hand' FROM product_prices pp, products p WHERE (" + amount + ") AND pp.prod_price_code=p.prod_price_code AND (" + productId + ")";
        query = "SELECT MAX(pp.max_percent_jobprice) 'max_percent_jobprice', MAX(pp.max_percent_shipprice) 'max_percent_shipprice', MAX(sh.default_mc_handling) 'default_mc_handling' FROM product_prices pp, products p, site_hosts sh WHERE pp.prod_price_code=p.prod_price_code AND (" + productId + ") AND sh.id=" + sitehostId;
        handlingQuery = query;
        ResultSet rs = st.executeQuery(query);
        if (rs.next()) {
          maxPercentJobPrice = Double.parseDouble(rs.getString("max_percent_jobprice"));
          maxPercentShipPrice = Double.parseDouble(rs.getString("max_percent_shipprice"));
          //subFee = Double.parseDouble(rs.getString("std_subvendor_hand"));
          //macFee = Double.parseDouble(rs.getString("std_vend_hand"));
          macFee = Double.parseDouble(rs.getString("default_mc_handling"));
        }
        rs.close();

        //double handlingCost = shipping.getHandlingCost(totalJobPrice, this.shippingCost);
        handlingCost = shipping.getHandlingCost(totalJobPrice, this.calculatedShipPrice, maxPercentJobPrice, maxPercentShipPrice, this.svFee, macFee);
        //this.shippingCost += handlingCost;
        DecimalFormat precisionTwo = new DecimalFormat("0.##");
        String mcfee = precisionTwo.format(shipping.getMcFee());
        //svFee = shipping.getSubFee();
        mcFee = Double.parseDouble(mcfee);
      }
      st.close();
      conn.close();
    }
    catch (ClassNotFoundException ex) {
      Logger.getLogger(ShipmentObject.class.getName()).log(Level.SEVERE, null, ex);
    }
    catch (Exception ex) {
      Logger.getLogger(ShipmentObject.class.getName()).log(Level.SEVERE, null, ex);
    }
  }

  public void calculateSVFee(HttpServletRequest request) {
    ShoppingCart sc = (ShoppingCart) request.getSession().getAttribute("shoppingCart");
    Vector shipments = sc.getShipments();
    Vector shipments1 = new Vector();
    shipments1.addElement((ShipmentObject) this);
    String wareHouse = this.getZipFrom();
    double svFee1 = this.getSVFee(), sameWarehouse = 1;
    System.out.println("wareHouse : " + wareHouse);
    System.out.println("SV Fee : " + svFee1);
    for (int i = 0; i < shipments.size(); i++) {
      ShipmentObject so = (ShipmentObject) shipments.elementAt(i);
      System.out.println("another Warehouse : " + so.getZipFrom());
      if((so.getId() != this.getId()) && (so.getZipFrom().equals(wareHouse))) {
        ++sameWarehouse; //no. of shipments having same warehouse
        System.out.println("another SV Fee : " + so.getSVFee());
        System.out.println("splitting SV Fee..");
        svFee1 = Math.max(svFee1, so.getSVFee());
        System.out.println("new SV Fee : " + svFee1);
        shipments1.addElement((ShipmentObject) so);
      }
    }
    if(sameWarehouse > 1) {
      svFee1 /= sameWarehouse;
      System.out.println("final SV Fee : " + svFee1);
      DecimalFormat precisionTow = new DecimalFormat("0.##");
      String svfee = precisionTow.format(svFee1);
      for (int i = 0; i < shipments1.size(); i++) {
          ShipmentObject so = (ShipmentObject) shipments1.elementAt(i);
          if(so.getSvFeeSplit()==0){
          	so.setSVFee(Double.parseDouble(svfee));
          	so.setSvFeeSplit(1);
          }
        }
    }
  }

public double getCalculatedShipPriceDisc() {
	return calculatedShipPriceDisc;
}

public void setCalculatedShipPriceDisc(double calculatedShipPriceDisc) {
	this.calculatedShipPriceDisc = calculatedShipPriceDisc;
}

public int getDoNotBundle() {
	return doNotBundle;
}

public void setDoNotBundle(int doNotBundle) {
	this.doNotBundle = doNotBundle;
}

public String getWarehouseId() {
	return warehouseId;
}

public void setWarehouseId(String warehouseId) {
	this.warehouseId = warehouseId;
}

public int getSvFeeSplit() {
	return svFeeSplit;
}

public void setSvFeeSplit(int svFeeSplit) {
	this.svFeeSplit = svFeeSplit;
}

public double getCalculatedShipPriceFull() {
	return calculatedShipPriceFull;
}

public void setCalculatedShipPriceFull(double calculatedShipPriceFull) {
	this.calculatedShipPriceFull = calculatedShipPriceFull;
}

public String getShipmentNotes() {
	return shipmentNotes;
}

public void setShipmentNotes(String shipmentNotes) {
	this.shipmentNotes = shipmentNotes;
}
}
