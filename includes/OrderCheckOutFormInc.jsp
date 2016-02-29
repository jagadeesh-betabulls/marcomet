<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*,com.marcomet.environment.*,java.util.*,com.marcomet.catalog.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />

<jsp:setProperty name="cB" property="*"/>  
<%
String siteHostId=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId();
boolean reuseAddresses=((sl.getValue("site_hosts","id",siteHostId,"reuse_addresses_flag").equals("1"))?true:false);
	String shippingLocationId=((request.getParameter("shippingLocationId")==null)?"0":request.getParameter("shippingLocationId"));
	Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
	Statement st = conn.createStatement();
	String addressMail1="";
	String addressMail2="";
	String cityMail="";
	String stateMailId="";
	String zipcodeMail="";
	String countryMailId="";
	String shipToName="";
	String storeShipLocation="";
	int numShipLocations=0;
	
    String locSQL = "select *,if(s.ship_to_name is null or s.ship_to_name='',c.company_name,s.ship_to_name) as 'shipToName' from shipping_locations s left join companies c on s.companyid=c.id where s.id='"+shippingLocationId+"'";

    ResultSet locRS = st.executeQuery(locSQL);
    if (locRS.next()) {
		 addressMail1=locRS.getString("address1");
		 addressMail2=locRS.getString("address2");
		 cityMail=locRS.getString("city");
		 stateMailId=locRS.getString("state");
		 zipcodeMail=locRS.getString("zip");
		 countryMailId=locRS.getString("country_id");
		 shipToName=locRS.getString("shipToName");
    }

    locSQL = "select shipping_locations.id,concat(location_title,': ',if(ship_to_name is null or ship_to_name='',c.company_name,ship_to_name),', ',address1,', ',address2,if(address2='','',', '),city,', ',st.value,', ',zip) as 'addressStr' from shipping_locations left join companies c on shipping_locations.companyid=c.id left join lu_abreviated_states st on st.id=state  where contactid='"+session.getAttribute("contactId").toString()+"' and reuse_address=1 and active_flag=1";

    locRS = st.executeQuery(locSQL);
    String shipLocations="<select name='shipLocationIdChoice' onChange='processShipLocation(this.value)'>";
    while (locRS.next()) {
		shipLocations+="<option value='"+locRS.getString("id")+"' "+((locRS.getString("id").equals(shippingLocationId))?"selected":"")+" >"+locRS.getString("addressStr")+"</option>";
		numShipLocations=numShipLocations+1;
    }
	//shipLocations+="<option value='0'>Enter New Shipping Address</option></select>";
	shipLocations+="</select>";

