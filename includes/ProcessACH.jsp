<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.environment.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
  <%= (request.getAttribute("errorMessage")==null)?"":"<div class='subtitle' style='color:red'>There was a problem processing this Credit Card Transaction: "+request.getAttribute("errorMessage")+"</div>"%><%= (session.getAttribute("errorMessage")==null) || session.getAttribute("errorMessage").toString().equals("")?"":"<div class='subtitle' style='color:red'>"+session.getAttribute("errorMessage")+"</div>"%><%

Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
%> <%= (request.getAttribute("errorMessage")==null)?"":"<div class='subtitle' style='color:red'>"+request.getAttribute("errorMessage")+"</div>"%><%= (session.getAttribute("errorMessage")==null) || session.getAttribute("errorMessage").toString().equals("")?"":"<div class='subtitle' style='color:red'>There was a problem processing this Credit Card Transaction: "+session.getAttribute("errorMessage")+"</div>"%><%

  //If there are accounts stored allow them to choose one
String pastACref=((request.getParameter("pastACref")!=null)?request.getParameter("pastACref"):"");
 ResultSet rsCards = st.executeQuery("select count(id) from cred_tx where (acct_type='C' or acct_type='S') and contact_id="+session.getAttribute("contactId").toString());
 int numGoodCards=0;
 if (rsCards.next()){
 	numGoodCards=((rsCards.getString(1)==null)?0:rsCards.getInt(1));
 }
 rsCards = st.executeQuery("select count(distinct masked_num) from cred_tx where (acct_type='C' or acct_type='S') and contact_id="+session.getAttribute("contactId").toString());
 int numCards=0;
 if (rsCards.next()){
 	numCards=((rsCards.getString(1)==null)?0:rsCards.getInt(1));
 }
 
 rsCards = st.executeQuery("select id,concat(if(acct_type='C','Checking Account: ','Savings Account: '),': ',masked_num) as 'display', lastref as 'value' from cred_tx where (acct_type='C' or acct_type='S') and contact_id="+session.getAttribute("contactId").toString()+" order by creation_date" );
 int cCount=0;
 String cardSelector="";
 String lastDisplay="";
 String lastValue="";
 String lastUsed="";
 while(rsCards.next() && 1==2){
		 	if (rsCards.getString("id")!=null){
		 		if (cCount==0){
		%>
		  <script type="text/javascript">
		  	
			function selectACH(cardStr){
				if (cardStr=='NEW'){
					document.getElementById("achForm").style.display='';
				} else {
					document.getElementById("achForm").style.display='none';
				}
			}
		</script>
		 		<div class='subtitle'>Select Bank Account or choose 'Enter a New Bank Account' to enter and use a new account:</div><select name='pastACref' onChange='selectACH(this.value)'>
		 		<option value='' <%=((pastACref.equals(""))?"Selected":"")%>>--Select Bank Account--</option><%
		 			cCount++;
		 		}
		 		if(!lastDisplay.equals("") && !lastDisplay.equals(rsCards.getString("display"))){
		 			%>
		 			<option value='<%=lastValue%>' <%=((pastACref.equals(lastValue) && !lastValue.equals(""))?"Selected":"")%> ><%=lastDisplay%></option><%
		 			lastUsed=lastDisplay;
		 		}
		 		lastDisplay=rsCards.getString("display");
		 		lastValue=rsCards.getString("value");
		 	}
 }

  	if(!lastDisplay.equals("") && !lastDisplay.equals(lastUsed)){
 		%><option value='<%=lastValue%>' <%=((pastACref.equals(lastValue))?"Selected":"")%> ><%=lastDisplay%></option><%
 	}
 %><option value='NEW' <%=((pastACref.equals("NEW"))?"Selected":"")%>>--Enter a new bank account--</option></select>
<div id="achForm" style="display:none;">
 <table border=0 width=500> 
  <tr><td colspan=2><div class='subtitle'><u>Bank Account Information:</u></div><div class='label'><font color="#990000">(Note: charge will appear on your bank account statement as MarComet.com, Inc.)</font></div></td></tr>
    <tr> 
      	<td width="30%" class="label">Account Type</td>  
		<td width='70%'><input type="radio" name="acct_type" value="C" checked> Checking&nbsp;&nbsp;&nbsp;<input type="radio" name="acct_type" value="S"> Savings </td>
    </tr>
    <tr> 
      <td class="label">Name on Account:</td>
      <td> <input type="text" name="accountName" value="<%= (request.getParameter("accountName")==null)?"":request.getParameter("accountName")%>" size="40"></td>
    </tr>
    <tr> 
      <td class="label">Bank Name</td>
      <td> <input type="text" name="bankName" value="<%= (request.getParameter("bankName")==null)?"":request.getParameter("bankName")%>" size="40"></td>
    </tr>
        <tr> 
      <td class="label">Account Number</td>
      <td> <input type="text" name="accountNumber" value="<%= (request.getParameter("accountNumber")==null)?"":request.getParameter("accountNumber")%>" size="40"></td>
    </tr>
        <tr> 
      <td class="label">Bank Routing #</td>
      <td> <input type="text" name="routingNumber" value="<%= (request.getParameter("routingNumber")==null)?"":request.getParameter("routingNumber")%>" size="40"></td>
    </tr>
    <tr> 
      <td class="label">Bank City</td>
      <td> <input type="text" name="bankCity" value="<%= (request.getParameter("bankCity")==null)?"":request.getParameter("bankCity")%>" size="40"></td>
    </tr>
        <tr> 
      <td class="label">Bank State</td>
      <td><input type="text" name="bankState" value="<%= (request.getParameter("bankState")==null)?"":request.getParameter("bankState")%>" size="40"></td>
    </tr>
    <tr> 
      <td colspan="2"> <img src='/images/ach.jpg'>
        <hr>
      </td>
    </tr>
</table>  
</div><% 
 	if (cCount==0){
	%><input type="hidden" name="pastACref" value="NEW"><%
	}
 if(cCount==0 || numGoodCards==0 || (request.getParameter("pastACref")!=null && request.getParameter("pastACref").equals("New")) ) {
%><script>document.getElementById("achForm").style.display="";</script><%}%>
<%
	session.setAttribute("errorMessage","");
	conn.close(); 
%>