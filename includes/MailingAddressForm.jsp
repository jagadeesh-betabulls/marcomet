<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*,com.marcomet.environment.*,java.util.*,com.marcomet.catalog.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:setProperty name="cB" property="*"/>  
<%
	String jobId=((request.getParameter("jobId")==null)?"0":request.getParameter("jobId"));
	String displayClass=((request.getParameter("displayClass")==null)?"bodyBlack":request.getParameter("displayClass"));
	String shippingLocationId=((request.getParameter("shippingLocationId")==null)?sl.getValue("jobs", "id", jobId, "ship_location_id"):request.getParameter("shippingLocationId"));	
	
	
	Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
	Statement st = conn.createStatement();
	String addressMail1="";
	String addressMail2="";
	String cityMail="";
	String stateMailId="";
	String zipcodeMail="";
	String countryMailId="";
	String shipToName="";
	int numShipLocations=0;
	boolean editor=((request.getParameter("editor")==null || request.getParameter("editor").equals("false"))?false:true);
	boolean formNeeded=((request.getParameter("formNeeded")!=null && request.getParameter("formNeeded").equals("true"))?true:false);
	String shipLocationIdChoice = ((request.getParameter("shipLocationIdChoice")==null)?"0":request.getParameter("shipLocationIdChoice"));
	boolean updateJob=false;
	String buyerContactId=sl.getValue("jobs", "id", jobId, "jbuyer_contact_id");
	String buyerCompanyId=sl.getValue("contacts", "id", buyerContactId, "companyid");
	cB.setContactId(buyerContactId);

    if(request.getParameter("changeShipAddress")!=null && request.getParameter("changeShipAddress").equals("true")){
		String newAddr="insert into shipping_locations ( address2, address1, state, zip, country_id, contactid, location_title, city, ship_to_name,companyid,active_flag) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)";
	    	PreparedStatement cAddr = conn.prepareStatement(newAddr);   
	    	cAddr.clearParameters(); 
	    			
    		cAddr.setString(1, request.getParameter("addressMail2E"));
    		cAddr.setString(2, request.getParameter("addressMail1E"));
    		cAddr.setString(3, request.getParameter("stateMailIdE"));
    		cAddr.setString(4, request.getParameter("zipcodeMailE"));
    		cAddr.setString(5, request.getParameter("countryMailIdE"));
    		cAddr.setString(6, buyerContactId);
    		cAddr.setString(7, request.getParameter("addressTitleE"));
    		cAddr.setString(8, request.getParameter("cityMailE"));
    		cAddr.setString(9, request.getParameter("shipToCompany"));
    		cAddr.setString(10, buyerCompanyId);
    		cAddr.setString(11, "1");
    	 	cAddr.executeUpdate();
    	 	
    	 	ResultSet lId = st.executeQuery("select max(id) as id from shipping_locations");
    	 	if (lId.next()){
    	 		shippingLocationId=lId.getString("id");
    	 		//update the job record with the shipLocationId
		    	updateJob=true;
    	 	}
    	
    } else{
    		if(!shipLocationIdChoice.equals("0")){
    			shippingLocationId=shipLocationIdChoice;
    			updateJob=true;
    		} else if(shippingLocationId.equals("0")){
	    		String compAddr="select id from shipping_locations where address2=? and address1=? and state=? and zip=? and country_id=? and contactid=? and city=? and companyid=? and active_flag=1";
	    		PreparedStatement cAddr = conn.prepareStatement(compAddr);
				cAddr.clearParameters();
				cAddr.setString(1, cB.getAddressMail2());
				cAddr.setString(2, cB.getAddressMail1());
				cAddr.setString(3, cB.getStateMailIdString());
				cAddr.setString(4, cB.getZipcodeMail());
				cAddr.setString(5, cB.getCountryMailIdString());
				cAddr.setString(6, buyerContactId);
				cAddr.setString(7, cB.getCityMail());
				cAddr.setString(8, buyerCompanyId);
				
	    	 	ResultSet lId = cAddr.executeQuery();
	    	 	if (lId.next() && lId.getString("id")!=null){
	    	 		shippingLocationId=lId.getString("id");
	    	 		updateJob=true;
	    	 	}else{
	    	 		String newAddr="insert into shipping_locations ( address2, address1, state, zip, country_id, contactid, location_title, city, companyid, active_flag) values ( ?, ?, ?, ?, ?, ?, ?, ?, ?,?)";
	    			cAddr = conn.prepareStatement(newAddr);   
	    			cAddr.clearParameters(); 
	    	 		cAddr.setString(1, cB.getAddressMail2());
					cAddr.setString(2, cB.getAddressMail1());
					cAddr.setString(3, cB.getStateMailIdString());
					cAddr.setString(4, cB.getZipcodeMail());
					cAddr.setString(5, cB.getCountryMailIdString());
					cAddr.setString(6, buyerContactId);
					cAddr.setString(7, "Default");					
					cAddr.setString(8, cB.getCityMail());
					cAddr.setString(9, buyerCompanyId);
					cAddr.setString(10,"1");
					cAddr.executeUpdate();
					
					lId = st.executeQuery("select max(id) as id from shipping_locations");
		    	 	if (lId.next()){
		    	 		shippingLocationId=lId.getString("id");
		    	 		updateJob=true;
		    	 	}	
	    	 	}
	    	 }    				
    	}
	if (updateJob){
		String upJob="update jobs set ship_location_id=? where id=?";
   		PreparedStatement uJob = conn.prepareStatement(upJob);
	    uJob.clearParameters(); 
	    uJob.setString(1, shippingLocationId);
		uJob.setString(2, jobId);
		uJob.executeUpdate();
	}
    String locSQL = "select *,if(s.ship_to_name is null or s.ship_to_name='',c.company_name,s.ship_to_name) as 'shipToName' from shipping_locations s left join companies c on s.companyid=c.id where active_flag=1 and s.id='"+shippingLocationId+"'";

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
if(editor){
    locSQL = "select shipping_locations.id,concat(location_title,': ',if(ship_to_name is null or ship_to_name='',c.company_name,ship_to_name),', ',address1,', ',address2,if(address2='','',', '),city,', ',st.value,', ',zip) as 'addressStr' from shipping_locations left join companies c on shipping_locations.companyid=c.id left join lu_abreviated_states st on st.id=state  where contactid='"+buyerContactId+"'  and active_flag=1";

    locRS = st.executeQuery(locSQL);
    String shipLocations="<select name='shipLocationIdChoice' onChange='processShipLocation(this.value)'>";
    while (locRS.next()) {
		shipLocations+="<option value='"+locRS.getString("id")+"' "+((locRS.getString("id").equals(shippingLocationId))?"selected":"")+" >"+locRS.getString("addressStr")+"</option>";
		numShipLocations=numShipLocations+1;
    }
	shipLocations+="<option value='0'>Enter New Shipping Address</option></select>";%>
	<script language="JavaScript">
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
	    function changeAddress(){
            document.getElementById('displayShip').style.display='none';
            document.getElementById('<%=((numShipLocations>1)?"chooseShip":"editShip")%>').style.display='';
            <%=((numShipLocations>1)?"":"document.forms[0].changeShipAddress.value='true';")%>
        }
        function cancelChangeAddress(){
            document.getElementById('displayShip').style.display='';
            document.getElementById('<%=((numShipLocations>1)?"chooseShip":"editShip")%>').style.display='none';
            <%=((numShipLocations>1)?"":"document.forms[0].changeShipAddress.value='false';")%> 
        }
        function cancelEditShipAddress(){
        	document.getElementById('displayShip').style.display='';
        	document.getElementById('editShip').style.display='none';
        	document.forms[0].changeShipAddress.value='false';
        }
        function processChange(){
        	if(document.forms[0].addressTitleE.value==''){alert("Please enter a title for this address.");
        	}else if(document.forms[0].addressMail1E.value==''){alert("Please enter a street address for this address.");
        	}else if(document.forms[0].cityMailE.value==''){alert("Please enter a city for this address.");
        	}else if(document.forms[0].zipcodeMailE.value==''){alert("Please enter a zip code for this address.");
        	}else{
        		document.forms[0].action='';
        		document.forms[0].submit();
        	}
        }
        
	</script>
	<%if(formNeeded){%><form action='' method="post"><%}%>
	<input type="hidden" name="changeShipAddress" value="false" >
				<div id="chooseShip" style="display:none;">
				Choose Shipping Address: <%=shipLocations%><br>
				<a href="javascript:cancelChangeAddress()" class="greybutton" style="padding:2px;">Cancel&nbsp;Shipping&nbsp;Address&nbsp;Change</a>
			</div>
			
			<div id="editShip" style="display:none;">
		  		<div class="subtitle1">Add&nbsp;New&nbsp;Shipping&nbsp;Address:</div>
		        <div class="subtitle">
		        	  Title for new address: <input type="text" name="addressTitleE" size=40 max=200 value=""><br>
		              Company/Ship To (if different from registration): <input type="text" name="shipToCompany" size=60 max=200 value=""><br>
		              Street Address 1: <input type="text" name="addressMail1E" size=40 max=200 value=""><br>
		              Street Address 2: <input type="text" name="addressMail2E" size=40 max=200 value=""><br>
		              City: <input type="text" name="cityMailE" value="" onChange="">, State: <taglib:LUDropDownTag dropDownName="stateMailIdE" table="lu_abreviated_states" selected="<%=cB.getStateMailIdString()%>" />
		              Zip/Postal Code: <input type="text" name="zipcodeMailE" value="" onChange=""><br>
		              Country: <taglib:LUDropDownTag dropDownName="countryMailIdE" table="lu_countries" /><br>
		              <div align=left><a href="javascript:cancelEditShipAddress()" class="greybutton"  style="padding:2px;">Cancel&nbsp;Edit&nbsp;Ship&nbsp;Address</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:processChange()" class="greybutton"  style="padding:2px;">Save&nbsp;New&nbsp;Address</a></div>
				</div>
			</div>
			<%if(formNeeded){%></form><%}%>
	<%}%>
	<div id="displayShip">
	<div class="<%=displayClass%>"><b>Ship To:</b><br>
	  <%=shipToName%><br>
	  <%= addressMail1%>
	  <%=((addressMail2.equals(""))?"":"<br>")%>
	  <%= addressMail2%>
	  <br><%= cityMail%>, <%= sl.getValue("lu_abreviated_states", "id", stateMailId, "value")%>    <%=zipcodeMail%>
	  <br>Country: <%= sl.getValue("lu_countries", "id", countryMailId, "value")%><%if (editor){
	  %><div align=left><br><a href="javascript:changeAddress();" class="greybutton" style="padding:2px;">Change&nbsp;Shipping&nbsp;Address</a></div><%}%>
	</div>
			</div>

            </td></tr>
        </table><br>