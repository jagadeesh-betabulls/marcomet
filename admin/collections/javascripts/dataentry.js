function round(number,X) {
// rounds number to X decimal places, defaults to 2
    X = (!X ? 2 : X);
    return Math.round(number*Math.pow(10,X))/Math.pow(10,X);
}

function setCompInfo() {
	try{
		var index = document.forms[0].compName.selectedIndex;
		document.forms[0].cId.value = document.forms[0].compName.options[index].value;
		if(document.forms[0].act.value!="exit")
		if(document.forms[0].cId.value == 0 && document.forms[0].name != "entryForm"){
		  alert("Please select a company!!!  ");
		  return false;
		}
		document.forms[0].cName.value = document.forms[0].compName.options[index].text;
		return true;
	} catch(e){
		return false;
	}
}
 
function checkEntryFormData(){
	var selectedCompIndex = document.forms[0].compName.value;
	if(selectedCompIndex == "0"){
		var invoiceObj = document.forms[0].invoiceNo.value;
		var jobObj = document.forms[0].jobNo.value;
		var custObj = document.forms[0].custNo.value;
		var orderObj = document.forms[0].orderNumber.value;
                if(invoiceObj.value == " " || jobObj.value == " " || orderObj == " ")
                {
                    alert("Space not allowed !!!");
                    return false;
                }
		if(isNull(invoiceObj) && isNull(jobObj) && isNull(custObj) && isNull(orderObj)){
			alert("Company/Job Number/Invoice Number/Order Number/Customer Number has to be entered.");
			return false;
		}
		//ordernumber
		
		if(isNull(orderObj) && isInteger(orderObj)){
			alert("Invalid Order Number !!!");
			orderObj.focus();
			return false;
		}
		if(isNull(invoiceObj) && isInteger(invoiceObj)){
				alert("Invalid Invoice Number !!!");
				invoiceObj.focus();
				return false;
		}
		if (isNull(jobObj) && isInteger(jobObj)){
				alert("Invalid Job Number !!!");
				jobObj.focus();
				return false;
		}
		if (isNull(custObj) && isInteger(custObj)){
				alert("Invalid Customer Number !!!");
				custObj.focus();
				return false;
		}
		//ordernumber
		if(hasSpaces(orderObj)){
			alert("Spaces not allowed in Order Number !!!");
			orderObj.focus();
			return false;
	}
		
		if(hasSpaces(invoiceObj)){
				alert("Spaces not allowed in Invoice Number !!!");
				invoiceObj.focus();
				return false;
		}
		if(hasSpaces(jobObj)){
				alert("Spaces not allowed in Job Number !!!");
				jobObj.focus();
				return false;
		}
		if(hasSpaces(custObj)){
				alert("Spaces not allowed in Customer Number !!!");
				custObj.focus();
				return false;
		}
	}
	return true;
}

