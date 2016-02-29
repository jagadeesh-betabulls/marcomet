<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*,com.marcomet.tools.*;" %>
<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
<link rel="stylesheet" href="/styles/modalbox.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script type="text/javascript" src="/javascripts/prototype1.js"></script>
<script type="text/javascript" src="/javascripts/scriptaculous1.js"></script>
<html>
  <head>
    <title><%=request.getParameter("title")%></title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  </head>
  <script type="text/javascript">
    function ShowCharges(productId, customerId, amount){
      var selectedShipper = "";
      for(i=0;i<document.forms.shipForm.shipper.length;i++){
        if(document.forms.shipForm.shipper[i].checked){
          selectedShipper = document.forms.shipForm.shipper[i].value;
          break;
        }
      }

      var ajaxRequest;
      if(window.XMLHttpRequest){
        //Mozilla, Netscape.
        ajaxRequest = new XMLHttpRequest();
      }
      else if(window.ActiveXObject){
        //Internet Explorer.
        ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
      }

      var params = "shipper="+selectedShipper+"&productId="+productId+"&amount="+amount+"&customerId="+customerId;
      ajaxRequest.open("post", "/servlet/com.marcomet.commonprocesses.ProcessShippingCost", true);
      ajaxRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
      ajaxRequest.send(params);
      ajaxRequest.onreadystatechange = function(){
        if(ajaxRequest.readyState == 4){
          if(ajaxRequest.status == 200){
            eval(ajaxRequest.responseText);
          }
        }
      };
    }
  </script>
  <body>
    <form id="shipForm">
      <br>
      &nbsp;Product ID :&nbsp;<input id="productId" value="">
      <br>
      &nbsp;Customer ID :&nbsp;<input id="customerId" value="">
      <br>
      &nbsp;Quantity :&nbsp;<input id="amount" value="">
      <br><br>
      <input type="radio" name="shipper" value="ups" checked>Ship Thru UPS
      <input type="radio" name="shipper" value="fedex">Ship Thru FedEx
      <br><br>
      <input type="button" value="Show Charges" onClick="javascript:$('aCost').innerHTML = ''; $('hCost').innerHTML = ''; $('tCost').innerHTML = ''; ShowCharges($('productId').value, $('customerId').value, $('amount').value)">
      &nbsp;&nbsp;&nbsp;&nbsp;
      <input type="button" value="Cancel" onClick="self.close()">
      <br><br>
      <%--<div id="divCosting">
        <br>
        &nbsp;Ground Cost :&nbsp;<input id="GroundCost" value="">
        <br>
        &nbsp;Next Day Cost :&nbsp;<input id="NextDayCost" value="">
        <br>
        &nbsp;Second Day Cost :&nbsp;<input id="SecondDayCost" value="">
        <br>
        &nbsp;Three Day Cost :&nbsp;<input id="ThreeDayCost" value="">
        <br>
      </div>--%>
      <table border="1" cellpadding="1" cellspacing="1">
        <tr>
          <td><div id="aCost"></div></td>
          <td><div id="hCost"></div></td>
          <td><div id="tCost"></div></td>
        </tr>
      </table>
    </form>
  </body>
</html>