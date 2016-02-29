<%@ page import="java.sql.*;"%>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.formatterTool" scope="page" />
<% double totInvoice =0;
   double totPaid = 0;
   double totEscrow = 0;
   double totJobSales = 0;
   double totShipping = 0;
   double totSalesTax = 0;
   Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
   Statement st = conn.createStatement();
   ResultSet invoiceRS = st.executeQuery("SELECT i.id 'invoicenumber', DATE_FORMAT(i.record_creation_timestamp,'%m/%d/%y') 'invoicedate', id.ar_invoice_amount 'invoiceamount', 'amountpaid',id.deposited 'inescrow', id.ar_purchase_amount 'purchaseamount', id.ar_shipping_amount 'shippingamount', id.ar_sales_tax 'salestaxamount' FROM ar_invoices i, ar_invoice_details id, jobs j WHERE j.id = id.jobid AND i.id = id.ar_invoiceid AND id.jobid = " + request.getParameter("jobId"));
   request.setAttribute("invoiceRS", invoiceRS);
   PreparedStatement collectionStatement = conn.prepareStatement("SELECT payment_amount 'paid' FROM ar_collection_details WHERE ar_invoiceid = ?");
   ResultSet collectionRS; %>
<table>
  <tr>
    <td class="tableheader">Invoice#</td>
    <td class="tableheader">Inv Date</td>
    <td class="tableheader">Inv Amount</td>
    <td class="tableheader">Amt Paid</td>
    <td class="tableheader">In Escrow</td>
    <td class="tableheader">Job Sales</td>
    <td class="tableheader">Shipping</td>
    <td class="tableheader">Sales Tax</td>
  </tr>
  <iterate:dbiterate name="invoiceRS" id="i"><%
  collectionStatement.clearParameters();
  collectionStatement.setInt(1, invoiceRS.getInt("invoicenumber"));								
  collectionRS = collectionStatement.executeQuery(); %>
  <tr>
    <td class="label" align="right"><$ invoicenumber $></td>
    <td class="body"><$ invoicedate $></td>
    <td class="body"align="right"><%=formatter.getCurrency(invoiceRS.getDouble("invoiceamount"))%></td>
    <td class="body"align="right"><%
      if (collectionRS.next()) {
         formatter.getCurrency(collectionRS.getDouble(1)));    
         totPaid += collectionRS.getDouble(1);
      } else {
         formatter.getCurrency(0));    
      } %>
    </td>
    <td class="body" align="right"><%=formatter.getCurrency(invoiceRS.getDouble("inescrow"))%></td>
    <td class="body" align="right"><%=formatter.getCurrency(invoiceRS.getDouble("purchaseamount"))%></td>
    <td class="body" align="right"><%=formatter.getCurrency(invoiceRS.getDouble("shippingamount"))%></td>
    <td class="body" align="right"><%=formatter.getCurrency(invoiceRS.getDouble("salestaxamount"))%></td>
  </tr><%
  totInvoice  += invoiceRS.getDouble("invoiceamount");
  totEscrow   += invoiceRS.getDouble("inescrow");
  totJobSales += invoiceRS.getDouble("purchaseamount");
  totShipping += invoiceRS.getDouble("shippingamount");
  totSalesTax += invoiceRS.getDouble("salestaxamount"); %>
  </iterate:dbiterate>
  <tr>
    <td class="label" colspan="2" align="right">Total Billed</td>
    <td class="Topborderlable" align="right"><%=formatter.getCurrency(totInvoice)%></td>
    <td class="Topborderlable" align="right"><%=formatter.getCurrency(totPaid)%></td>
    <td class="Topborderlable" align="right"><%=formatter.getCurrency(totEscrow)%></td>
    <td class="Topborderlable" align="right"><%=formatter.getCurrency(totJobSales)%></td>
    <td class="Topborderlable" align="right"><%=formatter.getCurrency(totShipping)%></td>
    <td class="Topborderlable" align="right"><%=formatter.getCurrency(totSalesTax)%></td>
  </tr>
</table>