<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.environment.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<jsp:setProperty name="cB" property="*"/>  
<%
//if credit card processing isn't allowed on this site, show nothing

if(Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getCCommerce())>0){

String pastref=((request.getParameter("pastref")!=null)?request.getParameter("pastref"):"");

Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
%>
  <%= (request.getAttribute("errorMessage")==null)?"":"<div class='subtitle' style='color:red'>"+request.getAttribute("errorMessage")+"</div>"%><%= (session.getAttribute("errorMessage")==null) || session.getAttribute("errorMessage").toString().equals("")?"":"<div class='subtitle' style='color:red'>There was a problem processing this Credit Card Transaction: "+session.getAttribute("errorMessage")+"</div>"%><%
  %><script>
  			function chooseCardType(){

				var thisCardStr='';
				var thisCard='0';
				var ccNum=document.forms[0].ccNumber.value;
				if (ccNum.length<6){
					thisCard='';
					thisCardStr='&nbsp;';
				}else{
					if(ccNum.substr(0,1)=='4'){
						thisCard='1';
						thisCardStr='VISA';
					}else if(ccNum.substr(0,2)=='34' || ccNum.substr(0,2)=='37'){
						thisCard='3';
						thisCardStr='AMERICAN EXPRESS';
					}else if(ccNum.substr(0,2)>50 && ccNum.substr(0,2)<56){
						thisCard='2';
						thisCardStr='MASTERCARD';
					}else if(ccNum.substr(0,4)=='6011'){
						thisCard='4';
						thisCardStr='DISCOVER';
					}else if(ccNum.substr(0,2)=='36' || ccNum.substr(0,2)=='38' || (ccNum.substr(0,3)>299 && ccNum.substr(0,3)<306)){
						thisCard='5';
						thisCardStr='DINERS CLUB';
					}else{
						thisCard='';
						thisCardStr='INVALID CARD NUMBER or CARD TYPE NOT ACCEPTED';
					}
				}
				document.getElementById('ccType').innerHTML=thisCardStr;
				document.forms[0].ccType.value=thisCard;
			}
  </script>
        <input name="titleId" type="hidden" size="20" max="20" value="<%= cB.getTitleIdString() %>" ></input>
        <input name="firstName" type="hidden" size="20" max="20" value="<%= cB.getFirstName() %>" ></input>
        <input name="lastName" type="hidden" size="30" max="30" value="<%= cB.getLastName() %>" ></input>
		<input name="companyName" type="hidden" size="32" max="64" value="<%= cB.getCompanyName() %>"></input>
		<input type="hidden" name="jobTitle" size="20" max="20" value="<%= cB.getJobTitle() %>" ></input>
		<input type="hidden" name="email" value="<%= cB.getEmail() %>" /></input>
		<input type="hidden" name="companyURL" value="<%= cB.getCompanyURL() %>" /></input><%
		
			int commerce = Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getCCommerce());
			String hostAddress="";
			if (commerce == 0) {
				hostAddress="";
			} else if (commerce == 1) {
		        hostAddress="pilot-payflowpro.paypal.com";
			} else if (commerce == 2) {
		        hostAddress="payflowpro.paypal.com";
		    }
		%><input type="hidden" name="cch" value="<%= hostAddress %>">
        <input type="hidden" name="locationBillId" value="<%= cB.getLocationBillIdString()%>">
        <input type="hidden" name="locationBillTypeId" value="<%= cB.getLocationBillTypeIdString()%>">
        <input type="hidden" name="addressBill1" size=56 max=200 value="<%= cB.getAddressBill1() %>" onChange="formChangedArea('Locations')" >
        <input type="hidden" name="addressBill2" size=56 max=200 value="<%= cB.getAddressBill2() %>" onChange="formChangedArea('Locations')" >
        <input type="hidden" name="cityBill" value="<%= cB.getCityBill() %>" onChange="formChangedArea('Locations')">
        <input type="hidden" name="stateBillId" value="<%= cB.getStateBillId() %>" onChange="formChangedArea('Locations')">
        <input type="hidden" name="zipcodeBill" value="<%= cB.getZipcodeBill() %>" onChange="formChangedArea('Locations')">
        <input type="hidden" name="phoneCount" value="3">
        <input type="hidden" name="phoneTypeId0" size="3" value="<%= cB.getPhoneTypeIdString(0) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="areaCode0" size="3" value="<%= cB.getAreaCode(0) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="prefix0" size="4" value="<%= cB.getPrefix(0) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="lineNumber0" size="5" value="<%= cB.getLineNumber(0) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="extension0" size="4" value="<%= cB.getExtension(0) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="phoneTypeId1" size="3" value="<%= cB.getPhoneTypeIdString(1) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="areaCode1" size="3" value="<%= cB.getAreaCode(1) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="prefix1" size="4" value="<%= cB.getPrefix(1) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="lineNumber1" size="5" value="<%= cB.getLineNumber(1) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="extension1" size="4" value="<%= cB.getExtension(1) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="phoneTypeId2" size="3" value="<%= cB.getPhoneTypeIdString(2) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" size="3" name="areaCode2" value="<%= cB.getAreaCode(2) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="prefix2" size="4" value="<%= cB.getPrefix(2) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="lineNumber2" size="5" value="<%= cB.getLineNumber(2) %>" onChange="formChangedArea('Phones')">
        <input type="hidden" name="extension2" size="4" value="<%= cB.getExtension(2) %>" onChange="formChangedArea('Phones')">
