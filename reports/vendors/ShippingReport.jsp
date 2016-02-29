<%@ page import="java.text.*,java.sql.*,com.marcomet.tools.*;" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<div id="divWait" align="center" style="position:absolute;top:50%;left:50%">
  <h5>Please Wait<img src="/images/generic/dotdot.gif" width="72" height="10"></h5>
</div>
<jsp:useBean id="shipper" class="com.marcomet.commonprocesses.ProcessShippingCost" scope="page" />
<%
    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    Statement st1 = conn.createStatement();
    Statement st2 = conn.createStatement();
    Statement st3 = conn.createStatement();
%>
<html>
  <head>
    <title>Shipping Report</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
    <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
    <script language="JavaScript" src="/javascripts/mainlib.js"></script>
  </head>
  <body>
    <p class="Title">Jobs Shipping Report</p>
    <%--Below commented code is for displaying Shipping Report..--%>
    <%--<table border="0" cellpadding="2" cellspacing="0" width="100%">
      <tr>
        <td class="planheader1">Job Number</td>
        <td class="planheader1">Product ID</td>
        <td class="planheader1">Product Code</td>
        <td class="planheader1">Quantity Shipped</td>
        <td class="planheader1">Job Price</td>
        <td class="planheader1">Amount Billed</td>
        <td class="planheader1">Job Cost</td>
        <td class="planheader1">Shipping Cost</td>
        <td class="planheader1">Calculated Shipping Cost</td>
        <td class="planheader1">Shipping Price</td>
        <td class="planheader1">% of Job Total</td>
        <td class="planheader1">Calculated Shipping Price</td>
        <td class="planheader1">Calculated % of Job Total</td>
      </tr>
      <%
    //String query = "SELECT j.id, j.product_id, j.product_code, j.quantity, j.price 'job price', j.billable, (j.accrued_po_cost + j.accrued_inventory_cost) 'job cost', SUM(sd.cost) 'ship cost', SUM(sd.price) 'ship price', (SUM(sd.price)/j.billable)*100 '% job total' FROM jobs j JOIN (products p JOIN product_prices pp ON p.prod_price_code=pp.prod_price_code AND pp.weight_per_box>0 AND pp.length>0 AND pp.width>0 AND pp.height>0) ON j.product_id=p.id, shipping_data sd WHERE j.id=sd.job_id AND YEAR(j.creation_date)=(YEAR(CURRENT_DATE)-1) GROUP BY j.id ORDER BY j.id";
    String query = "SELECT j.id, j.product_id, j.product_code, j.quantity, j.price 'job price', j.billable, (j.accrued_po_cost + j.accrued_inventory_cost) 'job cost', SUM(sd.cost) 'ship cost', SUM(sd.price) 'ship price', (SUM(sd.price)/j.billable)*100 '% job total', LEFT(sd.method,1) 'shipper' FROM jobs j, products p, product_prices pp, shipping_data sd WHERE j.product_id=p.id AND p.prod_price_code=pp.prod_price_code AND pp.weight_per_box>0 AND pp.length>0 AND pp.width>0 AND pp.height>0 AND j.quantity=pp.quantity AND j.id=sd.job_id AND YEAR(j.creation_date)=(YEAR(CURRENT_DATE)-1) GROUP BY j.id ORDER BY j.id";
    ResultSet rs = st.executeQuery(query);
    if (rs.next()) {
      do {
        shipper.setJobId(rs.getString("id"));
        if (rs.getString("shipper").equalsIgnoreCase("f")) {
          shipper.setShipper("FEDEX");
        }
        //else{
        //  shipper.setShipper("UPS");
        //}
        String calcShipCost = new DecimalFormat("#0.00").format(shipper.calculateShippingCost());
        String calcShipPrice = new DecimalFormat("#0.00").format(Double.parseDouble(calcShipCost) + shipper.getHandlingCost(Double.parseDouble(rs.getString("job price")), Double.parseDouble(calcShipCost)));
      %>
      <tr>
        <td><%= rs.getString("id")%></td>
        <td><%= rs.getString("product_id")%></td>
        <td><%= rs.getString("product_code")%></td>
        <td align="right"><%= rs.getString("quantity")%></td>
        <td align="right"><%= rs.getString("job price")%></td>
        <td align="right"><%= rs.getString("billable")%></td>
        <td align="right"><%= rs.getString("job cost")%></td>
        <td align="right"><%= rs.getString("ship cost")%></td>
        <td align="right"><%= calcShipCost%></td>
        <td align="right"><%= rs.getString("ship price")%></td>
        <td align="right"><%= new DecimalFormat("#0.00").format(Double.parseDouble(rs.getString("% job total")))%></td>
        <td align="right"><%= calcShipPrice%></td>
        <td align="right"><%= new DecimalFormat("#0.00").format((Double.parseDouble(calcShipPrice) / Double.parseDouble(rs.getString("billable"))) * 100)%></td>
      </tr>
      <%} while (rs.next());
        rs.close();
      } else {
      %>
      <tr>
        <td colspan="12">No Record Found.</td>
      </tr>
      <%}%>
    </table>--%>
    <%
    int countUpdate = 0;
    int countInsert = 0;
    String query = "SELECT j.id, j.product_id, j.jwarehouse_id, j.quantity, j.price 'job price', sd.method FROM jobs j, products p, product_prices pp, shipping_data sd WHERE j.product_id=p.id AND p.prod_price_code=pp.prod_price_code AND pp.weight_per_box>0 AND pp.length>0 AND pp.width>0 AND pp.height>0 AND j.quantity=pp.quantity AND j.id=sd.job_id AND YEAR(j.creation_date)=(YEAR(CURRENT_DATE)-1) GROUP BY j.id ORDER BY j.id";
    ResultSet rs = st.executeQuery(query);
    if (rs.next()) {
      do {
        String error = "";
        String jobId = rs.getString("id");
        String productId = rs.getString("product_id");
        String warehouseId = rs.getString("jwarehouse_id");
        String quantity = rs.getString("quantity");
        String shippingMethod = rs.getString("method");
        double jobPrice = Double.parseDouble(rs.getString("job price"));
        String shipFrom = "";
        String shipTo = "";
        String numberOfBoxes = "";
        String weight = "";
        String height = "";
        String length = "";
        String depth = "";
        String shippingCarrier = "";
        String shippingType = "";
        double shippingCost = 0;
        double svHandling = 0;
        double mcHandlingFull = 0;
        double mcHandlingCalc = 0;
        double shippingPriceFull = 0;
        double shippingPriceCalc = 0;

        String query1 = "SELECT cl.zip 'zipFrom',l.zip 'zipTo',pp.weight_per_box 'weight',pp.length,pp.width,pp.height,pp.number_of_boxes,pp.std_subvendor_hand 'svHandling',pp.std_vend_hand 'mcHandlingFull' FROM company_locations cl,locations l,product_prices pp WHERE cl.id=(SELECT location_id FROM warehouses WHERE id=(SELECT jwarehouse_id FROM jobs WHERE id=" + jobId + ")) and l.locationtypeid=1 and l.contactid=(SELECT jbuyer_contact_id FROM jobs WHERE id=" + jobId + ") and pp.quantity=(SELECT quantity FROM jobs WHERE id=" + jobId + ") AND pp.prod_price_code=(SELECT prod_price_code FROM products WHERE id=(SELECT product_id FROM jobs WHERE id=" + jobId + "))";
        ResultSet rs1 = st1.executeQuery(query1);
        if (rs1.next()) {
          shipFrom = rs1.getString("zipFrom");
          shipTo = rs1.getString("zipTo");
          weight = rs1.getString("weight");
          height = rs1.getString("height");
          length = rs1.getString("length");
          depth = rs1.getString("width");
          numberOfBoxes = rs1.getString("number_of_boxes");
          svHandling = Double.parseDouble(rs1.getString("svHandling"));
          mcHandlingFull = Double.parseDouble(rs1.getString("mcHandlingFull"));
        }
        rs1.close();

        if (shippingMethod.equals("") || shippingMethod.startsWith("U") || shippingMethod.startsWith("u")) {
          shippingCarrier = "UPS";
        } else if (shippingMethod.startsWith("F") || shippingMethod.startsWith("f")) {
          shippingCarrier = "FEDEX";
        } else {
          shippingCarrier = "UPS";
        }

        if (shippingMethod.contains("2")) {
          shippingType = "2DAY";
          if (shippingMethod.contains("AIR")) {
            shippingType = "2DAY AIR";
          }
        } else if (shippingMethod.contains("3")) {
          shippingType = "3DAY";
        } else if (shippingMethod.contains("NEXT")) {
          shippingType = "NEXT DAY";
          if (shippingMethod.contains("AIR")) {
            shippingType = "NEXT DAY AIR";
          }
        } else {
          shippingType = "GROUND";
        }

        shipper.setJobId(jobId);
        shipper.setShipper(shippingCarrier);
        shippingCost = shipper.calculateShippingCost();
        mcHandlingCalc = shipper.getHandlingCost(jobPrice, shippingCost) - svHandling;
        shippingPriceFull = shippingCost + svHandling + mcHandlingFull;
        shippingPriceCalc = shippingCost + svHandling + mcHandlingCalc;

        String sql1 = "SELECT id FROM proforma_shipping WHERE job_id=" + jobId;
        String sql2 = "";
        ResultSet rset1 = st2.executeQuery(sql1);
        if (rset1.next()) {
          sql2 = "UPDATE proforma_shipping SET product_id=" + productId + ",warehouse_id=" + warehouseId + ",quantity=" + quantity + ",ship_from_zip='" + shipFrom + "',ship_to_zip='" + shipTo + "'," +
                  "number_of_boxes=" + numberOfBoxes + ",weight=" + weight + ",height=" + height + ",length=" + length + ",depth=" + depth + "," +
                  "shipping_carrier='" + shippingCarrier + "',shipping_type='" + shippingType + "',shipping_cost=" + new DecimalFormat("#0.00").format(shippingCost) + ",subvendor_handling=" + new DecimalFormat("#0.00").format(svHandling) + "," +
                  "marcomet_handling_full=" + new DecimalFormat("#0.00").format(mcHandlingFull) + ",marcomet_handling_calculated=" + new DecimalFormat("#0.00").format(mcHandlingCalc) + ",shipping_price_full=" + new DecimalFormat("#0.00").format(shippingPriceFull) + ",shipping_price_calculated=" + new DecimalFormat("#0.00").format(shippingPriceCalc) +
                  " WHERE id=" + rset1.getString("id");
          countUpdate++;
        } else {
          sql2 = "INSERT INTO proforma_shipping (job_id,product_id,ship_from_zip,ship_to_zip,warehouse_id,quantity,number_of_boxes,weight,height,length,depth,shipping_carrier,shipping_type,shipping_cost,subvendor_handling,marcomet_handling_full,marcomet_handling_calculated,shipping_price_full,shipping_price_calculated)" +
                  " VALUES(" + jobId + "," + productId + ",'" + shipFrom + "','" + shipTo + "'," + warehouseId + "," + quantity + "," + numberOfBoxes + "," + weight + "," + height + "," + length + "," + depth + ",'" + shippingCarrier + "','" + shippingType + "'," + new DecimalFormat("#0.00").format(shippingCost) + "," + new DecimalFormat("#0.00").format(svHandling) + "," + new DecimalFormat("#0.00").format(mcHandlingFull) + "," + new DecimalFormat("#0.00").format(mcHandlingCalc) + "," + new DecimalFormat("#0.00").format(shippingPriceFull) + "," + new DecimalFormat("#0.00").format(shippingPriceCalc) + ")";
          countInsert++;
        }
        try {
          st3.executeUpdate(sql2);
        } catch (Exception e) {
    %>
    SQL Exception =&nbsp;<%= e.getMessage()%>
    <%
        }
        rset1.close();
      } while (rs.next());
      rs.close();
    }
    %>
    <script type="text/javascript">document.all["divWait"].style.display="none";</script>
    <p></p>
    No. of records inserted... <%= countInsert%>
    <p></p>
    No. of records updated... <%= countUpdate%>
  </body>
</html>
<%
    st.close();
    st1.close();
    st2.close();
    st3.close();
    conn.close();
%>