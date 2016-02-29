package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import com.marcomet.shipping.*;
import com.marcomet.environment.*;
import com.marcomet.tools.SimpleLookups;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class ProcessShippingCost extends HttpServlet {

  private String jobId = "";
  private String productId = "";
  private String contactId = "";
  private String zipFrom = "";
  private String zipFromState = "";
  private String zipFromCountry = "";
  private String zipTo = "";
  private String zipToState = "";
  private String zipToCountry = "";
  private String calcCountry = "";
  private String weight = "";
  private String height = "";
  private String length = "";
  private String width = "";
  private String quantity = "";
  private String shipper = "";
  private String shipperAccountNumber = "";
  private String upsUserName = "";
  private String upsPassword = "";
  private String upsXMLAccessKey = "";
  private String fdxMeterNumber = "";
  private int amount = 0;
  private String sitehostid;
  
  
  private int useDiscPrice=0;
  
  private double groundCost = 0.00;
  private double nextDayCost = 0.00;
  private double secondDayCost = 0.00;
  private double threeDayCost = 0.00;
  
  private double discGroundCost = 0.00;
  private double discNextDayCost = 0.00;
  private double discSecondDayCost = 0.00;
  private double discThreeDayCost = 0.00;
  
  private double fullGroundCost = 0.00;
  private double fullNextDayCost = 0.00;
  private double fullSecondDayCost = 0.00;
  private double fullThreeDayCost = 0.00;
  
  private double mcFee = 0.00;
  private double subFee = 0.00;

  // Response shipment type codes for US Domestic Shipments as specified in Appendix C of
  // the UPS OnLine Tools Rates and Service Selection Developers Guide..
  private static final String UPS_NEXT_DAY_AIR = "01";
  private static final String UPS_SECOND_DAY_AIR = "02";
  private static final String UPS_GROUND = "03";
  private static final String UPS_WORLDWIDE_EXPRESS = "07";
  private static final String UPS_WORLDWIDE_EXPEDITED = "08";
  private static final String UPS_STANDARD = "11";
  private static final String UPS_THREE_DAY_SELECT = "12";
  private static final String UPS_NEXT_DAY_AIR_SAVER = "13";
  private static final String UPS_NEXT_DAY_AIR_EARLY_AM = "14";
  private static final String UPS_WORLDWIDE_EXPRESS_PLUS = "54";
  private static final String UPS_SECOND_DAY_AIR_AM = "59";
  private static final String UPS_SAVER = "65";
  

  // These values should theoretically be the same for everyone requesting shipping rates..
  private static final String protocol = "https";
  private static final String upsHostname = "wwwcie.ups.com";
  private static final String upsService = "ups.app/xml/Rate";
  private static final String upsPackagingType = "02";  //'00' (unknown), '01' (UPS letter), '02' (customer supplied package),
  //'03' (tube), '04' (PAK), '21' (UPS express box), '24' (UPS 25KG box), '25' (UPS 10KG box),
  //'2a' (small express box), '2b' (medium express box), '2c' (large express box), or '30' (pallet)
  private static final String upsPickupTypeDisc = "01"; //'01' (daily pickup), '03' (customer counter), '06' (one time pickup), '07' (on call air),
  private static final String upsPickupType = "06"; //'01' (daily pickup), '03' (customer counter), '06' (one time pickup), '07' (on call air),
  //'11' (suggested retail rates), '19' (letter center), or '20' (air service center)
  private static final String fdxHostname = "gatewaybeta.fedex.com:443";
  private static final String fdxService = "GatewayDC";

  // <editor-fold defaultstate="collapsed" desc="Getter-Setter Methods.">
  public int getAmount() {
    return amount;
  }

  public void setAmount(int amount) {
    this.amount = amount;
  }

  public String getContactId() {
    return contactId;
  }

  public void setContactId(String contactId) {
    this.contactId = contactId;
  }

  public String getFdxMeterNumber() {
    return fdxMeterNumber;
  }

  public void setFdxMeterNumber(String fdxMeterNumber) {
    this.fdxMeterNumber = fdxMeterNumber;
  }

  public String getHeight() {
    return height;
  }

  public void setHeight(String height) {
    this.height = height;
  }

  public String getJobId() {
    return jobId;
  }

  public void setJobId(String jobId) {
    this.jobId = jobId;
  }

  public String getLength() {
    return length;
  }

  public void setLength(String length) {
    this.length = length;
  }

  public double getMcFee() {
    return mcFee;
  }

  public void setMcFee(double mcFee) {
    this.mcFee = mcFee;
  }

  public String getProductId() {
    return productId;
  }

  public void setProductId(String productId) {
    this.productId = productId;
  }

  public String getQuantity() {
    return quantity;
  }

  public void setQuantity(String quantity) {
    this.quantity = quantity;
  }

  public String getShipper() {
    return shipper;
  }

  public void setShipper(String shipper) {
    this.shipper = shipper;
  }

  public String getShipperAccountNumber() {
    return shipperAccountNumber;
  }

  public void setShipperAccountNumber(String shipperAccountNumber) {
    this.shipperAccountNumber = shipperAccountNumber;
  }

  public double getSubFee() {
    return subFee;
  }

  public void setSubFee(double subFee) {
    this.subFee = subFee;
  }

  public String getUpsPassword() {
    return upsPassword;
  }

  public void setUpsPassword(String upsPassword) {
    this.upsPassword = upsPassword;
  }

  public String getUpsUserName() {
    return upsUserName;
  }

  public void setUpsUserName(String upsUserName) {
    this.upsUserName = upsUserName;
  }

  public String getUpsXMLAccessKey() {
    return upsXMLAccessKey;
  }

  public void setUpsXMLAccessKey(String upsXMLAccessKey) {
    this.upsXMLAccessKey = upsXMLAccessKey;
  }

  public String getWeight() {
    return weight;
  }

  public void setWeight(String weight) {
    this.weight = weight;
  }

  public String getWidth() {
    return width;
  }

  public void setWidth(String width) {
    this.width = width;
  }

  public String getZipFrom() {
    return zipFrom;
  }

  public void setZipFrom(String zipFrom) {
    this.zipFrom = zipFrom;
  }

  public String getZipFromState() {
    return zipFromState;
  }

  public void setZipFromState(String zipFromState) {
    this.zipFromState = zipFromState;
  }

  public String getZipFromCountry() {
    return zipFromCountry;
  }

  public void setZipFromCountry(String zipFromCountry) {
    this.zipFromCountry = zipFromCountry;
  }

  public String getZipTo() {
    return zipTo;
  }

  public void setZipTo(String zipTo) {
    this.zipTo = zipTo;
  }

  public String getZipToState() {
    return zipToState;
  }

  public void setZipToState(String zipToState) {
    this.zipToState = zipToState;
  }

  public String getZipToCountry() {
    return zipToCountry;
  }

  public void setZipToCountry(String zipToCountry) {
    this.zipToCountry = zipToCountry;
  }

  public double getGroundCost() {
    return groundCost;
  }

  public void setGroundCost(double groundCost) {
    this.groundCost = groundCost;
  }

  public double getNextDayCost() {
    return nextDayCost;
  }

  public void setNextDayCost(double nextDayCost) {
    this.nextDayCost = nextDayCost;
  }

  public double getSecondDayCost() {
    return secondDayCost;
  }

  public void setSecondDayCost(double secondDayCost) {
    this.secondDayCost = secondDayCost;
  }

  public double getThreeDayCost() {
    return threeDayCost;
  }

  public void setThreeDayCost(double threeDayCost) {
    this.threeDayCost = threeDayCost;
  }
  // </editor-fold>

  public double calculateShippingCost()
      throws ClassNotFoundException, Exception {

    setParameters();
    getShippingCost(getShipper());

    return getGroundCost();
  }

  public void calculateShippingCost(HttpServletRequest request, HttpServletResponse response)
      throws ClassNotFoundException, Exception {

    PrintWriter out = response.getWriter();
    sitehostid=((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId();

    setParameters(request, response);
    getShippingCost(getShipper());

    out.write("$('GroundCost').value = '" + getGroundCost() + "';");
    out.write("$('NextDayCost').value = '" + getNextDayCost() + "';");
    out.write("$('SecondDayCost').value = '" + getSecondDayCost() + "';");
    out.write("$('ThreeDayCost').value = '" + getThreeDayCost() + "';");

//    if (getShipper().equalsIgnoreCase("ups")) {
//      //// Set configurable request variables..
//      //String UPSAccount = "Y5v287";
//      //String UPSUsername = "spanchal";
//      //String UPSPassword = "s7panchal";
//      //String UPSXMLAccessKey = "6C41DAC9EEB88654";
//    }
//    else if (getShipper().equalsIgnoreCase("fedex")) {
//      //// Set configurable request variables..
//      //String FDXAccountNumber = "510087941";
//      //String FDXMeterNumber = "100005551";
//    }
  }

  private void setParameters(HttpServletRequest request, HttpServletResponse response)
      throws ClassNotFoundException, Exception {

    setProductId(request.getParameter("productId"));
    setContactId(request.getParameter("customerId"));
    setAmount(Integer.parseInt(request.getParameter("amount")));
    setShipper(request.getParameter("shipper"));

    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
    String query = "";

    //query = "SELECT zip 'zipFrom' FROM company_locations WHERE id=(SELECT location_id FROM warehouses WHERE id=(SELECT default_warehouse_id FROM products WHERE id=" + getProductId() + "))";
    query = "SELECT cl.zip 'zipFrom, lus.state_abreviation 'zipFromState', luc_value 'zipFromCountry' FROM company_locations cl, warehouses w, products p, lu_states lus, lu_countries luc WHERE cl.id=w.location_id AND w.id=p.default_warehouse_id AND p.id=" + getProductId() + " AND cl.state=lus.id AND cl.country_id=luc.id";
    ResultSet rs1 = st.executeQuery(query);
    if (rs1.next()) {
      setZipFrom(rs1.getString("zipFrom"));
      setZipFromState(rs1.getString("zipFromState"));
      setZipFromCountry(rs1.getString("zipFromCountry"));
    }
    rs1.close();

    //query = "SELECT zip 'zipTo' FROM locations WHERE locationtypeid=1 AND contactid=(SELECT id FROM contacts WHERE id=" + getContactId() + ")";
    query = "SELECT l.zip 'zipTo', lus.state_abreviation 'zipToState', luc.value 'zipToCountry',luc.use_calculated_shipping 'useCountryShipping' FROM locations l, contacts c, lu_states lus, lu_countries luc WHERE l.locationtypeid=1 AND l.contactid=c.id & c.id=" + getContactId();
    ResultSet rs2 = st.executeQuery(query);
    if (rs2.next()) {
      setZipTo(rs2.getString("zipTo"));
      setZipToState(rs2.getString("zipToState"));
      setZipToCountry(rs2.getString("zipToCountry"));
      setCalcCountry(rs2.getString("useCountryShipping"));
      
    }
    rs2.close();

    //query = "SELECT weight, length, width, height, number_of_boxes FROM product_prices WHERE quantity=" + getAmount() + " AND prod_price_code=(SELECT prod_price_code FROM products WHERE id=" + getProductId() + ")";
    query = "SELECT pp.weight, pp.length, pp.width, pp.height, pp.number_of_boxes,sh.use_full_shipcharge FROM site_hosts sh, product_prices pp, products p WHERE sh.id="+sitehostid+" and pp.quantity=" + getAmount() + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + getProductId();
    ResultSet rs3 = st.executeQuery(query);
    if (rs3.next()) {
      setWeight(rs3.getString("weight"));
      setLength(rs3.getString("length"));
      setWidth(rs3.getString("width"));
      setHeight(rs3.getString("height"));
      setQuantity(rs3.getString("number_of_boxes"));
      setUseDiscPrice(rs3.getInt("use_full_shipcharge"));
    }
    rs3.close();

    //query = "SELECT account_number, user_name, password, xml_key, meter_number FROM shipping_accounts WHERE shipper_type='" + getShipper().toUpperCase() + "' AND vendor_id=(SELECT ds_vendor FROM product_prices WHERE prod_price_code=(SELECT prod_price_code FROM products WHERE id=" + getProductId() + "))";
    query = "SELECT sa.account_number, sa.user_name, sa.password, sa.xml_key, sa.meter_number FROM shipping_accounts sa, product_prices pp, products p WHERE sa.shipper_type='" + getShipper().toUpperCase() + "' AND sa.vendor_id=pp.ds_vendor AND pp.prod_price_code=p.prod_price_code AND p.id=" + getProductId();
    ResultSet rs4 = st.executeQuery(query);
    if (rs4.next()) {
      setShipperAccountNumber(rs4.getString("account_number"));
      setUpsUserName(rs4.getString("user_name"));
      setUpsPassword(rs4.getString("password"));
      setUpsXMLAccessKey(rs4.getString("xml_key"));
      setFdxMeterNumber(rs4.getString("meter_number"));
    }
    rs4.close();

    st.close();
    conn.close();
  }

  private void setParameters()
      throws ClassNotFoundException, Exception {

    int flag = 0;

    if (!(getJobId().equals(""))) {
      flag = 1;
    }
    else if ((!(getProductId().equals(""))) && (!(getContactId().equals("")))) {
      flag = 2;
    }

    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
    String query = "";
 
    if (flag == 1) {
      //query = "SELECT state, zip 'zipFrom', country_id FROM company_locations WHERE id=(SELECT location_id FROM warehouses WHERE id=(SELECT jwarehouse_id FROM jobs WHERE id=" + getJobId() + "))";
      query = "SELECT lus.state_abreviation 'zipFromState', cl.zip 'zipFrom', luc.value 'zipFromCountry' FROM company_locations cl, warehouses w, jobs j, lu_states lus, lu_countries luc WHERE cl.id=w.location_id AND w.id=j.jwarehouse_id AND j.id=" + getJobId() + " AND cl.state=lus.id AND cl.country_id=luc.id";
    }else if (flag == 2) {
      String warehouseId = null;
      String sql = "SELECT default_warehouse_id 'warehouseId' FROM products WHERE id=" + getProductId();
      ResultSet rs11 = null;
      rs11 = st.executeQuery(sql);
      if (rs11.next()) {
        warehouseId = rs11.getString("warehouseId");
      }
      rs11.close();
      if (warehouseId.equals("0") || warehouseId == null) {
        //sql = "SELECT default_warehouse_id 'warehouseId' FROM vendors WHERE id=(SELECT dropship_vendor FROM product_price_codes WHERE prod_price_code=(SELECT prod_price_code FROM products WHERE id=" + getProductId() + "))";
        sql = "SELECT v.default_warehouse_id 'warehouseId' FROM vendors v, product_price_codes ppc, products p WHERE v.id=ppc.dropship_vendor AND ppc.prod_price_code=p.prod_price_code AND p.id=" + getProductId();
        rs11 = st.executeQuery(sql);
        if (rs11.next()) {
          warehouseId = rs11.getString("warehouseId");
        }
        rs11.close();
        if (warehouseId.equals("0") || warehouseId == null) {
          warehouseId = "66";
        }
      }
      //query = "SELECT zip 'zipFrom' FROM company_locations WHERE id=(SELECT location_id FROM warehouses WHERE id=" + warehouseId + ")";
      query = "SELECT lus.state_abreviation 'zipFromState', cl.zip 'zipFrom', luc.value 'zipFromCountry' FROM company_locations cl, warehouses w, lu_states lus, lu_countries luc WHERE cl.id=w.location_id AND w.id=" + warehouseId + " AND cl.state=lus.id AND cl.country_id=luc.id";
    }
    
    ResultSet rs1 = st.executeQuery(query);
    if (rs1.next()) {
      setZipFrom(rs1.getString("zipFrom"));
      setZipFromState(rs1.getString("zipFromState"));
      setZipFromCountry(rs1.getString("zipFromCountry"));
    }
    rs1.close();

    if (flag == 1) {
      //query = "SELECT zip 'zipTo' FROM locations WHERE locationtypeid=1 and contactid=(SELECT jbuyer_contact_id FROM jobs WHERE id=" + getJobId() + ")";
      query = "SELECT lus.state_abreviation 'zipToState', l.zip 'zipTo', luc.value 'zipToCountry' FROM locations l, jobs j, lu_states lus, lu_countries luc WHERE l.locationtypeid=1 and l.contactid=j.jbuyer_contact_id AND j.id=" + getJobId() + " AND l.state=lus.id AND l.country_id=luc.id";
    }
    else if (flag == 2) {
      //query = "SELECT zip 'zipTo' FROM locations WHERE locationtypeid=1 AND contactid=(SELECT id FROM contacts WHERE id=" + getContactId() + ")";
      query = "SELECT lus.state_abreviation 'zipToState', l.zip 'zipTo', luc.value 'zipToCountry',luc.use_calculated_shipping 'useCountryShipping' FROM locations l, contacts c, lu_states lus, lu_countries luc WHERE l.locationtypeid=1 AND l.contactid=c.id AND c.id=" + getContactId() + " AND l.state=lus.id AND l.country_id=luc.id";
    }
    ResultSet rs2 = st.executeQuery(query);
    if (rs2.next()) {
      setZipTo(rs2.getString("zipTo"));
      setZipToState(rs2.getString("zipToState"));
      setZipToCountry(rs2.getString("zipToCountry"));
      setCalcCountry(rs2.getString("useCountryShipping"));
    }
    rs2.close();

    if (flag == 1) {
      //query = "SELECT weight_per_box, length, width, height, number_of_boxes FROM product_prices WHERE quantity=(SELECT quantity FROM jobs WHERE id=" + getJobId() + ") AND prod_price_code=(SELECT prod_price_code FROM products WHERE id=(SELECT product_id FROM jobs WHERE id=" + getJobId() + "))";
      query = "SELECT pp.weight_per_box, pp.length, pp.width, pp.height, pp.number_of_boxes FROM product_prices pp, jobs j WHERE pp.quantity=(SELECT quantity FROM jobs WHERE id=" + getJobId() + ") AND prod_price_code=(SELECT prod_price_code FROM products WHERE id=(SELECT product_id FROM jobs WHERE id=" + getJobId() + "))";
    }
    else if (flag == 2) {
      //query = "SELECT weight_per_box, length, width, height, number_of_boxes FROM product_prices WHERE quantity=" + getAmount() + " AND prod_price_code=(SELECT prod_price_code FROM products WHERE id=" + getProductId() + ")";
      query = "SELECT pp.weight_per_box, pp.length, pp.width, pp.height, pp.number_of_boxes FROM product_prices pp, products p WHERE pp.quantity=" + getAmount() + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + getProductId();
    }
    ResultSet rs3 = st.executeQuery(query);
    if (rs3.next()) {
      setWeight(rs3.getString("weight_per_box"));
      setLength(rs3.getString("length"));
      setWidth(rs3.getString("width"));
      setHeight(rs3.getString("height"));
      setQuantity(rs3.getString("number_of_boxes"));
    }
    rs3.close();

    if (getShipper().equals("")) {
      setShipper("UPS");
    }
    if (flag == 1) {
      //query = "SELECT DISTINCT shipper_type, account_number, user_name, password, xml_key, meter_number FROM shipping_accounts WHERE vendor_id=(SELECT dropship_vendor FROM jobs WHERE id=" + getJobId() + ")";
      query = "SELECT DISTINCT sa.shipper_type, sa.account_number, sa.user_name, sa.password, sa.xml_key, sa.meter_number,sh.use_full_shipcharge FROM shipping_accounts sa, jobs j,site_hosts sh WHERE sh.id="+sitehostid+" and sa.vendor_id=j.dropship_vendor AND j.id=" + getJobId();
    }
    else if (flag == 2) {
      //query = "SELECT DISTINCT account_number, user_name, password, xml_key, meter_number FROM shipping_accounts WHERE shipper_type='" + getShipper().toUpperCase() + "' AND vendor_id=(SELECT DISTINCT ds_vendor FROM product_prices WHERE quantity=" + getAmount() + " AND prod_price_code=(SELECT prod_price_code FROM products WHERE id=" + getProductId() + "))";
      query = "SELECT DISTINCT sa.account_number, sa.user_name, sa.password, sa.xml_key, sa.meter_number,sh.use_full_shipcharge FROM shipping_accounts sa, product_prices pp, products p,site_hosts sh WHERE sh.id="+sitehostid+" and sa.shipper_type='" + getShipper().toUpperCase() + "' AND sa.vendor_id=pp.ds_vendor AND pp.quantity=" + getAmount() + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + getProductId();
    }
    ResultSet rs41 = st.executeQuery(query);
    if (rs41.next()) {
      if (flag == 1) {
        setShipper(rs41.getString("shipper_type"));
      }

      setShipperAccountNumber(rs41.getString("account_number"));
      setUpsUserName(rs41.getString("user_name"));
      setUpsPassword(rs41.getString("password"));
      setUpsXMLAccessKey(rs41.getString("xml_key"));
      setFdxMeterNumber(rs41.getString("meter_number"));
      setUseDiscPrice(rs41.getInt("use_full_shipcharge"));
    } else {	
      //if (flag == 1) {
      //  query = "SELECT DISTINCT shipper_type, account_number, user_name, password, xml_key, meter_number FROM shipping_accounts WHERE vendor_id=105";
      //}
      //else if (flag == 2) {
      //  query = "SELECT DISTINCT account_number, user_name, password, xml_key, meter_number FROM shipping_accounts WHERE shipper_type='" + getShipper().toUpperCase() + "' AND vendor_id=105";
      //}
      query = "SELECT DISTINCT account_number, user_name, password, xml_key, meter_number,sh.use_full_shipcharge FROM shipping_accounts,site_hosts sh WHERE sh.id="+sitehostid+" and shipper_type='" + getShipper().toUpperCase() + "' AND vendor_id=105";
      ResultSet rs42 = st.executeQuery(query);
      if (rs42.next()) {
        //if (flag == 1) {
        //  setShipper(rs42.getString("shipper_type"));
        //}
        setShipperAccountNumber(rs42.getString("account_number"));
        setUpsUserName(rs42.getString("user_name"));
        setUpsPassword(rs42.getString("password"));
        setUpsXMLAccessKey(rs42.getString("xml_key"));
        setFdxMeterNumber(rs42.getString("meter_number"));
        setUseDiscPrice(rs42.getInt("use_full_shipcharge"));
      }
      rs42.close();
    }
    rs41.close();

    st.close();
    conn.close();
  }

  public void getShippingCost(String shipper) 
      throws ClassNotFoundException, Exception {
	    try {
			setGroundCost(0);
			setNextDayCost(0);
			setSecondDayCost(0);
			setThreeDayCost(0);
			System.out.println("DiscPrice: " + getUseDiscPrice());
			System.out.println("CalcCountry: " + getCalcCountry());
			Connection conn = DBConnect.getConnection();
			Statement st = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);

			try {
			    String query = "SELECT distinct use_full_shipcharge,use_calculated_shipping FROM site_hosts sh left join lu_countries lu on lu.value='"+getZipToCountry()+"' where sh.id="+sitehostid;
				ResultSet rs41 = st.executeQuery(query);
				if (rs41.next()) {
					setUseDiscPrice(rs41.getInt("use_full_shipcharge"));
					setCalcCountry(rs41.getString("use_calculated_shipping"));
				}
				System.out.println("DiscPrice: " + getUseDiscPrice());
				System.out.println("CalcCountry: " + getCalcCountry());
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}finally{
				st.close();
				conn.close();
			}
			
			
			if (shipper.equalsIgnoreCase("ups")) {
			      ShippingXMLTransmitter upsXMLTransmitter = new ShippingXMLTransmitter(upsHostname, protocol);
			      ShippingXMLTransmitter discUpsXMLTransmitter = new ShippingXMLTransmitter(upsHostname, protocol);

			  // Create request XML..
			      StringBuffer upsRequestXML = getUPSAccessRequestXML(getUpsXMLAccessKey(), getUpsUserName(), getUpsPassword());
			      StringBuffer discUpsRequestXML = getUPSAccessRequestXML(getUpsXMLAccessKey(), getUpsUserName(), getUpsPassword());
			      upsRequestXML.append(getUPSShipRateRequestXML(getZipFrom(), getZipTo(), getWeight(), getLength(), getWidth(), getHeight(), getQuantity(), getShipperAccountNumber(), upsPackagingType, upsPickupType));
			      discUpsRequestXML.append(getUPSShipRateRequestXML(getZipFrom(), getZipTo(), getWeight(), getLength(), getWidth(), getHeight(), getQuantity(), getShipperAccountNumber(), upsPackagingType, upsPickupTypeDisc));

			      upsXMLTransmitter.setXml(upsRequestXML);
			      discUpsXMLTransmitter.setXml(discUpsRequestXML);

			  // Create response doc..
			      Document upsResponseDoc = getResponseDocument(upsXMLTransmitter, upsService);
			      Document discUpsResponseDoc = getResponseDocument(discUpsXMLTransmitter, upsService);

			  // Fill response container for future use to calculate Shipping Rates..
			      UPSRatingServiceResponseContainer rsrc = fillUPSResponseContainer(upsResponseDoc);
			      UPSRatingServiceResponseContainer discRsrc = fillUPSResponseContainer(discUpsResponseDoc);

			  // Calculate Shipping Cost as per the Shipment Type..
			  // Any of the Shipment Type Code can be used to calculate Shipping Cost..
					System.out.println("DiscPrice 2:" + getUseDiscPrice());
					System.out.println("CalcCountry 2:" + getCalcCountry());
			  if (getCalcCountry().equals("1")) {
				  if(getUseDiscPrice()==1){
				        setGroundCost(getUPSShippingCost(UPS_GROUND, rsrc));
				        setNextDayCost(getUPSShippingCost(UPS_NEXT_DAY_AIR, rsrc));
				        setSecondDayCost(getUPSShippingCost(UPS_SECOND_DAY_AIR, rsrc));
				        setThreeDayCost(getUPSShippingCost(UPS_THREE_DAY_SELECT, rsrc));
				  }else{
				        setGroundCost(getUPSShippingCost(UPS_GROUND, discRsrc));
				        setNextDayCost(getUPSShippingCost(UPS_NEXT_DAY_AIR, discRsrc));
				        setSecondDayCost(getUPSShippingCost(UPS_SECOND_DAY_AIR, discRsrc));
				        setThreeDayCost(getUPSShippingCost(UPS_THREE_DAY_SELECT, discRsrc));
				  }
			        
			        setDiscGroundCost(getUPSShippingCost(UPS_GROUND, discRsrc));
			        setDiscNextDayCost(getUPSShippingCost(UPS_NEXT_DAY_AIR, discRsrc));
			        setDiscSecondDayCost(getUPSShippingCost(UPS_SECOND_DAY_AIR, discRsrc));
			        setDiscThreeDayCost(getUPSShippingCost(UPS_THREE_DAY_SELECT, discRsrc));
			        
			        setFullGroundCost(getUPSShippingCost(UPS_GROUND, rsrc));
			        setFullNextDayCost(getUPSShippingCost(UPS_NEXT_DAY_AIR, rsrc));
			        setFullSecondDayCost(getUPSShippingCost(UPS_SECOND_DAY_AIR, rsrc));
			        setFullThreeDayCost(getUPSShippingCost(UPS_THREE_DAY_SELECT, rsrc));
			  }
			  
			} else if (shipper.equalsIgnoreCase("fedex")) {
     ShippingXMLTransmitter fdxXMLTransmitter = new ShippingXMLTransmitter(fdxHostname, protocol);

     // Create request XML..
     StringBuffer fdxRequestXML = getFDXShipRateRequestXML(getShipperAccountNumber(), getFdxMeterNumber(), getZipFrom(), getZipTo(), getWeight(), getLength(), getWidth(), getHeight(), getQuantity());
     fdxXMLTransmitter.setXml(fdxRequestXML);

     // Create response doc..
     Document fdxResponseDoc = getResponseDocument(fdxXMLTransmitter, fdxService);

     // Fill response container for future use to calculate Shipping Rates..
     FDXRateAvailableServiceResponseContainer rasrc = fillFDXResponseContainer(fdxResponseDoc);

     // Calculate Shipping Cost as per the Shipment Type..
     // Any of the Shipment Type Code can be used to calculate Shipping Cost,
     if (getCalcCountry().equals("1")) {
			setGroundCost(getFDXShippingCost("FEDEXGROUND", rasrc));
			setSecondDayCost(getFDXShippingCost("FEDEX2DAY", rasrc));
     }
   }
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
  }

  public double getHandlingCost(double jobPrice, double shipPrice)
      throws ClassNotFoundException, Exception {

    double maxPercentJobPrice = 0;
    double maxPercentShipPrice = 0;
    subFee = 0;
    mcFee = 0;
    double mcFee1 = 0;
    double mcFee2 = 0;

    int flag = 0;

    if (!(getJobId().equals(""))) {
      flag = 1;
    }
    else if ((!(getProductId().equals(""))) && (!(getContactId().equals("")))) {
      flag = 2;
    }

    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
    String query = "";

    if (flag == 1) {
      query = "SELECT max_percent_jobprice, max_percent_shipprice, std_subvendor_hand, std_vend_hand FROM product_prices WHERE quantity=(SELECT quantity FROM jobs WHERE id=" + getJobId() + ") AND prod_price_code=(SELECT prod_price_code FROM products WHERE id=(SELECT product_id FROM jobs WHERE id=" + getJobId() + "))";
    }
    else if (flag == 2) {
      if (jobPrice == 0.00) {
        query = "SELECT price, max_percent_jobprice, max_percent_shipprice, std_subvendor_hand, std_vend_hand FROM product_prices WHERE quantity=" + getAmount() + " AND prod_price_code=(SELECT prod_price_code FROM products WHERE id=" + getProductId() + ")";
      }
      else {
        query = "SELECT max_percent_jobprice, max_percent_shipprice, std_subvendor_hand, std_vend_hand FROM product_prices WHERE quantity=" + getAmount() + " AND prod_price_code=(SELECT prod_price_code FROM products WHERE id=" + getProductId() + ")";
      }
    }

    ResultSet rs = st.executeQuery(query);
    if (rs.next()) {
      if (jobPrice == 0.00) {
        jobPrice = Double.parseDouble(rs.getString("price"));
      }
      maxPercentJobPrice = Double.parseDouble(rs.getString("max_percent_jobprice"));
      maxPercentShipPrice = Double.parseDouble(rs.getString("max_percent_shipprice"));
      subFee = Double.parseDouble(rs.getString("std_subvendor_hand"));
      mcFee = Double.parseDouble(rs.getString("std_vend_hand"));
    //mcFee1 = mcFee2 = mcFee;
    }
    rs.close();
    st.close();
    conn.close();

    double maxJobPrice = jobPrice * (maxPercentJobPrice / 100);

    // Test 1 (Total ShipPrice not more than XX% of JobPrice due to MCFee)..
    if ((shipPrice + subFee + mcFee) < maxJobPrice) {
    	mcFee1 = mcFee;
    }
    else if ((shipPrice + subFee) >= maxJobPrice) {
    	mcFee1 = 0;
    }
    else {
    	mcFee1 = maxJobPrice - (shipPrice + subFee);
    }

    // Test 2 (MCFee not more than YY% of Total ShipPrice)..
    if ((mcFee / (shipPrice + subFee + mcFee)) <= (maxPercentShipPrice / 100)) {
    	mcFee2 = mcFee;
    } else if ((mcFee / (shipPrice + subFee + mcFee)) > (maxPercentShipPrice / 100)) {
    	mcFee2 = (shipPrice + subFee) * ((maxPercentShipPrice / 100) / (1 - (maxPercentShipPrice / 100)));
    }

    mcFee = Math.min(mcFee1, mcFee2);

    return (subFee + mcFee);
  }

  public double getHandlingCost(double jobPrice, double shipPrice, double maxPercentJobPrice, double maxPercentShipPrice, double subFee, double mcFee) {
    this.mcFee = mcFee;
    this.subFee = subFee;
    double mcFee1 = 0;
    double mcFee2 = 0;

    double maxJobPrice = jobPrice * (maxPercentJobPrice / 100);

    // Test 1 (Total ShipPrice not more than XX% of JobPrice due to MCFee)..
    if ((shipPrice + this.subFee + this.mcFee) < maxJobPrice) {
      mcFee1 = this.mcFee;
    }
    else if ((shipPrice + this.subFee) >= maxJobPrice) {
      mcFee1 = 0;
    }
    else {
      mcFee1 = maxJobPrice - (shipPrice + this.subFee);
    }

    // Test 2 (MCFee not more than YY% of Total ShipPrice)..
    if ((this.mcFee / (shipPrice + this.subFee + this.mcFee)) <= (maxPercentShipPrice / 100)) {
      mcFee2 = this.mcFee;
    }
    else if ((this.mcFee / (shipPrice + this.subFee + this.mcFee)) > (maxPercentShipPrice / 100)) {
      mcFee2 = (shipPrice + this.subFee) * ((maxPercentShipPrice / 100) / (1 - (maxPercentShipPrice / 100)));
    }

    this.mcFee = Math.min(mcFee1, mcFee2);

    return (this.subFee + this.mcFee);
  }

  private String getXMLNodes(Element element) {
    String resp = "";
    resp += element.getNodeName() + " = " + element.getNodeValue() + "  ---  ";
    if (element.hasChildNodes()) {
      resp += "**";
      int len = element.getChildNodes().getLength();
      for (int i = 0; i < len; i++) {
        if (element.getChildNodes().item(i).hasChildNodes()) {
          resp += getXMLNodes((Element) element.getChildNodes().item(i));
        }
        else {
          resp += element.getChildNodes().item(i).getNodeName() + " = " + element.getChildNodes().item(i).getNodeValue() + "  ---  ";
        }
      }
    }
    return resp;
  }

  private String getNodeTextContent(Node node) {
    for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
      if (child.getNodeName().equalsIgnoreCase("#text")) {
        return node.getFirstChild().getNodeValue();
      }
    }
    return null;
  }

  public double getUPSShippingCost(String shipType, UPSRatingServiceResponseContainer rsrc) {
    Iterator rsIt = rsrc.getUPSRatedShipments().iterator();
    double cost = 0;
    while (rsIt.hasNext()) {
      UPSRatingServiceResponseContainer.UPSRatedShipment rsrs = (UPSRatingServiceResponseContainer.UPSRatedShipment) rsIt.next();
      if (rsrs.getService().code.equals(shipType)) {
        cost = Double.parseDouble(rsrs.getTotalCharges().monetaryValue);
      //return cost;
      }
    }
    return cost;
  }

  public double getFDXShippingCost(String shipType, FDXRateAvailableServiceResponseContainer rasrc) {
    Iterator rasIt = rasrc.getFdxReplyHeader().getEntries().iterator();
    double cost = 0;
    while (rasIt.hasNext()) {
      FDXRateAvailableServiceResponseContainer.FDXReplyHeader.Entry entry = (FDXRateAvailableServiceResponseContainer.FDXReplyHeader.Entry) rasIt.next();
      if (entry.getService().equals(shipType)) {
        cost = Double.parseDouble(entry.getEstimatedCharges().getDiscountedCharges().netCharge);
      //return cost;
      }
    }
    return cost;
  }

  private StringBuffer getUPSAccessRequestXML(String accessKey, String username, String password) {
    StringBuffer upsAccessRequest = new StringBuffer("<?xml version=\"1.0\"?>");

    upsAccessRequest.append("<AccessRequest xml:lang=\"en-US\">");
    upsAccessRequest.append("	<AccessLicenseNumber>" + accessKey + "</AccessLicenseNumber>");
    upsAccessRequest.append("	<UserId>" + username + "</UserId>");
    upsAccessRequest.append("	<Password>" + password + "</Password>");
    upsAccessRequest.append("</AccessRequest>");

    return upsAccessRequest;
  }

  private StringBuffer getUPSShipRateRequestXML(String zipFrom, String zipTo, String weight, String length, String width, String height, String quantity, String UPSAccount, String packageType, String pickupType) {
    StringBuffer upsShipRateRequest = new StringBuffer("<?xml version=\"1.0\"?>");
    SimpleLookups sl = new SimpleLookups();
    upsShipRateRequest.append("<RatingServiceSelectionRequest xml:lang=\"en-US\">");
    upsShipRateRequest.append("<Request>");
    upsShipRateRequest.append("	<TransactionReference>");
    upsShipRateRequest.append("   <CustomerContext>Rating and Service</CustomerContext>");
    upsShipRateRequest.append("		<XpciVersion>1.0001</XpciVersion>");
    upsShipRateRequest.append("	</TransactionReference>");
    upsShipRateRequest.append("	<RequestAction>Rate</RequestAction>");
    upsShipRateRequest.append("	<RequestOption>Shop</RequestOption>");
    upsShipRateRequest.append("</Request>");
    upsShipRateRequest.append("<PickupType>");
    upsShipRateRequest.append("	<Code>" + pickupType + "</Code>");
    upsShipRateRequest.append("</PickupType>");
    upsShipRateRequest.append("<Shipment>");
    upsShipRateRequest.append("	<Shipper>");
    upsShipRateRequest.append("		<ShipperNumber>" + UPSAccount + "</ShipperNumber>");
    upsShipRateRequest.append("		<Address>");
    //upsShipRateRequest.append("			<StateProvinceCode>" + zipFromState + "</StateProvinceCode>");
    upsShipRateRequest.append("			<PostalCode>" + zipFrom + "</PostalCode>");
    upsShipRateRequest.append("			<CountryCode>US</CountryCode>");
    upsShipRateRequest.append("		</Address>");
    upsShipRateRequest.append("	</Shipper>");
    upsShipRateRequest.append("	<ShipTo>");
    upsShipRateRequest.append("		<Address>");
    //upsShipRateRequest.append("			<StateProvinceCode>" + zipToState + "</StateProvinceCode>");
    upsShipRateRequest.append("			<PostalCode>" + zipTo + "</PostalCode>");
    String shipToCountry="";
	try {
		shipToCountry = sl.getValue("lu_ups_countries","value","'"+getZipToCountry()+"'","ups_code");
	} catch (SQLException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
    upsShipRateRequest.append("			<CountryCode>"+shipToCountry+"</CountryCode>");
    upsShipRateRequest.append("		</Address>");
    upsShipRateRequest.append("	</ShipTo>");
    for (int i = 0; i < Integer.parseInt(quantity); i++) {
      upsShipRateRequest.append("	<Package>");
      upsShipRateRequest.append("		<PackagingType>");
      upsShipRateRequest.append("			<Code>" + packageType + "</Code>");
      upsShipRateRequest.append("			<Description>Package</Description>");
      upsShipRateRequest.append("		</PackagingType>");
      upsShipRateRequest.append("   <Dimensions>");
      upsShipRateRequest.append("     <UnitOfMeasurement>");
      upsShipRateRequest.append("       <Code>IN</Code>");
      upsShipRateRequest.append("     </UnitOfMeasurement>");
      upsShipRateRequest.append("     <Length>" + length + "</Length>");
      upsShipRateRequest.append("     <Width>" + width + "</Width>");
      upsShipRateRequest.append("     <Height>" + height + "</Height>");
      upsShipRateRequest.append("   </Dimensions>");
      upsShipRateRequest.append("		<Description>Rate Shipping</Description>");
      upsShipRateRequest.append("		<PackageWeight>");
      upsShipRateRequest.append("			<UnitOfMeasurement>");
      upsShipRateRequest.append("       <Code>LBS</Code>");
      upsShipRateRequest.append("     </UnitOfMeasurement>");
      upsShipRateRequest.append("			<Weight>" + weight + "</Weight>");
      upsShipRateRequest.append("		</PackageWeight>");
      upsShipRateRequest.append("	</Package>");
    }
    upsShipRateRequest.append("</Shipment>");
    upsShipRateRequest.append("</RatingServiceSelectionRequest>");

    return upsShipRateRequest;
  }

  private StringBuffer getFDXShipRateRequestXML(String FDXAccountNumber, String FDXMeterNumber, String zipFrom, String zipTo, String weight, String length, String width, String height, String quantity) {
    StringBuffer fdxShipRateRequest = new StringBuffer("<?xml version='1.0' encoding='UTF-8' ?>");

    fdxShipRateRequest.append("<FDXRateAvailableServicesRequest xmlns:api='http://www.fedex.com/fsmapi' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:noNamespaceSchemaLocation='FDXRateAvailableServicesRequest.xsd'>");
    fdxShipRateRequest.append("<RequestHeader>");
    fdxShipRateRequest.append(" <AccountNumber>" + FDXAccountNumber + "</AccountNumber>");
    fdxShipRateRequest.append(" <MeterNumber>" + FDXMeterNumber + "</MeterNumber>");
    //fdxShipRateRequest.append(" <CarrierCode>FDXG</CarrierCode>"); // FDXG-Ground, FDXE-Express, Omit this tag-Both..
    fdxShipRateRequest.append("</RequestHeader>");
    //fdxShipRateRequest.append("<ShipDate>" & strUKDate & "</ShipDate>");
    fdxShipRateRequest.append("<DropoffType>REGULARPICKUP</DropoffType>");
    fdxShipRateRequest.append("<Packaging>YOURPACKAGING</Packaging>");
    fdxShipRateRequest.append("<WeightUnits>LBS</WeightUnits>");
    fdxShipRateRequest.append("<Weight>" + weight + "</Weight>");
    fdxShipRateRequest.append("<ListRate>false</ListRate>");
    fdxShipRateRequest.append("<OriginAddress>");
    //fdxShipRateRequest.append(" <StateOrProvinceCode>" + zipFromState + "</StateOrProvinceCode>");
    fdxShipRateRequest.append(" <PostalCode>" + zipFrom + "</PostalCode>");
    fdxShipRateRequest.append(" <CountryCode>US</CountryCode>");
    fdxShipRateRequest.append("</OriginAddress>");
    fdxShipRateRequest.append("<DestinationAddress>");
    //fdxShipRateRequest.append(" <StateOrProvinceCode>" + zipToState + "</StateOrProvinceCode>");
    fdxShipRateRequest.append(" <PostalCode>" + zipTo + "</PostalCode>");
    fdxShipRateRequest.append(" <CountryCode>US</CountryCode>");
    fdxShipRateRequest.append("</DestinationAddress>");
    fdxShipRateRequest.append("<Payment>");
    fdxShipRateRequest.append(" <PayorType>SENDER</PayorType>");
    fdxShipRateRequest.append("</Payment>");
    fdxShipRateRequest.append("<Dimensions>");
    fdxShipRateRequest.append(" <Length>" + length + "</Length>");
    fdxShipRateRequest.append(" <Width>" + width + "</Width>");
    fdxShipRateRequest.append(" <Height>" + height + "</Height>");
    fdxShipRateRequest.append(" <Units>IN</Units>");
    fdxShipRateRequest.append("</Dimensions>");
    fdxShipRateRequest.append("<PackageCount>" + quantity + "</PackageCount>");
    fdxShipRateRequest.append("</FDXRateAvailableServicesRequest>");

    return fdxShipRateRequest;
  }

  private Document getResponseDocument(ShippingXMLTransmitter xmlTransmitter, String service) {
    StringBuffer responseXML = new StringBuffer();
    try {
      xmlTransmitter.contactService(service);
      responseXML = xmlTransmitter.getXml();
    }
    catch (Exception ex) {
      Logger.getLogger(ProcessShippingCost.class.getName()).log(Level.SEVERE, null, ex);
    }

    // Parse response XML..
    Document responseDoc = parseXML(responseXML);

    //// Test response XML..
    //String testResponse = "";
    //testResponse = getXMLNodes(responseDoc.getDocumentElement());
    //out.write("alert(\"" + testResponse + "\");");

    return responseDoc;
  }

  public Document parseXML(StringBuffer responseXML) {
    Document doc = null;
    try {
      StringReader sr = new StringReader(responseXML.toString());
      DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
      doc = factory.newDocumentBuilder().parse(new InputSource(sr));
    }
    catch (SAXException ex) {
      Logger.getLogger(ProcessShippingCost.class.getName()).log(Level.SEVERE, null, ex);
    }
    catch (IOException ex) {
      Logger.getLogger(ProcessShippingCost.class.getName()).log(Level.SEVERE, null, ex);
    }
    catch (ParserConfigurationException ex) {
      Logger.getLogger(ProcessShippingCost.class.getName()).log(Level.SEVERE, null, ex);
    }

    return doc;
  }

  public UPSRatingServiceResponseContainer fillUPSResponseContainer(Document doc) {
    UPSRatingServiceResponseContainer rsrc = new UPSRatingServiceResponseContainer();

    Node root = doc.getDocumentElement();

    for (Node mainsection = root.getFirstChild(); mainsection != null; mainsection = mainsection.getNextSibling()) {
      if (mainsection.getNodeName().equalsIgnoreCase("Response")) {
        for (Node node = mainsection.getFirstChild(); node != null; node = node.getNextSibling()) {
          if (node.getNodeName().equalsIgnoreCase("TransactionReference")) {
            for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
              if (child.getNodeName().equalsIgnoreCase("CustomerContext")) {
                rsrc.getUPSResponse().getTransactionReference().customerContext = getNodeTextContent(child);
              }
              else if (child.getNodeName().equalsIgnoreCase("XpciVersion")) {
                rsrc.getUPSResponse().getTransactionReference().xpciVersion = getNodeTextContent(child);
              }
            }
          }
          else if (node.getNodeName().equalsIgnoreCase("ResponseStatusCode")) {
            rsrc.getUPSResponse().setResponseStatusCode(getNodeTextContent(node));
          }
          else if (node.getNodeName().equalsIgnoreCase("ResponseStatusDescription")) {
            rsrc.getUPSResponse().setResponseStatusDescription(getNodeTextContent(node));
          }
          else if (node.getNodeName().equalsIgnoreCase("Error")) {
            //assemble an Error object and add it to the list
            UPSRatingServiceResponseContainer.UPSResponse.Error err = rsrc.getUPSResponse().new Error();

            for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
              if (child.getNodeName().equalsIgnoreCase("ErrorSeverity")) {
                err.errorSeverity = getNodeTextContent(child);
              }
              else if (child.getNodeName().equalsIgnoreCase("ErrorCode")) {
                err.errorCode = getNodeTextContent(child);
              }
              else if (child.getNodeName().equalsIgnoreCase("ErrorDescription")) {
                err.errorDescription = getNodeTextContent(child);
              }
              else if (child.getNodeName().equalsIgnoreCase("MinimumRetrySeconds")) {
                err.minimumRetrySeconds = getNodeTextContent(child);
              }
              else if (child.getNodeName().equalsIgnoreCase("ErrorLocation")) {
                UPSRatingServiceResponseContainer.UPSResponse.Error.ErrorLocation errLoc = err.new ErrorLocation();

                for (Node subchild = child.getFirstChild(); subchild != null; subchild = subchild.getNextSibling()) {
                  if (subchild.getNodeName().equalsIgnoreCase("ErrorLocationElementName")) {
                    errLoc.errorLocationElementName = getNodeTextContent(subchild);
                  }
                  else if (subchild.getNodeName().equalsIgnoreCase("ErrorLocationAttributeName")) {
                    errLoc.errorLocationAttributeName = getNodeTextContent(subchild);
                  }
                }

                err.errorLocations.add(errLoc);
              }
              else if (child.getNodeName().equalsIgnoreCase("ErrorDigest")) {
                String errDigest = getNodeTextContent(child);
                err.errorDigests.add(errDigest);
              }
            }

            rsrc.getUPSResponse().getErrors().add(err);
          }
        }
      }
      else if (mainsection.getNodeName().equalsIgnoreCase("RatedShipment")) {
        UPSRatingServiceResponseContainer.UPSRatedShipment rsrs = rsrc.new UPSRatedShipment();

        for (Node node = mainsection.getFirstChild(); node != null; node = node.getNextSibling()) {
          if (node.getNodeName().equalsIgnoreCase("Service")) {
            for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
              if (child.getNodeName().equalsIgnoreCase("Code")) {
                rsrs.getService().code = getNodeTextContent(child);
              }
              else if (child.getNodeName().equalsIgnoreCase("Description")) {
                rsrs.getService().description = getNodeTextContent(child);
              }
            }
          }
          else if (node.getNodeName().equalsIgnoreCase("RatedShipmentWarning")) {
            rsrs.setRatedShipmentWarning(getNodeTextContent(node));
          }
          else if (node.getNodeName().equalsIgnoreCase("BillingWeight")) {
            for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
              if (child.getNodeName().equalsIgnoreCase("UnitOfMeasurement")) {
                for (Node subchild = child.getFirstChild(); subchild != null; subchild = subchild.getNextSibling()) {
                  if (subchild.getNodeName().equalsIgnoreCase("Code")) {
                    rsrs.getBillingWeight().unitOfMeasurement.code = getNodeTextContent(subchild);
                  }
                  else if (subchild.getNodeName().equalsIgnoreCase("Description")) {
                    rsrs.getBillingWeight().unitOfMeasurement.description = getNodeTextContent(subchild);
                  }
                }
              }
              else if (child.getNodeName().equalsIgnoreCase("Weight")) {
                rsrs.getBillingWeight().weight = getNodeTextContent(child);
              }
            }
          }
          else if (node.getNodeName().equalsIgnoreCase("TransportationCharges")) {
            for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
              if (child.getNodeName().equalsIgnoreCase("CurrencyCode")) {
                rsrs.getTransportationCharges().currencyCode = getNodeTextContent(child);
              }
              else if (child.getNodeName().equalsIgnoreCase("MonetaryValue")) {
                rsrs.getTransportationCharges().monetaryValue = getNodeTextContent(child);
              }
            }
          }
          else if (node.getNodeName().equalsIgnoreCase("ServiceOptionsCharges")) {
            for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
              if (child.getNodeName().equalsIgnoreCase("CurrencyCode")) {
                rsrs.getServiceOptionsCharges().currencyCode = getNodeTextContent(child);
              }
              else if (child.getNodeName().equalsIgnoreCase("MonetaryValue")) {
                rsrs.getServiceOptionsCharges().monetaryValue = getNodeTextContent(child);
              }
            }
          }
          else if (node.getNodeName().equalsIgnoreCase("HandlingChargeAmount")) {
            for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
              if (child.getNodeName().equalsIgnoreCase("CurrencyCode")) {
                rsrs.getHandlingChargeAmount().currencyCode = getNodeTextContent(child);
              }
              else if (child.getNodeName().equalsIgnoreCase("MonetaryValue")) {
                rsrs.getHandlingChargeAmount().monetaryValue = getNodeTextContent(child);
              }
            }
          }
          else if (node.getNodeName().equalsIgnoreCase("TotalCharges")) {
            for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
              if (child.getNodeName().equalsIgnoreCase("CurrencyCode")) {
                rsrs.getTotalCharges().currencyCode = getNodeTextContent(child);
              }
              else if (child.getNodeName().equalsIgnoreCase("MonetaryValue")) {
                rsrs.getTotalCharges().monetaryValue = getNodeTextContent(child);
              }
            }
          }
          else if (node.getNodeName().equalsIgnoreCase("GuaranteedDaysToDelivery")) {
            rsrs.setGuaranteedDaysToDelivery(getNodeTextContent(node));
          }
          else if (node.getNodeName().equalsIgnoreCase("ScheduledDeliveryTime")) {
            rsrs.setScheduledDeliveryTime(getNodeTextContent(node));
          }
          else if (node.getNodeName().equalsIgnoreCase("RatedPackage")) {
            UPSRatingServiceResponseContainer.UPSRatedShipment.RatedPackage rsrp = rsrs.new RatedPackage();

            for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
              if (child.getNodeName().equalsIgnoreCase("TransportationCharges")) {
                for (Node subchild = child.getFirstChild(); subchild != null; subchild = subchild.getNextSibling()) {
                  if (subchild.getNodeName().equalsIgnoreCase("CurrencyCode")) {
                    rsrp.getTransportationCharges().currencyCode = getNodeTextContent(subchild);
                  }
                  else if (subchild.getNodeName().equalsIgnoreCase("MonetaryValue")) {
                    rsrp.getTransportationCharges().monetaryValue = getNodeTextContent(subchild);
                  }
                }
              }
              else if (child.getNodeName().equalsIgnoreCase("ServiceOptionsCharges")) {
                for (Node subchild = child.getFirstChild(); subchild != null; subchild = subchild.getNextSibling()) {
                  if (subchild.getNodeName().equalsIgnoreCase("CurrencyCode")) {
                    rsrp.getServiceOptionsCharges().currencyCode = getNodeTextContent(subchild);
                  }
                  else if (subchild.getNodeName().equalsIgnoreCase("MonetaryValue")) {
                    rsrp.getServiceOptionsCharges().monetaryValue = getNodeTextContent(subchild);
                  }
                }
              }
              else if (child.getNodeName().equalsIgnoreCase("TotalCharges")) {
                for (Node subchild = child.getFirstChild(); subchild != null; subchild = subchild.getNextSibling()) {
                  if (subchild.getNodeName().equalsIgnoreCase("CurrencyCode")) {
                    rsrp.getTotalCharges().currencyCode = getNodeTextContent(subchild);
                  }
                  else if (subchild.getNodeName().equalsIgnoreCase("MonetaryValue")) {
                    rsrp.getTotalCharges().monetaryValue = getNodeTextContent(subchild);
                  }
                }
              }
              else if (child.getNodeName().equalsIgnoreCase("Weight")) {
                rsrp.setWeight(getNodeTextContent(child));
              }
              else if (child.getNodeName().equalsIgnoreCase("BillingWeight")) {
                for (Node subchild = child.getFirstChild(); subchild != null; subchild = subchild.getNextSibling()) {
                  if (subchild.getNodeName().equalsIgnoreCase("UnitOfMeasurement")) {
                    for (Node subsubchild = subchild.getFirstChild(); subsubchild != null; subsubchild = subsubchild.getNextSibling()) {
                      if (subsubchild.getNodeName().equalsIgnoreCase("Code")) {
                        rsrp.getBillingWeight().unitOfMeasurement.code = getNodeTextContent(subsubchild);
                      }
                      else if (subsubchild.getNodeName().equalsIgnoreCase("Description")) {
                        rsrp.getBillingWeight().unitOfMeasurement.description = getNodeTextContent(subsubchild);
                      }
                    }
                  }
                  else if (subchild.getNodeName().equalsIgnoreCase("Weight")) {
                    rsrp.getBillingWeight().weight = getNodeTextContent(subchild);
                  }
                }
              }
            }
            rsrs.getRatedPackages().add(rsrp);
          }
          else if (node.getNodeName().equalsIgnoreCase("NegotiatedRates")) {
            for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
              if (child.getNodeName().equalsIgnoreCase("NetSummaryCharges")) {
                for (Node subchild = child.getFirstChild(); subchild != null; subchild = subchild.getNextSibling()) {
                  if (subchild.getNodeName().equalsIgnoreCase("GrandTotal")) {
                    for (Node subsubchild = subchild.getFirstChild(); subsubchild != null; subsubchild = subsubchild.getNextSibling()) {
                      if (subsubchild.getNodeName().equalsIgnoreCase("CurrencyCode")) {
                        rsrs.getNegotiatedRates().netSummaryCharges.grandTotal.currencyCode = getNodeTextContent(subsubchild);
                      }
                      else if (subsubchild.getNodeName().equalsIgnoreCase("MonetaryValue")) {
                        rsrs.getNegotiatedRates().netSummaryCharges.grandTotal.monetaryValue = getNodeTextContent(subsubchild);
                      }
                    }
                  }
                }
              }
            }
          }
        }
        rsrc.getUPSRatedShipments().add(rsrs);
      }
    }

    return rsrc;
  }

  public FDXRateAvailableServiceResponseContainer fillFDXResponseContainer(Document doc) {
    FDXRateAvailableServiceResponseContainer rasrc = new FDXRateAvailableServiceResponseContainer();

    Node root = doc.getDocumentElement();

    for (Node mainsection = root.getFirstChild(); mainsection != null; mainsection = mainsection.getNextSibling()) {
      if (mainsection.getNodeName().equalsIgnoreCase("Entry")) {
        FDXRateAvailableServiceResponseContainer.FDXReplyHeader.Entry entry = rasrc.getFdxReplyHeader().new Entry();

        for (Node child = mainsection.getFirstChild(); child != null; child = child.getNextSibling()) {
          if (child.getNodeName().equalsIgnoreCase("Service")) {
            entry.setService(getNodeTextContent(child));
          }
          else if (child.getNodeName().equalsIgnoreCase("Packaging")) {
            entry.setPackaging(getNodeTextContent(child));
          }
          else if (child.getNodeName().equalsIgnoreCase("EstimatedCharges")) {
            for (Node subchild = child.getFirstChild(); subchild != null; subchild = subchild.getNextSibling()) {
              if (subchild.getNodeName().equalsIgnoreCase("DimWeightUsed")) {
                entry.getEstimatedCharges().dimWeightUsed = getNodeTextContent(subchild);
              }
              else if (subchild.getNodeName().equalsIgnoreCase("BilledWeight")) {
                entry.getEstimatedCharges().billedWeight = getNodeTextContent(subchild);
              }
              else if (subchild.getNodeName().equalsIgnoreCase("DiscountedCharges")) {
                for (Node subsubchild = subchild.getFirstChild(); subsubchild != null; subsubchild = subsubchild.getNextSibling()) {
                  if (subsubchild.getNodeName().equalsIgnoreCase("BaseCharge")) {
                    entry.getEstimatedCharges().getDiscountedCharges().baseCharge = getNodeTextContent(subsubchild);
                  }
                  else if (subsubchild.getNodeName().equalsIgnoreCase("TotalDiscount")) {
                    entry.getEstimatedCharges().getDiscountedCharges().totalDiscount = getNodeTextContent(subsubchild);
                  }
                  else if (subsubchild.getNodeName().equalsIgnoreCase("TotalSurcharge")) {
                    entry.getEstimatedCharges().getDiscountedCharges().totalSurcharge = getNodeTextContent(subsubchild);
                  }
                  else if (subsubchild.getNodeName().equalsIgnoreCase("NetCharge")) {
                    entry.getEstimatedCharges().getDiscountedCharges().netCharge = getNodeTextContent(subsubchild);
                  }
                  else if (subsubchild.getNodeName().equalsIgnoreCase("EarnedDiscount")) {
                    entry.getEstimatedCharges().getDiscountedCharges().earnedDiscount = getNodeTextContent(subsubchild);
                  }
                }
              }
            }
          }
          else if (child.getNodeName().equalsIgnoreCase("SignatureOption")) {
            entry.setSignatureOption(getNodeTextContent(child));
          }
        }
        rasrc.getFdxReplyHeader().getEntries().add(entry);
      }
    }

    return rasrc;
  }

  public void doPost(HttpServletRequest request, HttpServletResponse response) {
    try {
      //calculateShippingCost(request, response);
      setProductId(request.getParameter("productId"));
      setContactId(request.getParameter("customerId"));
      setAmount(Integer.parseInt(request.getParameter("amount")));
      if (request.getParameter("shipper") != null) {
        setShipper(request.getParameter("shipper"));
      }
      double actualCost = calculateShippingCost();
      double handlingFee = getHandlingCost(0.00, actualCost);
      double totalCost = actualCost + handlingFee;
      PrintWriter out = response.getWriter();
      //out.write("$('GroundCost').value = '" + getGroundCost() + "';");
      //out.write("$('NextDayCost').value = '" + getNextDayCost() + "';");
      //out.write("$('SecondDayCost').value = '" + getSecondDayCost() + "';");
      //out.write("$('ThreeDayCost').value = '" + getThreeDayCost() + "';");
      out.write("$('aCost').innerHTML = 'Actual Shipping Cost (From " + getShipper() + ") : " + actualCost + "';");
      out.write("$('hCost').innerHTML = 'Handling Fees : " + handlingFee + "';");
      out.write("$('tCost').innerHTML = 'Total Cost : " + totalCost + "';");
    }
    catch (ClassNotFoundException ex) {
      Logger.getLogger(ProcessShippingCost.class.getName()).log(Level.SEVERE, null, ex);
    }
    catch (Exception ex) {
      Logger.getLogger(ProcessShippingCost.class.getName()).log(Level.SEVERE, null, ex);
    }
  }