<%
//If there are credit cards stored allow them to choose one

 ResultSet rsCards = st.executeQuery("select count(id) from cred_tx where to_days(date_expires)>to_days(now()) and acct_type<>'C' and acct_type<>'S' and contact_id="+session.getAttribute("contactId").toString()); 
System.out.println("contact id is "+session.getAttribute("contactId").toString());
int numGoodCards=0;
 if (rsCards.next()){
 	numGoodCards=((rsCards.getString(1)==null)?0:rsCards.getInt(1));
 }
 rsCards = st.executeQuery("select count(distinct concat(masked_num,',',exp_date) ) from cred_tx where to_days(date_expires)>to_days(now()) and acct_type<>'C' and acct_type<>'S' and contact_id="+session.getAttribute("contactId").toString());
 int numCards=0;
 if (rsCards.next()){
 	numCards=((rsCards.getString(1)==null)?0:rsCards.getInt(1));
 }
 
 
 rsCards = st.executeQuery("select id,concat(acct_type,': ',masked_num,' - Exp Date:',left(exp_date,2),'/',right(exp_date,2),if(to_days(date_expires)>to_days(now()),'',' ****EXPIRED*****')) as 'display',if(to_days(date_expires)>to_days(now()),lastref,'expired') as 'value' from cred_tx where acct_type<>'C' and acct_type<>'S' and contact_id="+session.getAttribute("contactId").toString()+" order by creation_date" );
 int cCount=0;
 String cardSelector="";
 String lastDisplay="";
 String lastValue="";
 String lastUsed="";
 while(rsCards.next()){
		 	if (rsCards.getString("id")!=null){
		 		if (cCount==0){
		%>
		  <script type="text/javascript">
		  	
			function selectCard(cardStr){
				if (cardStr=='expired'){
					alert("You've chosen an expired card. Please choose another or enter a new card.");
				}else if (cardStr=='NEW'){
					document.getElementById("ccForm").style.display='';
				}else{
					document.getElementById("ccForm").style.display='none';
				}
			}
			
		</script>
		 		<div class='subtitle'>Select credit card or choose 'Enter a New Credit Card' to enter and use a new card:</div><select name='pastref' onChange='selectCard(this.value)'>
		 		<option value='' <%=((pastref.equals(""))?"Selected":"")%>>--Select Credit Card--</option><%
		 			cCount++;
		 		}
		 		if(!lastDisplay.equals("") && !lastDisplay.equals(rsCards.getString("display"))){
		 			%>
		 			<option value='<%=lastValue%>' <%=((pastref.equals(lastValue) && !lastValue.equals(""))?"Selected":"")%> ><%=lastDisplay%></option><%
		 			lastUsed=lastDisplay;
		 		}
		 		lastDisplay=rsCards.getString("display");
		 		lastValue=rsCards.getString("value");
		 	}
 }
	if (cCount==0){
	%><input type="hidden" name="pastref" value="NEW"><%
	}
  	if(!lastDisplay.equals("") && !lastDisplay.equals(lastUsed)){
 		%><option value='<%=lastValue%>' <%=((pastref.equals(lastValue))?"Selected":"")%> ><%=lastDisplay%></option><%
 	}
 %><option value='NEW' <%=((pastref.equals("NEW"))?"Selected":"")%>>--Enter a new credit card--</option></select>
