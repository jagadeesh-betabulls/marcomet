<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st1 = conn.createStatement();
Statement st2 = conn.createStatement();
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
	//find all product lines with the current company/segment
	try{
		if(request.getParameter("newValue").equals("")){
		  query = "delete from io_status where io_number='"+request.getParameter("ioNumber")+"'";
		}else{
		  query = "insert into io_status (io_number, io_status) values ('"+request.getParameter("ioNumber")+"','"+request.getParameter("newValue")+"')";		
		}
		st.executeUpdate(query); 
		changed++;
		closeThis=true;
	}catch (Exception e){
		%><br><%=query%><br><%
	}
}else{
%><html>
<head>
  <title>Change Insertion Order Status</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action="/popups/QuickChangeIOStatus.jsp?submitted=true">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr>
    <td class="tableheader">Update Insertion Order Status</td>
  </tr>
  <tr>
      <td class="lineitemscenter"><% 
String sqlContactDD = "Select value as 'value',text as 'text' from lu_io_status order by sequence"; 
%><formtaglib:SQLDropDownTag dropDownName="newValue" sql="<%= sqlContactDD %>" selected="" extraCode="" />
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
<input type="hidden" name="ioNumber" value="<%=request.getParameter("ioNumber")%>">
<input type="hidden" name="$$Return" value="<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>">
</form>
</body>
</html><%}
	st.close();
	st1.close();
	st2.close();
	conn.close();

%><%=((closeThis)?"<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>":"")%>
