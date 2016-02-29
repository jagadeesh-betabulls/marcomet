<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="com.marcomet.catalog.*, com.marcomet.jdbc.*, java.sql.*, java.util.*;" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<html>
<head>
  <title>Job Details</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  <META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
  <META HTTP-EQUIV="Pragma" CONTENT="no-cache">
  <META HTTP-EQUIV="Expires" CONTENT="-1">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000" onLoad="MM_preloadImages('/images/buttons/okover.gif')">
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
	ShoppingCart cart = (ShoppingCart)session.getAttribute("shoppingCart");
  	if ( cart != null) {
    	JobObject jo = cart.getJob(Integer.parseInt((String)request.getParameter("jobId")));
     	if (jo != null) {
        	Hashtable jobSpecs = (Hashtable)jo.getJobSpecs();	
	
%><table width=100% class="body" cellpadding="0" cellspacing="0">
  <tr> 
      		
    <td class="minderheaderleft" colspan=2>Job Details for Job:<br><font size='+1'><%=jo.getJobName()%></font></td>
    	</tr>
<%  
			Vector jsTable = new Vector();
			double jobTotal = 0;
	 		Enumeration eKeys = jobSpecs.keys();
			StringBuffer sbQuery = new StringBuffer();
			if(eKeys.hasMoreElements()){
				sbQuery.append("SELECT id, value FROM lu_specs WHERE id = ");
				sbQuery.append((String)eKeys.nextElement());
	
				while(eKeys.hasMoreElements()){
					sbQuery.append(" OR id = ");
					sbQuery.append((String)eKeys.nextElement());
				}
			
				sbQuery.append(" ORDER BY sequence");
				ResultSet rsJS = st.executeQuery(sbQuery.toString());

				while(rsJS.next()){
					JobSpecObject jso = (JobSpecObject)jobSpecs.get(rsJS.getString("id"));				
					//for later table use.
					if(jso.getPrice() !=  0){                  //the way we test for non-determinate price specs
						jsTable.add("<tr><td class='lineitems'><div class='label'>"+rsJS.getString("value")+"</div></td><td class='lineitems'><div align='right'>"+formater.getCurrency(jso.getPrice())+"</div></td></tr>");
						jobTotal += jso.getPrice();
					}	
					if(rsJS.getInt("id") != 99999 && rsJS.getInt("id") != 88888){
						
%><tr> 
    <td class="lineitems" width='20%' valign="top"><div class='label'><%=rsJS.getString("value")%></div></td>
    <td class="lineitems" width='80%' valign="top"><div class='bodyBlack'><%=((rsJS.getString("value").equals("Quantity") && ((String)jso.getValue()).equals("0"))?"N/A":(String)jso.getValue())%></div></td>
  </tr><%										
					}
				}
			}
%>
<tr><td colspan="2">
<table width=100% class="body">
  <tr> 
    <td class="subtitle1" colspan="2">Job Price Details:</td>
  </tr>
  <tr> 
    <td class="planheader1"> 
      <div align="left">&nbsp;&nbsp;Item</div>
    </td>
    <td class="planheader1"><div align='right'>Price&nbsp;&nbsp;</div></td>
  </tr><%
			for(int i = 0; i < jsTable.size(); i++){
%><%= (String)jsTable.elementAt(i)%> <%
			}
%><tr> 
    <td align="right" class="label">Job Totals:</td>
    <td align="right" class="TopborderLable"><%= formater.getCurrency(jobTotal) %><font color="#FF0000"></font></td>
  </tr>
</table></td></tr></table><%

if (jo.getPreBuiltFileURL() != null && !(jo.getPreBuiltFileURL().equals(""))){%><a href="<%=jo.getPreBuiltPDFFileURL()%>" target="_blank"><img src="<%=jo.getPreBuiltFileURL()%>"></a><!-- <%=jo.getPreBuiltPDFFile()%> --><%}
		}
	}
%><p><div align="center"><a href="javascript:close()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image1','','/images/buttons/okover.gif',1)"><img name="Image1" border="0" src="/images/buttons/ok.gif" width="50" height="20"></a></div>
</body>
</html><%conn.close();%>