function checkViewFormData(){
	var orderObj = document.forms[0].OrderNumber;
	var invoiceObj = document.forms[0].InvoiceNo;
	var chequeObj = document.forms[0].ChequeNumber;
	var chequeDFObj = document.forms[0].checkDateFrom;
	var chequeDTObj = document.forms[0].checkDateTo;
        if(!checkDateField(chequeDFObj,"From")){
           return false;
        }
        if(!checkDateField(chequeDTObj,"To")){
             return false;
        }
        //ordernumber
        if(orderObj.value==" ")
        	{
        	alert("Space not allowed !!!");
        	orderObj.focus();
        	return false;
        	}
       if(invoiceObj.value == " " )
       {
          alert("Space not allowed !!!");
          invoiceObj.focus();
          return false;
       }
       
        if(chequeObj.value == " ")
        {
          alert("Space not allowed !!!");
          chequeObj.focus();
          return false;
        }
       /*	if(isNull(invoiceObj) &&  !isInteger(invoiceObj)){
		alert("Invalid Invoice Number !!!");
		invoiceObj.focus();
		return false;
	}
	if (isNull(chequeObj) && !isInteger(chequeObj)){
		alert("Invalid Check Number !!!");
		chequeObj.focus();
		return false;
	}
	*/

	if(!isNull(invoiceObj)){
		if(hasSpaces(invoiceObj.value)){
			alert("Spaces not allowed in Invoice Number !!!");
			invoiceObj.focus();
			return false;
		}

		if(!isInteger(invoiceObj)){
			alert("Invalid Invoice Number !!!");
			invoiceObj.focus();
			return false;
		}
	}
//Ordernumber
	if(!isNull(orderObj)){
		if(hasSpaces(orderObj.value)){
			alert("Spaces not allowed in Order Number !!!");
			orderObj.focus();
			return false;
		}

		if(!isInteger(orderObj)){
			alert("Invalid Order Number !!!");
			orderObj.focus();
			return false;
		}
	}
	
	
	
	if (!isNull(chequeObj)){
		if(hasSpaces(chequeObj.value)){
			alert("Spaces not allowed in Check Number !!!");
			chequeObj.focus();
			return false;
		}

		//if(!isInteger(chequeObj)){
	        //      alert("Invalid Check Number !!!");
		//	chequeObj.focus();
		//	return false;
		//}
	}

	if (!isNull(chequeDFObj)){
		if(chequeDFObj.value.length < 8) {
			alert("Invalid Check FROM date.");
			chequeDFObj.focus();
			return false;
		}
	}

	if (!isNull(chequeDTObj)){
		if(chequeDTObj.value.length < 8) {
			alert("Invalid Check TO date.");
			chequeDTObj.focus();
			return false;
		}
	}
	if (!isNull(chequeDFObj) && !isNull(chequeDTObj)){
		if(!dateDiff(chequeDFObj.value,chequeDTObj.value)) {
			alert("Check TO date is less than Check FROM date.");
			chequeDFObj.focus();
			return false;
		}
	}

	return true;
}

function checkAddFormData(){

       //alert(document.forms[0].act.value);
       //alert(document.forms[0].cn.value);
       if(!(document.forms[0].act.value=="cancel")&&!(document.forms[0].act.value=="showAll"))
       {
	var recordCountObj = document.forms[0].recordCount;
        var obj1 = document.forms[0].txtCheckDate;
        var obj2 = document.forms[0].txtDepositDate;

	if(recordCountObj.value == 0){
		return false;
	}
	if(checkChequeNumber()){
		if(checkChequeDates()){
			if(checkChequeAmount()){
				return checkAddEntryData();
			}
			else{
				return false;
			}
		}
		else{
			return false;
		}
	}
	else{
		return false;
	}
  }
}

