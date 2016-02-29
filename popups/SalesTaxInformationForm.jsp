<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.workflow.*,com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<%
String jobId = request.getParameter("jobId");
String query = "select st.value entitystring,entity, rate, tax_shipping, tax_job, buyer_exempt from sales_tax,lu_abreviated_states st where st.id=sales_tax.entity and job_id = " + jobId;

String taxEntity="";
String taxRate="0";
String taxShipping="0";
String taxJob="0";
String buyerExempt="0";


Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);
if(rs.next()){
  taxEntity=rs.getString("entity");
  taxRate=rs.getString("rate");
  taxShipping=rs.getString("tax_shipping");
  taxJob=rs.getString("tax_job");
  buyerExempt=rs.getString("buyer_exempt");
}

%>
<html>
<head>
<title>Sales Tax Information</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>

<body bgcolor="#FFFFFF" text="#000000">
<form method="post" action="/servlet/com.marcomet.tools.UpdateSalesTaxInfoServlet">
  <table class="body" style="border-style: solid; border-width: 1px;">
    <tr>
      <td><b>Sales Tax:</b></td>
    <td colspan="2" class="tableheader">Tax Entity</td>
      <td class="tableheader" width="63">Tax Rate</td>
      <td class="tableheader" width="101">Tax Shipping</td>
      <td class="tableheader" width="76">Tax Job</td>
      <td class="tableheader" width="93">Buyer Exempt</td>
  </tr>
  <tr>
      <td >&nbsp;</td>
	<td align="right" colspan="2">
		<taglib:LUDropDownTag dropDownName="taxEntity" table="lu_abreviated_states" selected="<%=taxEntity%>" />
	</td>
	  <td align="right" width="63"> 
        <input type="text" style="text-align:right;" name="taxRate" size="4" value="<%=taxRate%>" ></td>
	  <td align="right" width="101"> 
        <select name="taxShipping">
	    <option value="1" <%=((taxShipping.equals("1"))?"selected":"")%> >Yes</option>
		<option value="0" <%=((taxShipping.equals("0"))?"selected":"")%> >No</option>
      </select>
	 </td>
	  <td align="right" width="76"> 
        <select name="taxJob">
	    <option value="1" <%=((taxJob.equals("1"))?"selected":"")%> >Yes</option>
		<option value="0" <%=((taxJob.equals("0"))?"selected":"")%> >No</option>
      </select>
	 </td>
	  <td align="right" width="93"> 
        <select name="buyerExempt">
	    <option value="1" <%=((buyerExempt.equals("1"))?"selected":"")%> >Yes</option>
		<option value="0" <%=((buyerExempt.equals("0"))?"selected":"")%> >No</option>
      </select>
	 </td>
  </tr>
</table><br>
  	<div align="center">
  		<input type="button" value="Update" onClick="submit()">
	&nbsp;&nbsp;&nbsp;
		<input type="button" value="Cancel" onClick="self.close()">
	</div>	

<input type="hidden" name="jobId" value="<%= request.getParameter("jobId")%>">
<input type="hidden" name="$$Return" value="<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>">
</form>
</body>
</html>
<%
st.close();
rs.close();
conn.close();
%>