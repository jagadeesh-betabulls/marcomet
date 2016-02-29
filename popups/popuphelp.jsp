<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.jdbc.*,com.marcomet.tools.*,java.util.*,java.lang.*" %>
<!--Pass as parameters: projecttypeid, page-->
<%String Help__MMColParam = "1";
if (request.getParameter("name") !=null) {Help__MMColParam = (String)request.getParameter("name");}
String sql = "SELECT * FROM helpanderrors WHERE context = '" + Help__MMColParam + "'";
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet Help = st.executeQuery(sql);
String baseURL = javax.servlet.http.HttpUtils.getRequestURL(request).toString();
	int dblslashIndex = baseURL.lastIndexOf("//")+2;
	baseURL = dblslashIndex != -1 ? baseURL.substring(dblslashIndex, baseURL.length()) : "";
	int slashIndex = baseURL.indexOf("/");
	baseURL = slashIndex != -1 ? baseURL.substring(0, slashIndex) : "";
	String dynamicHost = "";
	java.util.StringTokenizer stk = new java.util.StringTokenizer(baseURL, ".");
	if (stk.hasMoreElements()) {
		dynamicHost = stk.nextToken();
	}
%><html>
<head>
<title>MarComet Help System</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<link rel="stylesheet" href="/<%=dynamicHost %>/styles/vendor_styles.css" type="text/css">
</head>
<body bgcolor="#FFFFFF" text="#000000" onLoad="MM_preloadImages('../imgs/buttons/cancelover.gif','../images/buttons/continueover.gif')">
<p class="maintitle">Help System </p><%
if (Help.next()){
	%><p class="maintitle"><%=(((Help.getString("helptitle"))==null || Help.wasNull())?"Help Not Found":Help.getString("helptitle"))%></p>
	<p class="subtitle"><%=(((Help.getString("helptext"))==null || Help.wasNull())?"No help is available as of yet for this feature.":Help.getString("helptext"))%></p>
	<p class="subtitle">&nbsp;</p><%
	}else{
	%><p class="maintitle">Help Not Found</p>
	<p class="subtitle">No help is available as of yet for this feature.</p>
	<p class="subtitle">&nbsp;</p><%
}%><table width=100%>
  <tr> 
    <td width="35%">&nbsp;</td>
    <td class="whitebutton" width="34%"><a href="javascript:window.close()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('ok','','../images/buttons/continueover.gif',1)" onMouseDown="MM_swapImage('ok','','../images/buttons/continuedown.gif',1)"><img name="ok" border="0" src="../images/buttons/continue.gif" width="74" height="20"></a> 
    </td>
    <td width="35%">&nbsp;</td>
  </tr>
</table>
<p class="subtitle"><font color="#FFFFFF"><%=request.getParameter("name")%></font></p>
</body>
</html><%
Help.close();st.close();conn.close();
%>