function checkEditFormData(){

   if(!(document.forms[0].act.value=="viewlist"))
   {
	var recordCountObj = document.forms[0].recordCount;
	if(recordCountObj.value == 0){
		return false;
	}
	 if(checkChequeNumber()){
	 if(!checkChequeAmount())
			return false;
  		if(!checkChequeDates())
			return false;
	 }
	  else
	 {
	    return false;
	  }
	if(document.forms[0].data.value=="delete"){
		return true;
	}
	else {
		var sumpayment = 0;
		var i;
		var balance;
		var payment;
		var oldPayment;
		var rowcount;
		var invoiceId;
		var paymentObj;
		var oldPaymentsObj;

		var checkTotal = parseFloat(document.forms[0].txtCheckAmt.value);

		if(document.forms[0].payments.length != null) {
			var count = document.forms[0].payments.length;

			for(i=0;i<count;i++){
				balance = parseFloat(document.forms[0].balance[i].value);
				invoiceId = document.forms[0].invoicenum[i].value;
				paymentObj = document.forms[0].payments[i];
				oldPaymentsObj = document.forms[0].oldPayments[i];

				if(!isEmpty(paymentObj.value)){
					if(hasSpaces(paymentObj.value)){
						alert("Spaces not allowed for payment field for Invoice [ " +invoiceId + "].");
						paymentObj.focus();
						return false;
					}

					if(isNum(paymentObj)){
						payment = parseFloat(paymentObj.value);
					} else {
						alert("Invalid payment amount for Invoice [ " + invoiceId + " ].");
						paymentObj.focus();
						return false;
					}

					rowcount = i + 1;
					oldPayment = parseFloat(oldPaymentsObj.value);
					if(!(oldPayment>0)){
						if(balance < payment){
							if(!confirm("Balance is less than the payment for Invoice [ " + invoiceId + " ].")){
								paymentObj.focus();
								return false;
							}
						}
					} else {
						if(payment > oldPayment + balance){
							alert("New payment $ " + payment + " is more than earlier payment $ " +
								   oldPayment + " + Balance $ " + balance + ", for Invoice [ " + invoiceId + " ].");
							paymentObj.focus();
							return false;
						}
					}
					sumpayment = round(sumpayment + payment, 2);
				}
				else{
					rowcount = i + 1;
					continue;
				}
			}
            var tmp_1 = new String(sumpayment);
            var tmp_2 = tmp_1.substring(0,tmp_1.indexOf(".") +3);
            sumpayment = parseFloat(tmp_2);
            tmp_1 = new String(checkTotal);
            tmp_2 = tmp_1.substring(0,tmp_1.indexOf(".") +3);
            checkTotal = parseFloat(tmp_2);
			if (checkTotal > sumpayment){
				alert("Payment Total is less than Check Amount.");
				return false;
			}
			else if(checkTotal < sumpayment){
				alert("Payment Total is more than Check Amount." );
				return false;
			}
		} else {
			invoiceId = document.forms[0].invoicenum.value;
			balance = parseFloat(document.forms[0].balance.value);
			paymentObj = document.forms[0].payments;
			oldPaymentsObj = document.forms[0].oldPayments;

			if(!isEmpty(paymentObj.value)){
				if(hasSpaces(paymentObj.value)){
					alert("Spaces not allowed for payment field for Invoice [ " +invoiceId + "].");
					paymentObj.focus();
					return false;
				}

				if(isNum(paymentObj)){
					payment = parseFloat(paymentObj.value);
				} else {
					alert("Invalid payment amount for Invoice [ " + invoiceId + " ].");
					paymentObj.focus();
					return false;
				}

				oldPayment = parseFloat(oldPaymentsObj.value);
				if(!(oldPayment>0)){
					if(balance < payment){
						if(!confirm("Balance is less than the payment for Invoice [ " + invoiceId + " ].")){
							paymentObj.focus();
							return false;
						}
					}
				} else {
					if(payment > oldPayment + balance){
						alert("New payment $ " + payment + " is more than earlier payment $ " +
							   oldPayment + " + Balance $ " + balance + ", for Invoice [ " + invoiceId + " ].");
						paymentObj.focus();
						return false;
					}
				}

				if (checkTotal > payment){
					alert("Payment Total is less than Check Amount.");
					return false;
				}
				else if(checkTotal < payment){
					alert("Payment Total is more than Check Amount.");
					return false;
				}
			}
			else{
				alert("Payment has to be made against the Invoice [ " + invoiceId + " ].");
				paymentObj.focus();
				return false;
			}
		}
		return true;
	}
  }
}

function checkChequeNumber(){
   var specialChar = "!@#$%&*()<>,?"
	var obj = document.forms[0].txtCheckNumber;
	var oldObj = document.forms[0].oldCheckNumber;
	var val = obj.value;
	var oldVal = oldObj.value;
	if(val.indexOf(">") >= 0 || val.indexOf("<") >= 0){
	   if(!confirm("Check Number is not valid!!"))
	   	return false;
	}
	if(val.indexOf("^") >= 0 || val.indexOf("+") >= 0 || val.indexOf("?") >= 0 || val.indexOf("#") >= 0 || val.indexOf("&") >= 0 || val.indexOf("%") >= 0 || val.indexOf("!") >= 0 || val.indexOf("*") >= 0){
	   if(!confirm("Check Number is not valid!!"))
		   return false;
	}

	if( val == "0" || val == "00" || val == "000" || val == "0000"){
	  if(!confirm("Check Number 0 not allowed!!!")){
		obj.focus();
	  	return false;
	  }
	}

	if(!isEmpty(val)){
		if(hasSpaces(val)){
			alert("Spaces not allowed in Check number !!!");
			obj.focus();
			return false;
	}
    var cheques = document.forms[0].cn.value  + "#";
    if(cheques.indexOf( "#" + val + "#") >=0){
     if(!(val == oldVal)){
                    if(!confirm("Check Number is already there !!!"))
                    	 return false;
                   }
                }
	    return true;
	}
	else{
			alert("Check number cannot be blank. !!!");
			obj.focus();
			return false;
	}
}

function checkTest(){
 document.forms[0].cn.value  = document.forms[0].cn.value + "#" + document.forms[0].txtCheckNumber.value + "#";
}

