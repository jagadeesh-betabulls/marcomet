<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*,com.marcomet.environment.*,java.util.*,com.marcomet.catalog.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="shipper" class="com.marcomet.commonprocesses.ProcessShippingCost" scope="page" />
<table width='100%' border='1'><%
//    UserProfile up = (UserProfile) session.getAttribute("userProfile");

    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    DecimalFormat numberFormatter = new DecimalFormat("#,###,###");
    SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");
    String shipmentOption = "1";

    int creditStatus = 0;
    int countryId = 0;
    String nonUSTxt = "";
    String pageId = "";
    String orderSummaryTxt = "";
    String spPageId = "";
    int co_days = 0;
    int jobId = 0;
    String fileName = "";
    int poId = 0;

    double priceSubtotal = 0.00;
    double shipSubtotal = 0.00;
    double depositSubtotal = 0.00;
    double joStdShippingPrice = 0.00;

    int jobCount = -1;
    String shippingType = "";

    int jobNo = -1;
    String shipType = "GROUND";
    CatalogShipmentCreationServlet shipment = new CatalogShipmentCreationServlet();
    if (shipmentOption != null) {
      shipment.setShipmentOption(shipmentOption);
    }
    shipment.createShipment(session);

    ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("shoppingCart");
    if (shoppingCart != null) {
      Vector shipments = shoppingCart.getShipments();
      Vector wareHouses = new Vector();
      if (shipments.size() > 0) {
        for (int j = 0; j < shipments.size(); j++) {
          jobCount = j;
          ShipmentObject so = (ShipmentObject) shipments.elementAt(j);
          so.setZipTo((String)session.getAttribute("zipTo"));
          so.setZipToStateCode(Integer.parseInt((String)session.getAttribute("zipToStateCode")));
          Vector jobs = so.getJobs();
          double soWeight = so.getWeight();
          double soShippingCost = 0.00;
          //soShippingCost = so.getShippingCost() + so.getHandlingCost();
          if (wareHouses.size() == 0) {
            wareHouses.addElement(so.getZipFrom());
            so.calculateSVFee(request);
          } else if (!wareHouses.contains(so.getZipFrom())) {
            so.calculateSVFee(request);
          }

          for (int k = 0; k < jobs.size(); k++) {
            JobObject jo = (JobObject) jobs.elementAt(k);
            int projectId = so.getProjectId(k);

            double price = jo.getPrice();
            double deposit = jo.getEscrowDollarAmount();
            double discount = 0.00;
            double handlingCost = 0.00;
            int shipmentId = 0;
            int shipPricePolicy = 0;
            jo.setDiscount(discount);
            //ordersPresent = true;

            String productId = "", contactId = "", shipPolicy = "";
            int amount = 0, state = 0, shipPriceSource = 0;
            double joTotalWeight = 0.00;
            double joPercentShipment = 0.00, ppShipPercentage = 0.00, pShipPercentage = 0.00;

            state = so.getZipToStateCode();
            if (state > 53 || state == 2 || state == 12) {
              joStdShippingPrice = 0.00;
              shipPricePolicy = 0;
              shipPriceSource = 0;
            } else {
              JobSpecObject jsoProductCode = (JobSpecObject) jo.getJobSpecs().get("9001");
              String query = "SELECT id FROM products WHERE prod_code='" + jsoProductCode.getValue() + "'";
              ResultSet rs = st.executeQuery(query);
              if (rs.next()) {
                productId = rs.getString("id");
              }
              rs.close();
              contactId = (String) session.getAttribute("contactId");
              JobSpecObject jsoQuantity = (JobSpecObject) jo.getJobSpecs().get("705");
              amount = Integer.parseInt(jsoQuantity.getValue());
              query = "SELECT pp.weight_per_box 'weight', pp.number_of_boxes FROM product_prices pp, products p WHERE pp.quantity=" + amount + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
              ResultSet rs1 = st.executeQuery(query);
              if (rs1.next()) {
                joTotalWeight = (Double.parseDouble(rs1.getString("number_of_boxes")) * Double.parseDouble(rs1.getString("weight")));
              }

              query = "SELECT pp.ship_price_policy, pp.std_ship_price, pp.pp_default_ship_percentage, p.default_ship_percentage FROM product_prices pp, products p WHERE pp.quantity=" + amount + " AND pp.prod_price_code=p.prod_price_code AND p.id=" + productId;
              ResultSet rs2 = st.executeQuery(query);
              if (rs2.next()) {
                shipPolicy = rs2.getString("ship_price_policy");
                ppShipPercentage = rs2.getDouble("pp_default_ship_percentage");
                pShipPercentage = rs2.getDouble("default_ship_percentage");
                if (shipPolicy.equals("0")) {
                  if (soWeight == 0.00) {
                    if (ppShipPercentage == 0.00) {
                      if (pShipPercentage == 0.00) {
                        joStdShippingPrice = 0.00;
                        shipPricePolicy = 0;
                        shipPriceSource = 1;
                      } else {
                        joStdShippingPrice = (price * (pShipPercentage / 100));
                        shipPricePolicy = 2;
                        shipPriceSource = 1;
                      }
                    } else {
                      joStdShippingPrice = (price * (ppShipPercentage / 100));
                      shipPricePolicy = 2;
                      shipPriceSource = 1;
                    }
                  } else {

                    so.calculateShippingCost(request);
                    soShippingCost = so.getShippingPrice();
                    if (soShippingCost != 0.00) {
                      joPercentShipment = ((joTotalWeight / soWeight) * 100);
                      joStdShippingPrice = (soShippingCost * (joPercentShipment / 100));
                      shippingType = so.getShipType();
                      shipmentId = so.getId();

                    } else {
                      if (ppShipPercentage == 0.00) {
                        if (pShipPercentage == 0.00) {
                          joStdShippingPrice = 0.00;
                          shipPricePolicy = 0;
                          shipPriceSource = 1;
                        } else {
                          joStdShippingPrice = (price * (pShipPercentage / 100));
                          shipPricePolicy = 2;
                          shipPriceSource = 1;
                        }
                      } else {
                        joStdShippingPrice = (price * (ppShipPercentage / 100));
                        shipPricePolicy = 2;
                        shipPriceSource = 1;
                      }
                    }

                    shipPricePolicy = 2;
                    shipPriceSource = 0;
                  }
                } else if (shipPolicy.equals("1")) {
                  joStdShippingPrice = 0.00;
                  shipPricePolicy = 1;
                  shipPriceSource = 1;
                } else if (shipPolicy.equals("2")) {
                  joStdShippingPrice = Double.parseDouble(rs1.getString("std_ship_price"));
                  shipPricePolicy = 2;
                  shipPriceSource = 1;
                } else if (shipPolicy.equals("3")) {
                  if (ppShipPercentage == 0.00) {
                    if (pShipPercentage == 0.00) {
                      joStdShippingPrice = 0.00;
                      shipPricePolicy = 0;
                      shipPriceSource = 1;
                    } else {
                      joStdShippingPrice = (price * (pShipPercentage / 100));
                      shipPricePolicy = 3;
                      shipPriceSource = 1;
                    }
                  } else {
                    joStdShippingPrice = (price * (ppShipPercentage / 100));
                    shipPricePolicy = 3;
                    shipPriceSource = 1;
                  }
                } else if (shipPolicy.equals("4")) {
                  joStdShippingPrice = 0.00;
                  shipPricePolicy = 4;
                  shipPriceSource = 0;
                }
              }
            }
            jo.setShipPricePolicy(shipPricePolicy);
            jo.setShipPriceSource(shipPriceSource);
            jo.setShippingPrice(joStdShippingPrice);
            jo.setShippingType(shippingType);
            jo.setShipmentId(shipmentId);
            jo.setPercentageOfShipment(joPercentShipment);
          %>
          <tr>
            <td class="lineitems"><a href="javascript:pop('/catalog/summary/OrderSummaryJobDetails.jsp?jobId=<%= jo.getId()%>','500','500')" class="minderACTION"><%=jo.getJobName()%></a></td>
            <td class="lineitems">
              <div align="right"><%=((jo.getQuantity() == 0) ? "NA" : numberFormatter.format(jo.getQuantity()))%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= (jo.isRFQ()) ? "RFQ" : formater.getCurrency(price)%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(deposit)%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(discount)%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= (shipPolicy.equals("0")) ? ((joStdShippingPrice == 0.00) ? "TBD *" : formater.getCurrency(joStdShippingPrice)) : (shipPolicy.equals("4")) ? "TBD*" : formater.getCurrency(joStdShippingPrice)%></div>
            </td>
            <%double total = ((jo.isRFQ() ? 0.00 : price)) - discount - deposit + joStdShippingPrice;%>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(total)%></div>
            </td>
          </tr><%
          }
       }
              double totalPrice = shoppingCart.getOrderPrice() - shoppingCart.getDiscount() - shoppingCart.getOrderEscrowTotal() + shoppingCart.getShippingPrice();
          %><tr>
            <td>&nbsp;</td>
            <td class="lineitems">
              <div align="right">Order Totals:</div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(shoppingCart.getOrderPrice())%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(shoppingCart.getOrderEscrowTotal())%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(shoppingCart.getDiscount())%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(shoppingCart.getShippingPrice())%></div>
            </td>
            <td class="lineitems">
              <div align="right"><%= formater.getCurrency(totalPrice)%></div>
            </td>
          </tr><%}%>
<%}%></table><%
    st.close();
    conn.close();
    session.removeAttribute("shoppingCart");
%>