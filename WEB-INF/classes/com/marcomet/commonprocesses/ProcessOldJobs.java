package com.marcomet.commonprocesses;

import com.marcomet.catalog.JobObject;
import com.marcomet.catalog.ShipmentBoxObject;
import com.marcomet.catalog.ShipmentObject;
import com.marcomet.catalog.ShoppingCart;
import com.marcomet.jdbc.DBConnect;
import java.sql.*;
import java.text.DecimalFormat;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ProcessOldJobs {

  private Connection conn = null;
  private Statement st = null;
  //
  private int flag;
  private int id = 0;
  private double price = 0.00;
  private double mcFee = 0.00;
  private double weight = 0.00;
  private double volume = 0.00;
  private String boxes = "";
  //
  private String jZipFrom = "";
  private String jZipFromState = "";
  private String jZipFromCountry = "";
  private String jZipTo = "";
  private String jZipToState = "";
  private int jZipToStateCode = 0;
  private String jZipToCountry = "";
  private double jWeight = 0;
  private double jMaxWeight = 0;
  private double jHeight = 0;
  private double jMaxHeight = 0;
  private double jWidth = 0;
  private double jMaxWidth = 0;
  private double jLength = 0;
  private double jMaxLength = 0;
  private double jVolume = 0;
  private int jProjectId = 0;
  private int jNumberOfBoxes = 0;
  private int jQuantity = 1;
  private double jPaddingPercent = 0;
  private double jSVFee = 0;
  private String jShipper = "UPS";
  private String jShipperType = "GROUND";
  private String jShipperAccountNumber = "";
  private String jShipperUserName = "";
  private String jShipperPassword = "";
  private String jShipperXMLAccessKey = "";
  private String jShipperMeterNumber = "";

  public ProcessOldJobs() {
  }

  public void getOldJobs_Alone()
      throws ClassNotFoundException, Exception {

    if (conn == null) {
      conn = DBConnect.getConnection();
    }
    st = conn.createStatement();
    String query = "";

    flag = 1;

    query = "SELECT * FROM jobs WHERE recalc_flag=1 and shipment_id=0 ORDER BY id";
    ResultSet rs = st.executeQuery(query);
    while (rs.next()) {
      int jobId = Integer.parseInt(rs.getString("id"));
      //double jobPrice = Double.parseDouble(rs.getString("price"));
      JobObject jo = new JobObject();
      jo.setId(jobId);

      setShippingParameters(jobId);
      calculateShipping(flag, jo);
      calculateHandling(flag, jo);
      processInsert(flag, jo);
    }
    rs.close();
    st.close();
    conn.close();
  }

  public void getOldJobs_AsOrdered()
      throws ClassNotFoundException, Exception {

    if (conn == null || conn.isClosed()) {
      conn = DBConnect.getConnection();
    }
    st = conn.createStatement();
    String query = "";

    flag = 2;
    Vector vOrderId = new Vector();
    Vector vJobObject = new Vector();

    query = "SELECT j.id, j.job_name, p.order_id FROM jobs j, projects p WHERE recalc_flag=1 and j.shipment_id=0 AND j.project_id=p.id ORDER BY p.order_id";
    ResultSet rs = st.executeQuery(query);
    while (rs.next()) {
      int jobId = Integer.parseInt(rs.getString("id"));
      String jobName = rs.getString("job_name");
      vOrderId.addElement(rs.getString("order_id"));
      JobObject jo = new JobObject();
      jo.setId(jobId);
      jo.setJobName(jobName);
      vJobObject.addElement(jo);
    }
    rs.close();

    createShipments(vOrderId, vJobObject);

    st.close();
    conn.close();
  }

  public void getOldJobs_AsShipped()
      throws ClassNotFoundException, Exception {

    if (conn == null || conn.isClosed()) {
      conn = DBConnect.getConnection();
    }
    st = conn.createStatement();
    String query = "";

    flag = 3;
    Vector vShippingReference = new Vector();
    Vector vJobObject = new Vector();

    query = "SELECT j.id, j.job_name, sd.reference FROM jobs j, shipping_data sd WHERE recalc_flag=1 and j.shipment_id=0 AND sd.job_id=j.id AND sd.reference!='' ORDER BY sd.reference";
    ResultSet rs = st.executeQuery(query);
    while (rs.next()) {
      int jobId = Integer.parseInt(rs.getString("id"));
      String jobName = rs.getString("job_name");
      vShippingReference.addElement(rs.getString("reference"));
      JobObject jo = new JobObject();
      jo.setId(jobId);
      jo.setJobName(jobName);
      vJobObject.addElement(jo);
    }
    rs.close();

    createShipments(vShippingReference, vJobObject);

    st.close();
    conn.close();
  }

  private void createShipments(Vector vSameReference, Vector vJobObject)
      throws ClassNotFoundException, Exception {

    if (conn == null) {
      conn = DBConnect.getConnection();
    }
    st = conn.createStatement();
    String query = "";

    ShoppingCart sc = new ShoppingCart();
    ShipmentObject so = null;
    int cnt = 1;
    String oldReference = "";

    //create shipment objects..
    for (int i = 0; i < vSameReference.size(); i++) {
      boolean sameReference = false;
      String reference = (String) vSameReference.get(i);
      JobObject jo = (JobObject) vJobObject.get(i);
      int jobId = jo.getId();

      //set shipping parameters..
      setShippingParameters(jobId);

      //Vector shipments = sc.getShipments();
      int shipmentSize = sc.getShipmentSize();
      if (shipmentSize > 0) {
        for (int j = 0; j < shipmentSize; j++) {
          so = sc.getShipment(j + 1);
          //so = (ShipmentObject) shipments.elementAt(j);
          if (reference.equals(oldReference)) {
            sameReference = true;
            so.setWeight(so.getWeight() + (jNumberOfBoxes * jWeight));
            so.setVolume(so.getVolume() + (jNumberOfBoxes * jHeight * jWidth * jLength));
            so.addJob(jo);
            break;
          }
        }
      }
      if (!sameReference) {
        if (oldReference.equals("")) {
          oldReference = reference;
        }
        so = new ShipmentObject(cnt, jZipFrom, jZipFromState, jZipFromCountry, jZipTo, jZipToState, jZipToStateCode, jZipToCountry, jQuantity, jWeight * jNumberOfBoxes, jHeight, jLength, jWidth, jVolume * jNumberOfBoxes, jShipper, jShipperType, jSVFee);
        cnt++;
        so.addJob(jo);
        so.addProjectId(jProjectId);
        so.setMaxWeight(jMaxWeight);
        so.setMaxHeight(jMaxHeight);
        so.setMaxWidth(jMaxWidth);
        so.setMaxLength(jMaxLength);
        so.setMaxVolume(so.getMaxHeight() * so.getMaxWidth() * so.getMaxLength());
        so.setPaddingPercent(jPaddingPercent);
        so.setShipperAccountNumber(jShipperAccountNumber);
        so.setShipperMeterNumber(jShipperMeterNumber);
        so.setShipperPassword(jShipperPassword);
        so.setShipperUserName(jShipperUserName);
        so.setShipperXMLKey(jShipperType);
        sc.addShipment(so);
      }
    }

    //create shipment box objects..
    for (int i = 0; i < sc.getShipmentSize(); i++) {
      so = (ShipmentObject) sc.getShipments().elementAt(i);
      if (so.getWeight() != 0.00) {
        so.setHeight(so.getMaxHeight());
        so.setWidth(so.getMaxWidth());
        so.setLength(so.getMaxLength());

        createShipmentBoxes(so);
      }
      else {
      }
      price = 0;
      boxes = "";
      calculateShipping(flag, so);
      calculateHandling(flag, so);
      processInsert(flag, so);
    }
  }

  private void createShipmentBoxes(ShipmentObject so)
      throws ClassNotFoundException, Exception {

    if (conn == null) {
      conn = DBConnect.getConnection();
    }
    st = conn.createStatement();
    String query = "";

    ShipmentBoxObject sbo = null;

    int qty1 = (int) Math.ceil(so.getVolume() / so.getMaxVolume());
    int qty2 = (int) Math.ceil(so.getWeight() / so.getMaxWeight());
    int quantity = Math.max(qty1, qty2);
    if (quantity < so.getShipmentBoxes().size()) {
      quantity = so.getShipmentBoxes().size();
    }

    //create shipment boxes..
    for (int i = 0; i < quantity; i++) {
      boolean sameBox = false;
      Vector shipmentBoxes = so.getShipmentBoxes();
      if (shipmentBoxes.size() > 0) {
        for (int j = 0; j < shipmentBoxes.size(); j++) {
          sbo = (ShipmentBoxObject) shipmentBoxes.elementAt(j);
          if (sbo.getBoxNumber() == i + 1) {
            sameBox = true;
            sbo.setWeight(0);
            sbo.setVolume(0);
            sbo.setContents("");
            break;
          }
        }
      }
      if (!sameBox) {
        sbo = new ShipmentBoxObject(so.getId(), i + 1, 0, 0, 0, 0, "");
        sbo.setVolume(0);
        sbo.setPaddingPercent(so.getPaddingPercent());
        so.addShipmentBox(sbo);
      }
    }

    double[][] packs;
    String[] jobName;
    double wt = 0, len = 0, ht = 0, wid = 0, vol = 0, nob = 0;

    // create packs array..
    Vector jobs = so.getJobs();
    packs = new double[jobs.size()][3];
    jobName = new String[jobs.size()];
    for (int i = 0; i < jobs.size(); i++) {
      JobObject jo = (JobObject) jobs.elementAt(i);
      int jobId = jo.getId();

      query = "SELECT pp.weight_per_box, pp.length, pp.width, pp.height, pp.number_of_boxes FROM product_prices pp, products p, jobs j WHERE pp.quantity=j.quantity AND pp.prod_price_code=p.prod_price_code AND p.id=j.product_id AND j.id=" + jobId;
      ResultSet rs1 = st.executeQuery(query);
      if (rs1.next()) {
        wt = Double.parseDouble(rs1.getString("weight_per_box"));
        len = Double.parseDouble(rs1.getString("length"));
        ht = Double.parseDouble(rs1.getString("height"));
        wid = Double.parseDouble(rs1.getString("width"));
        vol = len * ht * wid;
        nob = Integer.parseInt(rs1.getString("number_of_boxes"));
      }
      rs1.close();

      packs[i][0] = wt;
      packs[i][1] = vol;
      packs[i][2] = nob;
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
              if (sbo.getContents().contains(" | " + counter[k] + " Pack(s) of " + jobName[i])) {
                sbo.setContents(sbo.getContents().replace(" | " + counter[k] + " Pack(s) of " + jobName[i], ""));
              }
              else if (sbo.getContents().contains(counter[k] + " Pack(s) of " + jobName[i])) {
                sbo.setContents(sbo.getContents().replace(counter[k] + " Pack(s) of " + jobName[i], ""));
              }
              counter[k]++;
            }

            if (sbo.getContents() != null && !(sbo.getContents().equals(""))) {
              sbo.setContents(sbo.getContents() + " | " + counter[k] + " Pack(s) of " + jobName[i]);
            }
            else {
              sbo.setContents(counter[k] + " Pack(s) of " + jobName[i]);
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
              if (sbo.getContents().contains(" | " + counter[qty - 1] + " Pack(s) of " + jobName[i])) {
                sbo.setContents(sbo.getContents().replace(" | " + counter[qty - 1] + " Pack(s) of " + jobName[i], ""));
              }
              else if (sbo.getContents().contains(counter[qty - 1] + " Pack(s) of " + jobName[i])) {
                sbo.setContents(sbo.getContents().replace(counter[qty - 1] + " Pack(s) of " + jobName[i], ""));
              }
              counter[qty - 1]++;
            }

            if (sbo.getContents() != null && !(sbo.getContents().equals(""))) {
              sbo.setContents(sbo.getContents() + " | " + counter[qty - 1] + " Pack(s) of " + jobName[i]);
            }
            else {
              sbo.setContents(counter[qty - 1] + " Pack(s) of " + jobName[i]);
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
    Vector shipmentBoxes = so.getShipmentBoxes();
    if (shipmentBoxes.size() > 0) {
      for (int i = 0; i < shipmentBoxes.size(); i++) {
        sbo = (ShipmentBoxObject) shipmentBoxes.elementAt(i);
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
          int count = Integer.parseInt(contents.substring(0, contents.indexOf("Pack(s) of")).trim());
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

  private void setShippingParameters(int jobId)
      throws ClassNotFoundException, Exception {

    if (conn == null) {
      conn = DBConnect.getConnection();
    }
    st = conn.createStatement();

    setDefault();

    String query1 = "SELECT cl.zip 'zipFrom', lus.state_abreviation 'zipFromState', luc.value 'zipFromCountry', w.ship_box_max_weight 'maxWeight', w.ship_box_height 'maxHeight', w.ship_box_length 'maxLength', w.ship_box_width 'maxWidth', w.box_padding_percent 'paddingPercent', j.project_id 'projectId' FROM company_locations cl, warehouses w, lu_states lus, lu_countries luc, jobs j WHERE cl.state=lus.id AND cl.country_id=luc.id AND cl.id=w.location_id AND w.id=j.jwarehouse_id AND j.id=" + jobId;
    ResultSet rs1 = st.executeQuery(query1);
    if (rs1.next()) {
      jZipFrom = rs1.getString("zipFrom");
      jZipFromState = rs1.getString("zipFromState");
      jZipFromCountry = rs1.getString("zipFromCountry");
      jMaxWeight = Double.parseDouble(rs1.getString("maxWeight"));
      jMaxHeight = Double.parseDouble(rs1.getString("maxHeight"));
      jMaxWidth = Double.parseDouble(rs1.getString("maxWidth"));
      jMaxLength = Double.parseDouble(rs1.getString("maxLength"));
      jPaddingPercent = Double.parseDouble(rs1.getString("paddingPercent"));
      jProjectId = Integer.parseInt(rs1.getString("projectId"));
    }
    rs1.close();

    query1 = "SELECT l.zip 'zipTo', l.state 'zipToStateCode', lus.state_abreviation 'zipToState', luc.value 'zipToCountry' FROM locations l, jobs j, lu_states lus, lu_countries luc WHERE l.state=lus.id AND l.country_id=luc.id AND l.locationtypeid=1 AND l.contactid=j.jbuyer_contact_id AND j.id=" + jobId;
    ResultSet rs2 = st.executeQuery(query1);
    if (rs2.next()) {
      jZipTo = rs2.getString("zipTo");
      jZipToState = rs2.getString("zipToState");
      jZipToStateCode = rs2.getInt("zipToStateCode");
      jZipToCountry = rs2.getString("zipToCountry");
    }
    rs2.close();

    query1 = "SELECT pp.weight_per_box, pp.length, pp.width, pp.height, pp.number_of_boxes, pp.std_subvendor_hand FROM product_prices pp, products p, jobs j WHERE pp.quantity=j.quantity AND pp.prod_price_code=p.prod_price_code AND p.id=j.product_id AND j.id=" + jobId;
    ResultSet rs3 = st.executeQuery(query1);
    if (rs3.next()) {
      jWeight = Double.parseDouble(rs3.getString("weight_per_box"));
      jLength = Double.parseDouble(rs3.getString("length"));
      jWidth = Double.parseDouble(rs3.getString("width"));
      jHeight = Double.parseDouble(rs3.getString("height"));
      jNumberOfBoxes = Integer.parseInt(rs3.getString("number_of_boxes"));
      jSVFee = Double.parseDouble(rs3.getString("std_subvendor_hand"));
    }
    rs3.close();

    jVolume = jHeight * jWidth * jLength;

    query1 = "SELECT DISTINCT sa.shipper_type, sa.account_number, sa.user_name, sa.password, sa.xml_key, sa.meter_number FROM shipping_accounts sa, jobs j WHERE sa.vendor_id=j.dropship_vendor AND j.id=" + jobId;
    ResultSet rs4 = st.executeQuery(query1);
    if (rs4.next()) {
      jShipper = rs4.getString("shipper_type");
      jShipperAccountNumber = rs4.getString("account_number");
      jShipperUserName = rs4.getString("user_name");
      jShipperPassword = rs4.getString("password");
      jShipperXMLAccessKey = rs4.getString("xml_key");
      jShipperMeterNumber = rs4.getString("meter_number");
    }
    else {
      query1 = "SELECT DISTINCT account_number, user_name, password, xml_key, meter_number FROM shipping_accounts WHERE shipper_type='" + jShipper.toUpperCase() + "' AND vendor_id=105";
      ResultSet rs5 = st.executeQuery(query1);
      if (rs5.next()) {
        jShipperAccountNumber = rs5.getString("account_number");
        jShipperUserName = rs5.getString("user_name");
        jShipperPassword = rs5.getString("password");
        jShipperXMLAccessKey = rs5.getString("xml_key");
        jShipperMeterNumber = rs5.getString("meter_number");
      }
      rs5.close();
    }
    rs4.close();
  }

  private void setDefault() {
    jZipFrom = "";
    jZipFromState = "";
    jZipFromCountry = "";
    jZipTo = "";
    jZipToState = "";
    jZipToStateCode = 0;
    jZipToCountry = "";
    jWeight = 0.00;
    jMaxWeight = 0.00;
    jHeight = 0.00;
    jMaxHeight = 0.00;
    jWidth = 0.00;
    jMaxWidth = 0.00;
    jLength = 0.00;
    jMaxLength = 0.00;
    jVolume = 0.00;
    jProjectId = 0;
    jNumberOfBoxes = 0;
    jQuantity = 1;
    jPaddingPercent = 0.00;
    jShipper = "UPS";
    jShipperType = "GROUND";
    jShipperAccountNumber = "";
    jShipperUserName = "";
    jShipperPassword = "";
    jShipperXMLAccessKey = "";
    jShipperMeterNumber = "";
  }

  private void calculateShipping(int flag, Object o)
      throws ClassNotFoundException, Exception {

    ProcessShippingCost psc = new ProcessShippingCost();

    psc.setShipperAccountNumber(jShipperAccountNumber);
    if (jShipper.equalsIgnoreCase("UPS")) {
      psc.setUpsXMLAccessKey(jShipperXMLAccessKey);
      psc.setUpsUserName(jShipperUserName);
      psc.setUpsPassword(jShipperPassword);
    }
    else if (jShipper.equalsIgnoreCase("FEDEX")) {
      psc.setFdxMeterNumber(jShipperMeterNumber);
    }
    psc.setZipFrom(jZipFrom);
    psc.setZipFromState(jZipFromState);
    psc.setZipFromCountry(jZipFromCountry);
    psc.setZipTo(jZipTo);
    psc.setZipToState(jZipToState);
    psc.setZipToCountry(jZipToCountry);
    if (flag == 1) {
      psc.setWeight(String.valueOf(jWeight));
      psc.setLength(String.valueOf(jLength));
      psc.setWidth(String.valueOf(jWidth));
      psc.setHeight(String.valueOf(jHeight));
      psc.setQuantity(String.valueOf(jQuantity));

      psc.getShippingCost(jShipper);

      price = psc.getGroundCost();
      weight = jNumberOfBoxes * jWeight;
      volume = jNumberOfBoxes * jVolume;
      boxes = jHeight + "x" + jWidth + "x" + jLength + " : " + jWeight;
    }
    else {
      ShipmentObject so = (ShipmentObject) o;
      ShipmentBoxObject sbo = null;
      Vector shipmentBoxes = so.getShipmentBoxes();
      if (shipmentBoxes.size() > 0) {
        for (int i = 0; i < shipmentBoxes.size(); i++) {
          sbo = (ShipmentBoxObject) shipmentBoxes.elementAt(i);
          psc.setWeight(String.valueOf(sbo.getWeight()));
          psc.setQuantity(String.valueOf(1));
          psc.setLength(String.valueOf(sbo.getLength()));
          psc.setWidth(String.valueOf(sbo.getWidth()));
          psc.setHeight(String.valueOf(sbo.getHeight()));

          psc.getShippingCost(jShipper);

          price += psc.getGroundCost();
          if (i == 0) {
            boxes += "Box " + sbo.getBoxNumber() + " : " + sbo.getHeight() + "x" + sbo.getWidth() + "x" + sbo.getLength() + " : " + sbo.getWeight();
          }
          else {
            boxes += " | Box " + sbo.getBoxNumber() + " : " + sbo.getHeight() + "x" + sbo.getWidth() + "x" + sbo.getLength() + " : " + sbo.getWeight();
          }
        }
      }
      else {
        psc.setWeight(String.valueOf(so.getWeight()));
        psc.setQuantity(String.valueOf(so.getQuantity()));
        psc.setLength(String.valueOf(so.getLength()));
        psc.setWidth(String.valueOf(so.getWidth()));
        psc.setHeight(String.valueOf(so.getHeight()));

        psc.getShippingCost(so.getShipper());

        price = psc.getGroundCost();
        boxes = so.getHeight() + "x" + so.getWidth() + "x" + so.getLength() + " : " + so.getWeight();
      }

      weight = so.getWeight();
      volume = so.getVolume();
    }
  }

  private void calculateHandling(int flag, Object o)
      throws ClassNotFoundException, Exception {

    if (conn == null) {
      conn = DBConnect.getConnection();
    }
    st = conn.createStatement();
    String query = "";

    ProcessShippingCost psc = new ProcessShippingCost();
    //psc.setJobId(String.valueOf(jobId));
    double handling = 0;

    if (flag == 1) {
      JobObject jo = (JobObject) o;
      int jobId = jo.getId();
      double jobPrice = 0;
      query = "SELECT price FROM jobs WHERE id=" + jobId;
      ResultSet rs = st.executeQuery(query);
      if (rs.next()) {
        jobPrice = Double.parseDouble(rs.getString("price"));
      }
      rs.close();

      psc.setJobId(String.valueOf(jobId));
      handling = psc.getHandlingCost(jobPrice, price);
    }
    else {
      String jobId = "";
      int jId = 0;
      double totalJobPrice = 0.00;
      double maxPercentJobPrice = 0, maxPercentShipPrice = 0, subFee = 0, macFee = 0;
      ShipmentObject so = (ShipmentObject) o;
      JobObject jo = null;
      Vector vJobs = so.getJobs();

      if (vJobs.size() > 0) {
        for (int i = 0; i < vJobs.size(); i++) {
          jo = (JobObject) vJobs.elementAt(i);
          jId = jo.getId();

          query = "SELECT price FROM jobs WHERE id=" + jId;
          ResultSet rs = st.executeQuery(query);
          if (rs.next()) {
            totalJobPrice += Double.parseDouble(rs.getString("price"));
          }
          rs.close();

          if (!(jobId.contains("j.id=" + String.valueOf(jo.getId())))) {
            if (i == 0) {
              jobId += "j.id=" + String.valueOf(jo.getId());
            }
            else {
              jobId += " OR j.id=" + String.valueOf(jo.getId());
            }
          }
        }

        query = "SELECT max_percent_jobprice, max_percent_shipprice, std_subvendor_hand, std_vend_hand FROM product_prices pp, products p, jobs j WHERE pp.prod_price_code=p.prod_price_code AND p.id=j.product_id AND (" + jobId + ")";
        ResultSet rs = st.executeQuery(query);
        if (rs.next()) {
          query = "SELECT MAX(max_percent_jobprice) 'max_percent_jobprice', MAX(max_percent_shipprice) 'max_percent_shipprice', MAX(std_subvendor_hand) 'std_subvendor_hand', MAX(std_vend_hand) 'std_vend_hand' FROM product_prices pp, products p, jobs j WHERE pp.prod_price_code=p.prod_price_code AND p.id=j.product_id AND (" + jobId + ")";
          ResultSet rs1 = st.executeQuery(query);
          if (rs1.next()) {
            maxPercentJobPrice = Double.parseDouble(rs1.getString("max_percent_jobprice"));
            maxPercentShipPrice = Double.parseDouble(rs1.getString("max_percent_shipprice"));
            subFee = Double.parseDouble(rs1.getString("std_subvendor_hand"));
            macFee = Double.parseDouble(rs1.getString("std_vend_hand"));
          }
          rs1.close();

          handling = psc.getHandlingCost(totalJobPrice, price, maxPercentJobPrice, maxPercentShipPrice, subFee, macFee);
        }
        rs.close();
      }
    }

    if (price != 0.00) {
      price += handling;
    }
    mcFee = psc.getMcFee();
  }

  private void processInsert(int flag, Object o)
      throws SQLException {

    try {
      if (conn == null) {
        conn = DBConnect.getConnection();
      }
      st = conn.createStatement();
      String insertSQL = "";

      if (flag == 1) {
        st.execute("LOCK TABLES prior_shipping_verification WRITE");

        JobObject jo = (JobObject) o;
        int jobId = jo.getId();
        insertSQL = "INSERT INTO prior_shipping_verification (id, jobid, price_alone, mc_fee_alone, weight_alone, volume_alone, boxes_alone) VALUES (?,?,?,?,?,?,?)";

        String getNextIdSQL = "SELECT IF( MAX(id) IS NULL, 0, MAX(id))+1  FROM prior_shipping_verification";
        ResultSet rs1 = st.executeQuery(getNextIdSQL);
        rs1.next();
        id = rs1.getInt(1);

        PreparedStatement ps = conn.prepareCall(insertSQL);
        ps.clearParameters();
        ps.setInt(1, id);
        ps.setInt(2, jobId);
        ps.setDouble(3, price);
        ps.setDouble(4, mcFee);
        ps.setDouble(5, weight);
        ps.setDouble(6, volume);
        if (price != 0.00) {
          boxes = new DecimalFormat("#0.##").format(100.00) + "% | " + boxes;
        }
        else {
          boxes = "0.00% | " + boxes;
        }
        ps.setString(7, boxes);
        ps.execute();
      }
      else {
        st.execute("LOCK TABLES product_prices pp READ, products p READ, jobs j READ, projects pj READ, shipping_data READ, prior_shipping_verification WRITE");

        if (flag == 2) {
          insertSQL = "INSERT INTO prior_shipping_verification (id, jobid, orderid, price_as_ordered, mc_fee_as_ordered, weight_as_ordered, volume_as_ordered, boxes_as_ordered) VALUES (?,?,?,?,?,?,?,?)";
        }
        else if (flag == 3) {
          insertSQL = "INSERT INTO prior_shipping_verification (id, jobid, reference, price_as_shipped, mc_fee_as_shipped, weight_as_shipped, volume_as_shipped, boxes_as_shipped) VALUES (?,?,?,?,?,?,?,?)";
        }

        ShipmentObject so = (ShipmentObject) o;
        Vector jobs = so.getJobs();
        for (int i = 0; i < jobs.size(); i++) {
          JobObject jo = (JobObject) jobs.elementAt(i);
          int jobId = jo.getId();
          double joTotalWeight = 0;
          String value = null;

          String query = "SELECT pp.weight_per_box, pp.number_of_boxes FROM product_prices pp, products p, jobs j WHERE pp.quantity=j.quantity AND pp.prod_price_code=p.prod_price_code AND p.id=j.product_id AND j.id=" + jobId;
          ResultSet rs = st.executeQuery(query);
          if (rs.next()) {
            joTotalWeight = (Double.parseDouble(rs.getString("number_of_boxes")) * Double.parseDouble(rs.getString("weight_per_box")));
          }
          rs.close();

          if (flag == 2) {
            query = "SELECT order_id 'value' FROM projects pj, jobs j WHERE j.project_id=pj.id AND j.id=" + jobId;
          }
          else if (flag == 3) {
            query = "SELECT reference 'value' FROM shipping_data WHERE reference!='' AND job_id=" + jobId;
          }
          ResultSet rs1 = st.executeQuery(query);
          if (rs1.next()) {
            value = rs1.getString("value");
          }
          rs1.close();

          double joPercentShipment = 0.00;
          if (weight > 0) {
            joPercentShipment = ((joTotalWeight / weight) * 100);
          }
          String bx = boxes;
          boxes = new DecimalFormat("#0.##").format(joPercentShipment) + "% | " + boxes;

          String getNextIdSQL = "SELECT IF( MAX(id) IS NULL, 0, MAX(id))+1  FROM prior_shipping_verification";
          ResultSet rs2 = st.executeQuery(getNextIdSQL);
          rs2.next();
          id = rs2.getInt(1);

          PreparedStatement ps = conn.prepareCall(insertSQL);
          ps.clearParameters();
          ps.setInt(1, id);
          ps.setInt(2, jobId);
          if (flag == 2) {
            ps.setInt(3, Integer.valueOf(value));
          }
          else if (flag == 3) {
            ps.setString(3, value);
          }
          ps.setDouble(4, price);
          ps.setDouble(5, mcFee);
          ps.setDouble(6, weight);
          ps.setDouble(7, volume);
          ps.setString(8, boxes);
          ps.execute();
          boxes = bx;
        }
      }
    }
    catch (Exception ex) {
      throw new SQLException(ex.getMessage());
    }
    finally {
      try {
        st.execute("UNLOCK TABLES");
      }
      catch (Exception ex) {
        Logger.getLogger(ProcessOldJobs.class.getName()).log(Level.SEVERE, null, ex);
      }
    }
  }
}