//if is null, first time here, or is "" due to return from login.
    if (request.getParameter("firstName") == null || request.getParameter("firstName").trim().equals("")) {
      cB.setContactId((String) session.getAttribute("contactId"));
    }

		%><script language="JavaScript">
	    	function submitLogin(){
	    	  document.forms[0].action ="/servlet/com.marcomet.users.security.LoginUserServlet";
	    	  document.forms[0].$$Return.value= "[/catalog/checkout/OrderCheckOutForm.jsp]";
	    	  document.forms[0].submit();
	    	}
	    	
	    	function processShipLocation(locId){
	    		if(locId=='0'){
	    			document.getElementById('chooseShip').style.display='none';
	    			document.getElementById('editShip').style.display='';
	    			document.forms[0].changeShipAddress.value='true';
	    		}else{
	    	  		document.forms[0].action ="";
	    	  		document.forms[0].submit();
	    		}
	    	}
	    	
 		 </script>
        
        <input type="hidden" name="formChangedPhones" value="<%= (request.getParameter("formChangedPhones") == null) ? "0" : request.getParameter("formChangedPhones")%>">
        <input type="hidden" name="formChangedLocations" value="<%= (request.getParameter("formChangedLocations") == null) ? "0" : request.getParameter("formChangedLocations")%>">
        <input type="hidden" name="formChangedContact" value="<%= (request.getParameter("formChangedCompany") == null) ? "0" : request.getParameter("formChangedContact")%>">
        <input type="hidden" name="formChangedCompany" value="<%= (request.getParameter("formChangedCompany") == null) ? "0" : request.getParameter("formChangedCompany")%>"><%

   		if (session.getAttribute("contactId") == null) {%>
          <table align="center" width="80%" class=label>
          <tr>
            <td colspan="4">
              I'm a returning Registered User
            </td>
          </tr>
          <tr>
            <td colspan="4" height="32">
              <input type="text" name="userName" value="">
              <input type="password" name="password" value="">
              <a href="javascript:submitLogin()" class="menuLINK" >Login</a> --or
            Complete the Information Below-- </td>
          </tr>
          </table><% 
          }
          
       %><table align="center" width="80%" class=label>
          <tr>
            <td colspan="4" height="31"> <span class="catalogTITLE">Order will be shipped/billed to the following.</span><font color="red"><span class="catalogTITLE">
            </span><%= (request.getAttribute("errorMessage") == null) ? "" : (String) request.getAttribute("errorMessage")%></font></td>
          </tr>
          <tr>
            <td colspan="4" class="subtitle1">Contact Information</td>
            <tr>
            </tr>
            <tr>
            <td height="22" colspan="4">
              <input type='hidden' value="<%= cB.getTitleIdString()%>" name="titleId"><%= sl.getValue("lu_titles", "id", cB.getTitleIdString(), "value")%> <input name="firstName" type="hidden" size="20" max="20" value="<%= cB.getFirstName()%>" onChange="formChangedArea('Contact')"><%= cB.getFirstName()%>
              <input name="lastName" type="hidden" size="30" max="30" value="<%= cB.getLastName()%>" onChange="formChangedArea('Contact')"><%= cB.getLastName()%>
            </td>
          </tr>
          <tr>
            <td colspan="4">Company: <input name="companyName" type="hidden" size="32" max="64" value="<%= cB.getCompanyName()%>" onChange="formChangedArea('Company')"><%= cB.getCompanyName()%></td>
          </tr>
          <tr>
            <td colspan="4">Franchise&nbsp;Site&nbsp;#:&nbsp;<input name="siteNumber" type="hidden" size="10" max="64" value="<%= cB.getSiteNumber()%>" onChange="formChangedArea('Contact')"><%= cB.getSiteNumber()%></td>
          </tr><%if (!cB.getPMSiteNumber().equals("")){%>
          <tr>
            <td colspan="4">Property Management Site #:&nbsp;<input name="pmSiteNumber" type="hidden" size="10" max="64" value="<%= cB.getPMSiteNumber()%>" onChange="formChangedArea('Contact')"><%= cB.getPMSiteNumber()%></td>
          </tr><%}%>
          <tr>
            <td colspan="4">Job Title:<input type="hidden" name="jobTitle" size="20" max="20" value="<%= cB.getJobTitle()%>" onChange="formChangedArea('Contact')"><%= cB.getJobTitle()%></td>
          </tr>
          <tr>

            <td colspan="4">E-mail:&nbsp;<input type="hidden" name="email" value="<%= cB.getEmail()%>" onChange="formChangedArea('Contact')"><%= cB.getEmail()%></td>
          </tr>
          <tr>
            <td colspan="4">Website:<input type="hidden" name="companyURL" value="<%= cB.getCompanyURL()%>" onChange="formChangedArea('Company')"><%= cB.getCompanyURL()%></td>
          </tr>
          <tr>
            <td colspan="4">Phone:<input type="hidden" name="phoneCount" value="3">
              <input type="hidden" value="<%=cB.getPhoneTypeIdString(0)%>" name="phoneTypeId0"><%= sl.getValue("lu_phone_types", "id", cB.getPhoneTypeIdString(0), "value")%>:
              <input type="hidden" name="areaCode0" size="3" value="<%= cB.getAreaCode(0)%>" onChange="formChangedArea('Phones')"><%= cB.getAreaCode(0)%>-<%= cB.getPrefix(0)%>-<%= cB.getLineNumber(0)%><%= ((cB.getExtension(0).equals("")) ? "" : " ext: " + cB.getExtension(0))%>
              <input type="hidden" name="prefix0" size="4" value="<%= cB.getPrefix(0)%>" onChange="formChangedArea('Phones')">
              <input type="hidden" name="lineNumber0" size="5" value="<%= cB.getLineNumber(0)%>" onChange="formChangedArea('Phones')">
              ext:
              <input type="hidden" name="extension0" size="4" value="<%= cB.getExtension(0)%>" onChange="formChangedArea('Phones')">
              <br>
              <input type="hidden" value="<%=cB.getPhoneTypeIdString(1)%>" name="phoneTypeId1"><%= sl.getValue("lu_phone_types", "id", cB.getPhoneTypeIdString(1), "value")%>:
              <input type="hidden" name="areaCode1" size="3" value="<%= cB.getAreaCode(1)%>" onChange="formChangedArea('Phones')"><%= cB.getAreaCode(1)%>-<%= cB.getPrefix(1)%>-<%= cB.getLineNumber(1)%><%= ((cB.getExtension(1).equals("")) ? "" : " ext: " + cB.getExtension(1))%>
              <input type="hidden" name="prefix1" size="4" value="<%= cB.getPrefix(1)%>" >
              <input type="hidden" name="lineNumber1" size="5" value="<%= cB.getLineNumber(1)%>" >
              ext:
              <input type="hidden" name="extension1" size="4" value="<%= cB.getExtension(1)%>" >
              <br>
              <input type="hidden" value="<%=cB.getPhoneTypeIdString(2)%>" name="phoneTypeId2"><%= sl.getValue("lu_phone_types", "id", cB.getPhoneTypeIdString(2), "value")%>
              <input type="hidden" size="3" name="areaCode2" value="<%= cB.getAreaCode(2)%>" ><%= cB.getAreaCode(2)%>-<%= cB.getPrefix(2)%>-<%= cB.getLineNumber(2)%><%= ((cB.getExtension(2).equals("")) ? "" : " ext: " + cB.getExtension(2))%>
              <input type="hidden" name="prefix2" size="4" value="<%= cB.getPrefix(2)%>" >
              <input type="hidden" name="lineNumber2" size="5" value="<%= cB.getLineNumber(2)%>">
              <input type="hidden" name="extension2" size="4" value="<%= cB.getExtension(2)%>" >
              <br>
            </td>
          </tr>

          <tr><td colspan="2" style="border:1px white solid;padding:5px;"> 
          <div class="subtitle1">Billing Address:</div>
            <div class="subtitle"><input type="hidden" value="<%= ((cB.getSameAsAbove()) ? "true" : "")%>" name="sameAsAbove"  >
              <input type="hidden" name="addressBill1" size=56 max=200 value="<%= cB.getAddressBill1()%>"  ><%= cB.getAddressBill1()%>
              <%=((cB.getAddressBill2().equals(""))?"":"<br>")%>
              <input type="hidden" name="addressBill2" size=56 max=200 value="<%= cB.getAddressBill2()%>"  ><%= cB.getAddressBill2()%>
            <br><input type="hidden" name="cityBill" value="<%= cB.getCityBill()%>" ><%= cB.getCityBill()%>, <input type="hidden" value="<%=cB.getStateBillId()%>" name="stateBillId"><%= sl.getValue("lu_abreviated_states", "id", cB.getStateBillIdString(), "value")%> <input type="hidden" name="zipcodeBill" value="<%= cB.getZipcodeBill()%>" ><%= cB.getZipcodeBill()%>
            <br>Country:&nbsp;<input type="hidden" value="<%=cB.getCountryBillId()%>" name="countryBillId"><%= sl.getValue("lu_countries", "id", cB.getCountryBillIdString(), "value")%>
         </div>
         </td>
         <td colspan="2" style="border:1px gray solid;padding:5px;">
         <input type="hidden" name="changeShipAddress" value="false" >
	        <div id="displayShip">
	          	<div class="subtitle1">Shipping Address:</div>
	            <div class="subtitle">
	            <%=shipToName%><br>
					<input type="hidden" name="addressMail1" size=56 max=200 value="<%= addressMail1%>" ><%= addressMail1%>
	              <%=((addressMail2.equals(""))?"":"<br>")%>
	              <input type="hidden" name="addressMail2" size=56 max=200 value="<%=addressMail2%>" ><%= addressMail2%>
	            <br><input type="hidden" name="cityMail" value="<%=cityMail%>" ><%= cityMail%>, <input type="hidden" value="<%=stateMailId%>" name="stateMailId"><%= sl.getValue("lu_abreviated_states", "id", stateMailId, "value")%>
	              <input type="hidden" name="zipcodeMail" value="<%= zipcodeMail%>" ><%=zipcodeMail%>
	            <br>Country: <input type="hidden" value="<%=countryMailId%>" name="countryMailId"><%= sl.getValue("lu_countries", "id", countryMailId, "value")%>
	            <script>
		            function changeAddress(){
			            document.getElementById('displayShip').style.display='none';
			            document.getElementById('processButtons').style.display='none';
			            document.getElementById('<%=((numShipLocations>1)?"chooseShip":"editShip")%>').style.display='';
			            <%=((numShipLocations>1)?"":"document.forms[0].changeShipAddress.value='true';")%>
		            }
		            function cancelChangeAddress(){
			            document.getElementById('displayShip').style.display='';
			            document.getElementById('processButtons').style.display='';
			            document.getElementById('<%=((numShipLocations>1)?"chooseShip":"editShip")%>').style.display='none';
			            <%=((numShipLocations>1)?"":"document.forms[0].changeShipAddress.value='false';")%> 
		            }
		            function cancelEditShipAddress(){
		            	document.getElementById('processButtons').style.display='';
		            	document.getElementById('displayShip').style.display='';
		            	document.getElementById('editShip').style.display='none';
		            	document.forms[0].changeShipAddress.value='false';
		            }
	            </script>
	            <div align=center><a href="javascript:changeAddress();" class="graybutton" style="padding:2px;">Change&nbsp;Shipping&nbsp;Address</a></div>
	            </div>
			</div>
			<div id="chooseShip" style="display:none;">
				Choose Shipping Address:<br><i>Choose an address from the list below or click 'Add a new shipping address'</i><br><%=shipLocations%><br>
				<a href="javascript:processShipLocation('0');" class="graybutton" style="padding:2px;"> + Add&nbsp;New&nbsp;Shipping&nbsp;Address</a>&nbsp;&nbsp;<a href="javascript:cancelChangeAddress()" class="graybutton" style="padding:2px;">Cancel&nbsp;Shipping&nbsp;Address&nbsp;Change</a>
			</div>
			<div id="editShip" style="display:none;"><br><br>
		  		<div class="subtitle1">Add&nbsp;New&nbsp;Shipping&nbsp;Address:</div>
		        <div class="subtitle">
		        	  Title for new address: <input type="text" name="addressTitleE" size=40 max=200 value=""><br>
		        	  Save this Address to be reused? <%if(reuseAddresses){%><input type=radio name="storeShipLocation" value="1" checked=true>Yes&nbsp;&nbsp;<input type=radio name="storeShipLocation" value="0">No<%}else{%><input type=radio name="storeShipLocation" value="0" checked=true>No&nbsp;&nbsp;<input type=radio name="storeShipLocation" value="1">Yes<%}%><br>
		              Company/Ship To (if different from registration): <input type="text" name="shipToCompany" size=60 max=200 value=""><br>
		              Street Address 1: <input type="text" name="addressMail1E" size=40 max=200 value=""><br>
		              Street Address 2: <input type="text" name="addressMail2E" size=40 max=200 value=""><br>
		              City: <input type="text" name="cityMailE" value="" onChange="">, State: <taglib:LUDropDownTag dropDownName="stateMailIdE" table="lu_abreviated_states" selected="<%=cB.getStateMailIdString()%>" />
		              Zip/Postal Code: <input type="text" name="zipcodeMailE" value="" onChange=""><br>
		              Country: <taglib:LUDropDownTag dropDownName="countryMailIdE" table="lu_countries" /><br>
		              <div align=center><a href="javascript:cancelEditShipAddress()" class="graybutton"  style="padding:2px;">Cancel&nbsp;Edit&nbsp;Ship&nbsp;Address</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:document.forms[0].action='';document.forms[0].submit();" class="graybutton"  style="padding:2px;">Save&nbsp;New&nbsp;Address</a></div>
				</div>
			</div>
            </td></tr>
        </table>
        <% if (session.getAttribute("Login") == null) {%>
        <table align="center" width="80%" class=label>
          <tr>
            <td colspan=4 height="30" class="subtitle1">New User Section</td>
          </tr>
          <tr>
            <td>Choose Login Name: *</td>
            <td colspan="3"><input type="text" name="newUserName" value="<%=cB.getNewUserName()%>"></td>
          </tr>
          <tr>
            <td>Choose Password: *</td>
            <td><input type="password" name="newPassword" value=""></td>
            <td>Confirm: *</td>
            <td><input type="password" name="newPasswordCheck" value=""></td>
          </tr>
          <tr>
            <td colspan="4">I have read and agree to the <a href="javascript:pop('/legal/terms_page_1.jsp','600','650')" class="minderACTION">MarComet
              Site Use Agreement</a>
              <input type="checkbox" name="userAgreement" value="true">
            &lt;== Please Review and Check to continue.</td>
          </tr>
        </table>

        <%	}%>