function checkChequeAmount(){
	var obj = document.forms[0].txtCheckAmt;
	var val = obj.value;
	if(isEmpty(val))
	{
	 alert("Check Amount blank not allowed!!!")
	 obj.focus();
	 return false;

	}
	if(val.indexOf(".") > 0)
	if(!((val.indexOf(".") + 2 == (val.length - 1)) ||  (val.indexOf(".") + 2 == (val.length))))
	{
	  alert("Precision upto two decimal digits are allowed!!!");
	  obj.focus();
	  return false;
	}
	if(val.indexOf("-") > 0)
	{
	 if(!confirm("The check amount is negative!!!")){
	 	obj.focus();
	 	return false;
	 }
	}
	var chkAmt = parseInt(val,10);
	if( chkAmt == 0){
	  if(!confirm("The Check Amount is 0!!!")){
		  obj.focus();
		  return false;
	  }
	 }

	if(!isEmpty(val)){
		if(hasSpaces(val)){
			alert("Spaces not allowed in Check Amount !!!");
			obj.focus();
			return false;
		}
		if (isNum(obj)){
		//	if(parseFloat(val) != 0) {
				return true;
			}else return false;
		//}
		alert("Check amount entered is not valid !!!");
		obj.focus();
		return false;
	}
	else{
		alert("Check amount field is blank. !!!");
		obj.focus();
		return false;
	}
}

function checkDateField(_obj,_nm)
{
  var val1 = _obj.value;
   if(!isEmpty(val1)){
       if(!isDate(val1,_nm)){
         _obj.focus();
         return false;
       } else return true;
  } else return true;
}
function checkChequeDates(){
	var obj = document.forms[0].txtCheckDate;
	var val1 = obj.value;
	if(!isEmpty(val1)){
	if (!isDate(val1,"Check")){
	  //alert("Provide the Check Date in the format [mm-dd-yyyy] !!!");
			document.forms[0].txtCheckDate.focus();
			return false;
	}
	}
	else{
		alert("Please fill in the Check Date. [mm-dd-yyyy] !!!");
		document.forms[0].txtCheckDate.focus();
		return false;
	}

	obj = document.forms[0].txtDepositDate;
	var val2 = obj.value;
	if(!isEmpty(val2)){
		if (isDate(val2,"Deposit")){

			if( dateDiff(val1,val2)){
				return true;
			}
			else{
				alert("Deposit date cannot be prior to Check date.");
				document.forms[0].txtDepositDate.focus();
				return false;
			}
		}
		else {
		//	alert("Provide the Check Deposit Date in the format [mm-dd-yyyy] !!!");
			document.forms[0].txtDepositDate.focus();
			return false;
		}
	}
	else{
	    alert("Please fill in the Check Deposit Date. [mm-dd-yyyy] !!!");
		document.forms[0].txtDepositDate.focus();
		return false;
	}
}

function dateDiff(val1,val2){
	var checkDate = val1.split('-');
	month1 = parseInt(checkDate[0],10);
	day1 = parseInt(checkDate[1],10);

	year1 = parseInt(checkDate[2],10);
	var depositDate = val2.split('-');
	month2 = parseInt(depositDate[0],10);
	day2 = parseInt(depositDate[1],10);

	year2 = parseInt(depositDate[2],10);

	if(year2>year1){
		return true;
	}
	else if(year2 == year1)
	{
		if(month2 > month1){
			return true;
		}
		else if(month2==month1)
		{
			if(day2>=day1){
				return true;
			}
		}
	}
	return false;
}

