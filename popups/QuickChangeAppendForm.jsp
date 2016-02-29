<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<html>
<head>
  <title><%= request.getParameter("question") %></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script>
	function trim(inputString) {
	   if (typeof inputString != "string") { return inputString; }
	   var retValue = inputString;
	   var ch = retValue.substring(0, 1);
	   while (ch == " ") {
	      retValue = retValue.substring(1, retValue.length);
	      ch = retValue.substring(0, 1);
	   }
	   ch = retValue.substring(retValue.length-1, retValue.length);
	   while (ch == " ") { 
	      retValue = retValue.substring(0, retValue.length-1);
	      ch = retValue.substring(retValue.length-1, retValue.length);
	   }
	   while (retValue.indexOf("  ") != -1) { 
	      retValue = retValue.substring(0, retValue.indexOf("  ")) + retValue.substring(retValue.indexOf("  ")+1, retValue.length);
	   }
	   return retValue; 
	}
	function submitForm(){
		var valStr = document.forms[0].editValue.value
		var mystr=valStr.split("'").join("&apos;").split("\n").join("<br>");
		newValStr1=document.forms[0].newValue.value
		newValStr=newValStr1.split("'").join("&apos;").split("\n").join("<br>")
		if (trim(mystr)==""){
			alert("There is no new note to save.");
		}else{
	 			var today=new Date();
				var todayStr=today.getMonth()+1+"/"+today.getDate()+"/"+(today.getYear())
				document.forms[0].newValue.value="<div class=notes id=vendorNotes_"+todayStr+">"+todayStr+": "+mystr+"</div><br />"+newValStr
				document.forms[0].submit();
		}
	}
</script>
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body>
	<%=((request.getParameter("update")!=null && request.getParameter("update").equals("n"))?"Note: Minder display will update the next time you refresh the window.":"")%>
<form method="post" action="/servlet/com.marcomet.tools.QuickColumnUpdaterServlet">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr><td class="tableheader"><%= request.getParameter("question") %></td></tr>
  <tr><td class="lineitems" align="center">
      <textarea name="editValue" cols="<%=request.getParameter("cols")%>" rows="<%=request.getParameter("rows")%>"><%
String fieldVal="";
      Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
      Statement st = conn.createStatement();
java.sql.ResultSet rs = st.executeQuery("SELECT " + request.getParameter("columnName") + " FROM "+request.getParameter("tableName")+" j WHERE j.id = " + request.getParameter("primaryKeyValue"));
      if (rs.next()) { 
		fieldVal=((rs.getString(1)==null)?"":rs.getString(1));
	}%></textarea></td></tr><tr><td align="center"><input type="button" value="Update" onClick="submitForm()">&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="Cancel" onClick="self.close()"></td></tr><tr><td><%=((fieldVal.equals(""))?"":"<div class='subtitle'>Previous Notes:</div>"+fieldVal)%></td></tr>
</table>
<input type="hidden" name="tableName" value="<%=request.getParameter("tableName")%>">
<input type="hidden" name="newValue" value="<%=fieldVal%>">
<input type="hidden" name="columnName" value="<%=request.getParameter("columnName")%>">
<input type="hidden" name="valueType" value="<%=request.getParameter("valueType")%>">
<input type="hidden" name="primaryKeyValue" value="<%=request.getParameter("primaryKeyValue")%>">
<input type="hidden" name="tableName" value="<%=request.getParameter("tableName")%>">
<input type="hidden" name="$$Return" value="<script><%=((request.getParameter("update")!=null && request.getParameter("update").equals("n"))?"":"parent.window.opener.location.reload();")%>setTimeout('close()',500);</script>">
</form>
</body>
</html><%st.close();conn.close();%>