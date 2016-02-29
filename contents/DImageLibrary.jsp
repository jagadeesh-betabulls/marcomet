<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.jdbc.*;" %>
<%
String password=((request.getParameter("password")==null || request.getParameter("password").equals(""))?
((session.getAttribute("wam_pw")==null)?"": session.getAttribute("wam_pw").toString()):request.getParameter("password"));
String userName=((request.getParameter("username")==null || request.getParameter("username").equals(""))?
((session.getAttribute("wam_un")==null)?"": session.getAttribute("wam_un").toString()):request.getParameter("username"));

String loginId = (session.getAttribute("contactId")==null)?"0":(String)session.getAttribute("contactId"); 

String siteSelect="";
int x=1;
boolean login=false;

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();

if (password.equals("") || userName.equals("")){
	ResultSet rsU=st.executeQuery("Select am_login,am_password from contacts where id='"+loginId+"' and am_login is not null and am_password is not null and am_login<>'' and am_password<>''");
	if(rsU.next()){
		userName=rsU.getString("am_login");
		password=rsU.getString("am_password");
	
	}
}
if (password.equals("") || userName.equals("")){
	x=0;
	ResultSet rs=st.executeQuery("Select * from v_contact_properties where contact_id='"+loginId+"'");
	
	while (rs.next()){
		siteSelect+=((siteSelect.equals(""))?"<select name='siteSelect' onChange='un(this.value);pw(this.value)'><option value=''>- SELECT PROPERTY -</option>":"")+ "<option value='"+rs.getString("property_code")+"'>"+rs.getString("property_code")+"</option>";
		userName=rs.getString("property_code");
		x++;
	}
	siteSelect+="</select>";
}else{
	login=true;
}
%><head>
  <style type="text/css">

  .label {
  	text-align: right;
  	font-weight: bold;
  	font-size: 12px;
  	font-family: sans-serif;
  	color: black;
  }

  </style>
<link rel="stylesheet" href="<%=session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script>
	function pw(passwd){
		document.forms[0].password.value='sitenumber'+passwd;
	}
	function un(uname){
		document.forms[0].username.value=uname;
	}
	function fieldCheck(){
		var returnChk=true;
		if (document.forms[0].username.value=='' || 	document.forms[0].password.value==''){
			alert('Please fill in site number or username and password, p='+document.forms[0].password.value+', user='+document.forms[0].username.value);
			returnChk=false;
		}
		return returnChk
	}
</script>
</head><body topmargin="50" leftmargin="100" rightmargin="100"><%
if (x==0){
%>
<form method="post" action='' onsubmit="return fieldCheck()">
<input type=hidden name=url value="index.php">
<input type="hidden"  name="remember" id="remember" value="yes" >
<div class='title' >Access Digital Resources</div>
<table cellpadd1ng=3 cellspacing=0 border=0 align=center width='300'>
	<tr><td colspan=2><img src='/images/spacer.gif' height="10"></td></tr>
	<tr><td class='label'>Property Site Number</td><td class='lineitems'><input type="text" name="uEntry1" id="name1" value="<%=userName%>" onChange='un(this.value);pw(this.value)'></td></tr>
	<tr><td colspan=2><img src='/images/spacer.gif' height="10"></td></tr>
	<tr><td colspan=2><hr size=1></td></tr>
	<tr><td colspan=2>- OR -</td></tr>
	<tr><td colspan=2><hr size=1></td></tr>
	<tr><td colspan=2><img src='/images/spacer.gif' height="10"></td></tr>
	<tr><td class='label'>Login Name</td><td ><input type="text" name="uentry2" id="name2" value="<%=userName%>" onChange='un(this.value)'><input type="hidden" name="username" id="name"  ></td></tr>
	<tr><td class='label'>Password</td><td ><input type="password" name="password" id="pwname"  /></td></tr>
	<tr><td colspan=2><img src='/images/spacer.gif' height="10"></td></tr>
	<tr><td colspan=2 align='center'><br><br><input name="Submit" type="submit" value="&nbsp;&nbsp;ACCESS RESOURCES&nbsp;&nbsp;" /></td></tr>
</table>
</form><%

}else if (x==1){

%>
<form method="post" action='<%=((request.getParameter("dom")==null)?"http://wam.marcomet.com":"http://"+request.getParameter("dom"))%>/DigitalAssets/login.php' >
<input type="hidden" name="url" value="index.php">
<input type="hidden"  name="remember" id="remember" value="yes" >
<input type="hidden" name="username" id="name" value="<%=userName%>" >
<input type="hidden" name="password" id="name" value="<%=((password.equals(""))?"sitenumber"+userName:password)%>" />
</form>
<script>
document.forms[0].submit();
</script><%

session.setAttribute("wam_un",userName);
session.setAttribute("wam_pw",password);

} else {
//If more than on property was found associated with the user

%>
<form method="post" action='' onsubmit="return fieldCheck()">
<input type=hidden name=url value="index.php">
<input type="hidden"  name="remember" id="remember" value="yes" >

<div class='title' >Resources Login</div>
<table cellpadd1ng=3 cellspacing=0 border=0 align=center width=50%>
		<tr><td class='label'>Choose Property Site Number</td><td ><%=siteSelect%><input type="hidden" name="username" id="name" value="" /><input type="hidden" name="password" id="name" value="" /></td></tr>
	
		<tr><td colspan=2 align='center'><br><br><input name="Submit" type="submit" value="&nbsp;&nbsp;ACCESS RESOURCES&nbsp;&nbsp;" /></td></tr>
</table>
</form><%


}%></body>
</html><%st.close();conn.close();%>