function checkAddEntryData(){
	var sumpayment = 0;
	var i;
	var balance;
	var payment;
	var rowcount;
	var invoiceId;
	var paymentObj;

	var checkObj = document.forms[0].txtCheckAmt;
	var checkTotal = parseFloat(checkObj.value)*1;

	if(document.forms[0].payments.length != null) {
		var count = document.forms[0].payments.length;

		for(i=0;i<count;i++){
			balance = parseFloat(document.forms[0].balance[i].value);
			invoiceId = document.forms[0].invoicenum[i].value;
			paymentObj = document.forms[0].payments[i];

			if(!isEmpty(paymentObj.value)){
				if(hasSpaces(paymentObj.value)){
					alert("Spaces not allowed for payment field for Invoice [ " +invoiceId + "].");
					paymentObj.focus();
					return false;
				}

				if(isNum(paymentObj)){
					payment = parseFloat(paymentObj.value);
				} else {
					alert("Invalid payment amount for Invoice [ " + invoiceId + " ].");
					paymentObj.focus();
					return false;
				}

				rowcount = i + 1;
				if(balance < payment){
					if(!confirm("Balance is less than the payment for Invoice [ " + invoiceId + " ].")){
					  paymentObj.focus();
					  return false;
					}
				}
				sumpayment = round(sumpayment + payment, 2);
			}
			else{
				rowcount = i + 1;
				continue;
			}
		}
		if (checkTotal > sumpayment){
			alert("Payment Total is less than Check Amount.");
			checkObj.focus();
			return false;
		}
		else if(checkTotal < sumpayment){
			alert("Payment Total is more than Check Amount.");
			checkObj.focus();
			return false;
		}
	} else {
		invoiceId = document.forms[0].invoicenum.value;
		balance = parseFloat(document.forms[0].balance.value);
		paymentObj = document.forms[0].payments;

		if(!isEmpty(paymentObj.value)){
			if(hasSpaces(paymentObj.value)){
				alert("Spaces not allowed for payment field for Invoice [ " +invoiceId + "].");
				paymentObj.focus();
				return false;
			}

			if(isNum(paymentObj)){
				payment = parseFloat(paymentObj.value);
			} else {
				alert("Invalid payment amount for Invoice [ " + invoiceId + " ].");
				paymentObj.focus();
				return false;
			}

			if(balance < payment){
				if(!confirm("Balance is less than the payment for Invoice [ " + invoiceId + " ].")){
					paymentObj.focus();
					return false;
				}
			}

			if (checkTotal > payment){
				alert("Payment Total is less than Check Amount.");
				checkObj.focus();
				return false;
			}
			else if(checkTotal < payment){
				alert("Payment Total is more than Check Amount.");
				checkObj.focus();
				return false;
			}
		}
		else{
			alert("Payment has to be made against the Invoice [ " + invoiceId + " ].");
			paymentObj.focus();
			return false;
		}
	}
	return true;
}

function isDate(value,_nm) {
	// format mm-dd-yyyy
	if (value=="") return false;
        if(value.indexOf("-") < 1 ){
          alert(_nm + " Date: Provide the date in format [mm-dd-yyyy] !!!");
          return false;
        }
       if(value.indexOf(" ") >0){
         alert(_nm + " Date: Provide the date in format [mm-dd-yyyy] !!!");
         return false;
       }
        var dateVal = value.split('-');
        if(dateVal.length != 3){
           alert(_nm + " Date: Provide the date in format [mm-dd-yyyy] !!!");
           return false;
         }

    if(dateVal[0].length == 0 || isNaN(dateVal[0])|| dateVal[0].indexOf("e")>= 0 ){
		alert(_nm + " Date: The month is invalid !!!");
		return false;
	}

	if(dateVal[1].length == 0 || isNaN(dateVal[1])|| dateVal[1].indexOf("e")>= 0){
		alert(_nm + " Date: The day is invalid !!!");
		return false;
	}

	if(dateVal[2].length == 0 || isNaN(dateVal[2]) || dateVal[2].indexOf("e") >= 0){
		alert(_nm +" Date: The year is invalid !!!");
		return false;
	}

	var m = dateVal[0];
	var d = dateVal[1];
	var y = dateVal[2];


	if (isNaN(m)){
		return false;
	}
	else{
		if ((m < 1) || (m > 12))
		{
			alert(_nm + " Date: The month [" + m + "] is invalid !!!");
			return false;
		}
	}

	if (isNaN(d)){
		return false;
	}
	else{
		if ((d < 1) || (d > 31))
		{
			alert(_nm + " Date: The day [" + d + "] is invalid !!!");
			return false;
		}
	}
         if((m == 4 || m  == 6 || m == 9 || m == 11) && d == 31){
                alert(_nm + "Date: Month " + m + " does not have 31 days !!!");
                return false;
          }
       if(m == 2) {
          var isleap = (y % 4 == 0 && (y % 100 !=0 || y % 400 == 0));
           if(d > 29 || ( d == 29 && !isleap )) {
              alert(_nm + " Date: Month 2 does not have " + d + " days in the year " + y + " !!!" );
            return false;
       }
    }

    if (isNaN(y)){
		return false;
	}
	else{
		if ((y < 1900) || (y > 2200))
		{
			alert(_nm + " Date: The year [" + y + "] is invalid !!!");
			return false;
		}
	}
	return true;
 }

 function isNum(obj) {
 	var tempVal
	if(!isNull(obj)){
		var value = obj.value;
		if (!isNaN(value) && !(value.indexOf("-") > 0)){
			if(value.indexOf(".") >= 0) {
			  tempVal = value.substring(value.indexOf("."));
			  if(tempVal.length > 3 ) {
			  	//alert("Invalid Currency value.");
			  	obj.focus();
			  	return false;
			  }
			}
			return true;
		}
		else {
			return false;
		}
	}
	return false;
}

