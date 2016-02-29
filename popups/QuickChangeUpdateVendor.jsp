<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
String query="";
String query1="";
String rootProdCode="";
String variantCode="";
String release="";

int changed=0;
int x=1;
int y=1;
boolean closeThis=false;

if (request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true")){

//Change the post date on the job	
	query = "update jobs j left join vendors v on v.id="+request.getParameter("newValue")+" set j.dropship_vendor="+request.getParameter("newValue")+",j.jwarehouse_id=if(v.default_warehouse_id is null,'66',v.default_warehouse_id) where j.id= "+request.getParameter("jobId");	
	st.executeUpdate(query); 

//If the PO transaction hasn't been posted yet change the vendor on the record
	query = "update jobs j,po_transactions p set p.vendor_id="+request.getParameter("newValue")+" where j.id="+request.getParameter("jobId")+" AND p.job_id=j.id and (p.accrued_date='0000-00-00' or p.accrued_date is null)";
	st.executeUpdate(query); 
	
	changed++;
	closeThis=true;

}else{

%><html>
<head>
  <title>Update Vendor</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action="/popups/QuickChangeUpdateVendor.jsp?submitted=true">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr>
    <td class="tableheader">Change Subvendor on Job/PO Records</td>
  </tr>
  <tr>
      <td class="lineitemscenter"><% 
      
String sqlVendors = "SELECT v.id 'value', company_name 'text' FROM vendors v, companies co WHERE v.active_vnd_flag=1 and v.company_id=co.id GROUP BY v.id ORDER BY company_name";

%><formtaglib:SQLDropDownTag dropDownName="newValue" sql="<%= sqlVendors %>" selected="<%=request.getParameter("vid")%>" extraCode="" />
      </td>
  </tr>
  <tr>
  	<td align="center">
  	<input type="button" value="Update" onClick="submit()">
	&nbsp;&nbsp;&nbsp;&nbsp;
	<input type="button" value="Cancel" onClick="self.close()">
	</td>
  </tr>
</table>
<input type="hidden" name="vid" value="<%=request.getParameter("vid")%>">
<input type="hidden" name="jobId" value="<%=request.getParameter("jobId")%>">
<input type="hidden" name="$$Return" value="<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>">
</form>
</body>
</html><%}
	st.close();
	conn.close();
%><%=((closeThis)?"<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>":"")%>