<div id="ccForm" style="display:none;">
  <table border=0 width=500> 
  <tr><td colspan=2><div class='subtitle'><u>Credit Card Information:</u></div><div class='label'><font color="#990000">(Note: charge will appear on your credit card statement as MarComet.com, Inc.)</font></div></td></tr>
     <tr> 
      <td class="label">Credit Card Number:</td>
      <td> 
        <input type="text" name="ccNumber" value="<%= (request.getParameter("ccNumber")==null)?"":request.getParameter("ccNumber")%>" size="19" onBlur='chooseCardType()' >
      </td>
    </tr>
    <tr> 
      <td class="label">Credit Card Type:</td><td class="subtitle"><span id="ccType"></span><input type="hidden" name="ccType" value="<%=((request.getParameter("ccType")!=null)? request.getParameter("ccType"):"")%>">
    </tr>

    <tr> 
      <td class="label">Credit Card Exp. Date:</td>
      <td> 
        <select name="ccMonth">
          <% String ccMonth = (request.getParameter("ccMonth")==null)?"":request.getParameter("ccMonth"); %>
          <option value="01" <%=(ccMonth.equals("01"))?"Selected":""%>>January</option>
          <option value="02" <%=(ccMonth.equals("02"))?"Selected":""%>>February</option>
          <option value="03" <%=(ccMonth.equals("03"))?"Selected":""%>>March</option>
          <option value="04" <%=(ccMonth.equals("04"))?"Selected":""%>>April</option>
          <option value="05" <%=(ccMonth.equals("05"))?"Selected":""%>>May</option>
          <option value="06" <%=(ccMonth.equals("06"))?"Selected":""%>>June</option>
          <option value="07" <%=(ccMonth.equals("07"))?"Selected":""%>>July</option>
          <option value="08" <%=(ccMonth.equals("08"))?"Selected":""%>>August</option>
          <option value="09" <%=(ccMonth.equals("09"))?"Selected":""%>>September</option>
          <option value="10" <%=(ccMonth.equals("10"))?"Selected":""%>>October</option>
          <option value="11" <%=(ccMonth.equals("11"))?"Selected":""%>>November</option>
          <option value="12" <%=(ccMonth.equals("12"))?"Selected":""%>>December</option>
        </select>
        <select name="ccYear">
          <% String ccYear = (request.getParameter("ccYear")==null)?"":request.getParameter("ccYear"); %>
          <option value="11" <%=(ccYear.equals("11"))?"Selected":""%>>2011</option>
          <option value="12" <%=(ccYear.equals("12"))?"Selected":""%>>2012</option>
          <option value="13" <%=(ccYear.equals("13"))?"Selected":""%>>2013</option>
          <option value="14" <%=(ccYear.equals("14"))?"Selected":""%>>2014</option>
          <option value="15" <%=(ccYear.equals("15"))?"Selected":""%>>2015</option>
          <option value="16" <%=(ccYear.equals("16"))?"Selected":""%>>2016</option>
		  <option value="17" <%=(ccYear.equals("17"))?"Selected":""%>>2017</option>
		  <option value="18" <%=(ccYear.equals("18"))?"Selected":""%>>2018</option>
		  <option value="19" <%=(ccYear.equals("19"))?"Selected":""%>>2019</option>
		  <option value="20" <%=(ccYear.equals("20"))?"Selected":""%>>2020</option>
		  <option value="21" <%=(ccYear.equals("21"))?"Selected":""%>>2021</option>
        </select>
      </td>
    </tr>
       <tr> 
      <td class="label">Card Verification Number:</td>
      <td> 
        <input type="text" name="ccvNumber" value="<%= (request.getParameter("ccvNumber")==null)?"":request.getParameter("ccvNumber")%>" size="5">(See below.)
      </td>
    </tr>
    <tr> 
      <td colspan="2"><br><br> <img src="/images/ccv.jpg">
      </td>
    </tr>
</table> 
</div>	
<% 
 if(numGoodCards==0 || (request.getParameter("pastref")!=null && request.getParameter("pastref").equals("New")) ) {
%><script>document.getElementById("ccForm").style.display="";</script><%}%>
<input type="hidden" name="statusId" value="2">
<input type="hidden" name="contactId" value="<%=session.getAttribute("contactId").toString()%>">
<input type="hidden" name="formChangedPhones" value="<%= (request.getParameter("formChangedPhones") == null )?"0":request.getParameter("formChangedPhones") %>">
<input type="hidden" name="formChangedLocations" value="<%= (request.getParameter("formChangedLocations") == null )?"0":request.getParameter("formChangedLocations") %>">
<input type="hidden" name="formChangedContact" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedContact") %>">
<input type="hidden" name="formChangedCompany" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedCompany") %>"><%

	session.setAttribute("errorMessage","");
	conn.close(); 
}else{
	%><%
}%>