function isInteger(obj) {
	if(!isNull(obj)){
		var value = obj.value;
		var valString = new String(value);
		if(valString.length > 0){
			if(!((isNaN(valString)) ||
				 (valString.indexOf("e")) >= 0 ||
				 (valString.indexOf("E")) >= 0 ||
				 (valString.indexOf(".")) >= 0 ||
				 (valString.indexOf("-")) >= 0 ||
				 (valString.indexOf("+")) >= 0)
				)
			{
				if(parseInt(valString,10) != 0) {
					return true;
				}
			}
		}
	}
	return false;
}

function isNull(obj) {
 	var value = obj;
	if (value=="" || value == " ") {
		return true;
	}
	return false;
}

function isEmpty(val){
	if(val == "" ){
		return true;
	}
	return false;
}

function enablePayments(){
	var paymentObj;
	var i;
	if(document.forms[0].payments.length != null) {
		var count = document.forms[0].payments.length;

		for(i=0;i<count;i++){
			paymentObj = document.forms[0].payments[i];
			paymentObj.readonly = "false";
		}

	} else {
		paymentObj = document.forms[0].payments;
		paymentObj.readonly = "false";
	}
	document.forms[0].submit.readonly="false";
}

function confirmDelete(){
	if(confirm("This will delete the check related entries. Do you want to continue?"))
	{
                document.forms[0].act.value = "edit";
		document.forms[0].data.value='delete';
		document.forms[0].submit;
		return true;
	}
	return false;
}

function addEditPayments(obj)
{
	var i;var paymentObj; var lastValueObj; var lastVal=0.00; var total = 0.00; var totalApp=0.00;
	//if(document.forms[0].payments.length != null) {
 if(true) {
         var count;
         if(document.forms[0].payments.length == null)
           count = 1
         else
	  	   count = document.forms[0].payments.length;
	  	  
	for(i=0;i<count;i++) {
        if(count==1) {
               paymentObj  = document.forms[0].payments;
               lastValueObj = document.forms[0].lastValue;
        } else {
			  paymentObj = document.forms[0].payments[i];
			  lastValueObj = document.forms[0].lastValue[i];
        }
		if(paymentObj == obj) {
	   		if(!isEmpty(obj.value) && (obj.value.length>=0)) {
        		if((obj.value.indexOf(".") != -1))
         		if(!((obj.value.indexOf(".") + 3) >= obj.value.length)) {
           			alert("Precision of two decimal points are allowed !!!");
           			obj.focus();
           			return false;
         		}
				//if(isNum(obj) && isNum(lastValueObj))
         		if(true){
		    		var val;
            		if(!isNaN(obj.value))
		        		val = parseFloat(obj.value);
					if(isNaN(val)){
					val = 0.00;
				}
				if(isNaN(lastValueObj.value)) {
					lastValueObj.value = 0.00;
				}

				lastVal = parseFloat(lastValueObj.value);
				total = parseFloat(document.forms[0].totalPayment.value);
				var totVal = total  - lastVal + val;
			    var totValues = new String(totVal);
				tolValues = totValues.substring(totValues.indexOf(".") + 2)
				var tVal = totValues.split('.');
				if(tVal.length == 2){
					if(tVal[1].length == 1){
					    totValues = totValues +"0";
					} else if(tVal[1].length == 0) {
					   totValues = totValues +"00";
					} else if(tVal[1].length > 2){
					  if(totValues.indexOf(".") + 4 <= totValues.length) {
                         var tmp_1 = parseInt(totValues.substring(totValues.indexOf(".") +4,totValues.indexOf(".") +5),10)
                         if(tmp_1 > 5){
                            totValues = totValues.substring(0,totValues.indexOf(".") +3);
                            var tmp_3 = totValues.substring(totValues.indexOf(".") +2,totValues.indexOf(".") +3);
                            var tmp_4 = new String((parseInt(tmp_3 ) + 1))
                            totValues = totValues.substring(0,totValues.indexOf(".") +2) + tmp_4;
                            if(totValues.indexOf(".") + 2 == totValues.length)
                              totValues = totValues + "0";
                         } else {
                             totValues = totValues.substring(0,totValues.indexOf(".") +3);
                         }

					   }
					 }
				  }
				  if(tVal.length == 1)
				 {
				    totValues = totValues +".00";
				 }
				 
			     document.forms[0].totalPayment.value=totValues;
                 if(count != 1)
			       document.forms[0].lastValue[i].value = val;
		         else
                   document.forms[0].lastValue.value = val;
			}
		} else {
					val = 0.0;
					if(isNaN(lastValueObj.value)){
						lastValueObj.value = 0.0;
					}
					lastVal = parseFloat(lastValueObj.value);
					total = parseFloat(document.forms[0].totalPayment.value);
					var totVal = total + val - lastVal;
					var totValues = new String(totVal);
					var tVal = totValues.split('.');
					if(tVal.length == 2) {
						if(tVal[1].length == 1) {
						    totValues = totValues +"0";
						} else if(tVal[1].length == 0) {
						    totValues = totValues +"00";
						}
					}
					if(tVal.length == 1) {
					    totValues = totValues +".00";
					}
					if(totValues.length > totValues.indexOf(".") +3 )
					  totValues = totValues.substring(0,totValues.indexOf(".") +3)
				 document.forms[0].totalPayment.value=totValues;
                 if(count!=1)
				   document.forms[0].lastValue[i].value = val;
                 else
                   document.forms[0].lastValue.value = val;
				}
			}
			totalApp=Math.round(((((totalApp)*1)+((paymentObj.value.replace(',',''))*1)))*100)/100;
		}
		document.forms[0].totalPayment.value=totalApp;
	}
}

