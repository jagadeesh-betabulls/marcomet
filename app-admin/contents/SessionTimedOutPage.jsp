<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%
	if(1==2){
		Cookie[] cookies = request.getCookies();
		
		//relog the user in if he/she was logged in.
		if(cookies != null){
			for(int i = 0; i < cookies.length; i++){
				if(cookies[i].getName().equals("contactId")){
//					session.setAttribute("Login",cookies[i].getValue());
				
					String sql = "select concat(firstname,\" \", lastname), email, companyid from contacts where id=" + cookies[i].getValue();
					//com.marcomet.jdbc.SimpleConnection sc = new com.marcomet.jdbc.SimpleConnection();
					java.sql.Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
					java.sql.Statement qs = conn.createStatement();
				
					java.sql.ResultSet rs1 = qs.executeQuery(sql);
//					if(rs1.next()){
	//					session.setAttribute("UserFullName",rs1.getString(1));
		//				session.setAttribute("email",rs1.getString(2));
			//			session.setAttribute("companyid",rs1.getString(3));															
				//	}
					qs.close();
					conn.close();
					qs = null;
					conn = null;
				}	
			}	
		}
	}
%>

<html>
<head>
<title>Warning: Your Session Timed Out</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="" src="/javascripts/mainlib.js"></script>
<body class="body" onLoad="MM_preloadImages('/images/buttons/continueover.gif')">
<form>
<div class="contentstitle">
    <p align="center">&nbsp;</p>
    <p align="center" class="catalogTITLE"><font size="4" face="Arial, Helvetica, sans-serif"><b><font color="#660000">SESSION 
      TIMED OUT</font></b></font></p>
    <p align="center" class="catalogITEM"><font face="Arial, Helvetica, sans-serif" size="3"><b><font color="#003366">Your 
      Data Session has timed out, you will be brought back to the home page. </font></b></font></p>
    <p class="catalogITEM" align="center"><font color="#003366"><b><font face="Arial, Helvetica, sans-serif" size="3">Any 
      task you have not completed might have to be started over.</font></b></font></p>
    
    <p class="catalogITEM">&nbsp;</p>
  <p></div>
<table border="0" align="center">
  <tr>
      <td><input type="button" name="Button" value="Home" onClick="javascript:parent.window.parent.window.parent.window.location.replace('/index.jsp')">
      </td>
  </tr>
</table>
</form>
</body>
</html>
