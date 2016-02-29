<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
String tableName=((request.getParameter("tableName")==null || request.getParameter("tableName").equals(""))?"jobs":request.getParameter("tableName"));
String newValue=request.getParameter("newValue");
String parentDiv=((request.getParameter("parentDiv")==null || request.getParameter("parentDiv").equals(""))?"":request.getParameter("parentDiv"));
boolean useDiv=((parentDiv.equals(""))?false:true);

String submitAction=((useDiv)?"opener.document.getElementById('"+parentDiv+"').innerHTML=document.getElementById('show_d_newValue').innerHTML;":((request.getParameter("refreshOpener")!=null && request.getParameter("refreshOpener").equals("false"))?"":"parent.window.opener.location.reload();"));

%><html>
<head>
  <title><%= request.getParameter("question") %></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action="/servlet/com.marcomet.tools.QuickColumnUpdaterServlet">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr><td class="tableheader"><%= request.getParameter("question") %></td></tr>
  <tr><td class="lineitems" align="center"><%
  String dateVal="today";
  if(newValue==null){
      java.sql.ResultSet rs = st.executeQuery("SELECT DATE_FORMAT(" + request.getParameter("columnName") + ",'%Y-%m-%d') FROM "+request.getParameter("tableName")+" j WHERE j.id = " + request.getParameter("primaryKeyValue"));
      if (rs.next()) { 
      		dateVal=rs.getString(1);
      } 
  }
      %><jsp:include page="/includes/DatePicker.jsp" >
      <jsp:param name="fieldName" value="newValue" />
	<jsp:param name="class" value="<%="textBox"%>" />
	<jsp:param name="defaultDate" value="<%=dateVal%>" />
		<jsp:param name="defaultDate" value="<%=dateVal%>" />
</jsp:include>
      </td></tr>
<tr><td align="center"><input type="button" value="Update" onClick="<%=submitAction%>;document.forms[0].submit()"  >&nbsp;&nbsp;<%if(request.getParameter("tableName").equals("products")){%><input type="button" value="Change Across Tiers" onClick='document.forms(0).action="QuickChangeAcrossBrandsForm.jsp?noPL=false&submitted=true";document.forms(0).submit();'>&nbsp;&nbsp;<%}%>&nbsp;&nbsp;<input type="button" value="Cancel" onClick="self.close()">&nbsp;&nbsp;<%if(request.getParameter("tableName").equals("products")){%><br><br><input type="button" value="Change Across Brands AND Tiers" onClick='document.forms(0).action="QuickChangeAcrossBrandsForm.jsp?noPL=true&noCID=true&submitted=true";document.forms(0).submit();'><%}%></td></tr>
</table>
<input type="hidden" name="columnName" value="<%=request.getParameter("columnName")%>">
<input type="hidden" name="valueType" value="<%=request.getParameter("valueType")%>">
<input type="hidden" name="primaryKeyValue" value="<%=request.getParameter("primaryKeyValue")%>">
<input type="hidden" name="tableName" value="<%=request.getParameter("tableName")%>">
<input type="hidden" name="$$Return" value="<script>setTimeout('close()',500);</script>">
<%=((request.getParameter("autosubmit")!=null && request.getParameter("autosubmit").equals("true"))?"<script>document.forms[0].submit()</script>":"")%>
</form></body>
</html><%st.close();conn.close();%>