function hasSpaces(val){
	var index = val.indexOf(" ");
        if(val == " ")
            return true;
        if(index == 0)
           return true;
	if( (index <= (val.length - 1)) && (index >=0) ){
		return true;
	}
	return false;
}
function doExit(){
document.forms[0].act.value="exit";
}
function doCancel(){
document.forms[0].act.value="cancel";
}
function doShowAll(){
document.forms[0].act.value="showAll";
}
function doView(){
 document.forms[0].act.value="viewlist";
}
function doEdit(){
    document.forms[0].act.value="edit";
}
function CheckDate( arguments)
{
        try
        {
                var dateStr
                dateStr = new String(arguments.value);
                //if (isValidDateWithoutAlerts(dateStr)==true)
                isValidDateWithoutAlerts(dateStr)
                if(strErrMsg=="")
                {
                        arguments.IsValid = true;
                        return ; // valid string
                }
                else
                {
                        arguments.errormessage= strErrMsg
                        arguments.IsValid = false;
                        return ; // invalid string
                }
        }
catch (exception){}
}

var strErrMsg
function isValidDateWithoutAlerts(dateStr)
{
        try
        {
                strErrMsg=""
                var datePat = /^(\d{1,2})(\/|-)(\d{1,2})\2(\d{4})$/;
                var matchArray = dateStr.match(datePat);
                if (matchArray == null)
                {
                        strErrMsg="Date is not in a valid format."
                        return false;
                }
                month = matchArray[1];
                day = matchArray[3];
                year = matchArray[4];

                if(year < 1800)
                {
                        strErrMsg="Year cannot be less than 1800."
                        return false;
                }
                if (month < 1 || month > 12)
{
                        strErrMsg="Month must be between 1 and 12."
                        return false;
                }
                if (day < 1 || day > 31)
                {
                        strErrMsg="Day must be between 1 and 31."
                        return false;
                }
                if ((month==4 || month==6 || month==9 || month==11) && day==31)
                {
                        strErrMsg="Month "+month+" does not have 31 days."
                        return false;
                }
                if (month == 2)
                {
                        var isleap = (year % 4 == 0 && (year % 100 != 0 || year
% 400 == 0));
                        if (day>29 || (day==29 && !isleap))
                        {
                                strErrMsg="February does not have " + day + " days in the year " + year + "."
return false;
                        }
                }
                return true;
        }
        catch (exception){
                alert(exception.message);
        }
}