public double getDiscGroundCost() {
	return discGroundCost;
}

public void setDiscGroundCost(double discGroundCost) {
	this.discGroundCost = discGroundCost;
}

public double getDiscNextDayCost() {
	return discNextDayCost;
}

public void setDiscNextDayCost(double discNextDayCost) {
	this.discNextDayCost = discNextDayCost;
}

public double getDiscSecondDayCost() {
	return discSecondDayCost;
}

public void setDiscSecondDayCost(double discSecondDayCost) {
	this.discSecondDayCost = discSecondDayCost;
}

public double getDiscThreeDayCost() {
	return discThreeDayCost;
}

public void setDiscThreeDayCost(double discThreeDayCost) {
	this.discThreeDayCost = discThreeDayCost;
}

public double getFullGroundCost() {
	return fullGroundCost;
}

public void setFullGroundCost(double fullGroundCost) {
	this.fullGroundCost = fullGroundCost;
}

public double getFullNextDayCost() {
	return fullNextDayCost;
}

public void setFullNextDayCost(double fullNextDayCost) {
	this.fullNextDayCost = fullNextDayCost;
}

public double getFullSecondDayCost() {
	return fullSecondDayCost;
}

public void setFullSecondDayCost(double fullSecondDayCost) {
	this.fullSecondDayCost = fullSecondDayCost;
}

public double getFullThreeDayCost() {
	return fullThreeDayCost;
}

public void setFullThreeDayCost(double fullThreeDayCost) {
	this.fullThreeDayCost = fullThreeDayCost;
}

public int getUseDiscPrice() {
	return useDiscPrice;
}

public void setUseDiscPrice(int useDiscPrice) {
	this.useDiscPrice = useDiscPrice;
}

public String getSitehostid() {
	return sitehostid;
}

public void setSitehostid(String sitehostid) {
	this.sitehostid = sitehostid;
}

public String getCalcCountry() {
	return calcCountry;
}

public void setCalcCountry(String calcCountry) {
	this.calcCountry = calcCountry;
}
}
