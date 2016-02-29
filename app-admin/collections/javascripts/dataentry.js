function setCompInfo() {
	try{
		var index = document.forms[0].compName.selectedIndex;
		document.forms[0].cId.value = document.forms[0].compName.options[index].value;
		document.forms[0].cName.value = document.forms[0].compName.options[index].text;
		return true;
	} catch(e){
		return false;
	}
}

function checkEntryFormData(){
	var selectedCompIndex = document.forms[0].compName.value;
	if(selectedCompIndex == "0"){
		var invoiceObj = document.forms[0].invoiceNo;
		var jobObj = document.forms[0].jobNo;
                if(invoiceObj.value == " " || jobObj.value == " ")
                {
                    alert("Space not allowed !!!");
                    return false;
                }
		if(isNull(invoiceObj) && isNull(jobObj)){
			alert("Company/Job Number/Order Number/Invoice Number has to be entered.");
			return false;
		}
		if(!isNull(invoiceObj) && !isInteger(invoiceObj)){
				alert("Invalid Invoice Number !!!");
				invoiceObj.focus();
				return false;
		}
		if (!isNull(jobObj) && !isInteger(jobObj)){
				alert("Invalid Job Number !!!");
				jobObj.focus();
				return false;
		}
		if(hasSpaces(invoiceObj.value)){
				alert("Spaces not allowed in Invoice Number !!!");
				invoiceObj.focus();
				return false;
		}
		if(hasSpaces(jobObj.value)){
				alert("Spaces not allowed in Job Number !!!");
				jobObj.focus();
				return false;
		}
	}
	return true;
}

function checkViewFormData(){
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
       if(!(document.forms[0].act.value=="cancel"))
       {
	var recordCountObj = document.forms[0].recordCount;
        var obj1 = document.forms[0].txtCheckDate;
        var obj2 = document.forms[0].txtDepositDate;
        // alert(obj1.value);
       // alert(obj2.value);
        // checkDate(obj1);
        // if(obj1.IsValid == false) {
        //   alert(obj1.errormessage);
       //    obj1.focus();       
       //    return false;
        // }
        // checkDate(obj2)
        // if(obj2.IsValid == false){
        //  alert(obj2.errormessage);
        //  obj2.focus();
        //  return false;
        // }
        //alert("Test");
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

					if(isNumber(paymentObj)){
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
							alert("Balance is less than the payment for Invoice [ " + invoiceId + " ].");
							paymentObj.focus();
							return false;
						}
					} else {
						if(payment > oldPayment + balance){
							alert("New payment $ " + payment + " is more than earlier payment $ " + 
								   oldPayment + " + Balance $ " + balance + ", for Invoice [ " + invoiceId + " ].");
							paymentObj.focus();
							return false;
						}
					}
					sumpayment = sumpayment + payment;
				}
				else{
					rowcount = i + 1;
					continue;
				}
			}

			if (checkTotal > sumpayment){
				alert("Payment Total is less than Check Amount.");
				return false;
			}
			else if(checkTotal < sumpayment){
				alert("Payment Total is more than Check Amount.");
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

				if(isNumber(paymentObj)){
					payment = parseFloat(paymentObj.value);
				} else {
					alert("Invalid payment amount for Invoice [ " + invoiceId + " ].");
					paymentObj.focus();
					return false;
				}

				oldPayment = parseFloat(oldPaymentsObj.value);
				if(!(oldPayment>0)){
					if(balance < payment){
						alert("Balance is less than the payment for Invoice [ " + invoiceId + " ].");
						paymentObj.focus();
						return false;
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
	var obj = document.forms[0].txtCheckNumber;
	var val = obj.value;
	if(!isEmpty(val)){
		if(hasSpaces(val)){
			alert("Spaces not allowed in Check number !!!");
			obj.focus();
			return false;
		}
                 var cheques = document.forms[0].cn.value;
                if(cheques.indexOf(val) >=0){
                   alert("Check Number is already there !!!");
                    return false;
                }
		//if (isInteger(obj)){
		//	return true;
		//}
		//else {
		//	alert("Invalid Check number !!!");
		//	obj.focus();
		//	return false;
		//}
             return true;
	}
	else{
		alert("Check number cannot be blank. !!!");
		obj.focus();
		return false;
	}
}

function checkChequeAmount(){
	var obj = document.forms[0].txtCheckAmt;
	var val = obj.value;
	if(!isEmpty(val)){
		if(hasSpaces(val)){
			alert("Spaces not allowed in Check Amount !!!");
			obj.focus();
			return false;
		}
		if (isNumber(obj)){
			if(parseFloat(val) > 0) {
				return true;
			}else return false;
		}
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
	month1 = parseInt(checkDate[0]);
	day1 = parseInt(checkDate[1]);
	year1 = parseInt(checkDate[2]);

	var depositDate = val2.split('-');
	month2 = parseInt(depositDate[0]);
	day2 = parseInt(depositDate[1]);
	year2 = parseInt(depositDate[2]);

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
	var checkTotal = parseFloat(checkObj.value);
        
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

				if(isNumber(paymentObj)){
					payment = parseFloat(paymentObj.value);
				} else {
					alert("Invalid payment amount for Invoice [ " + invoiceId + " ].");
					paymentObj.focus();
					return false;
				}

				rowcount = i + 1;
				if(balance < payment){
					alert("Balance is less than the payment for Invoice [ " + invoiceId + " ].");
					paymentObj.focus();
					return false;
				}
				sumpayment = sumpayment + payment;
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

			if(isNumber(paymentObj)){
				payment = parseFloat(paymentObj.value);
			} else {
				alert("Invalid payment amount for Invoice [ " + invoiceId + " ].");
				paymentObj.focus();
				return false;
			}

			if(balance < payment){
				alert("Balance is less than the payment for Invoice [ " + invoiceId + " ].");
				paymentObj.focus();
				return false;
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
           
	if(dateVal[2].length == 0 || isNaN(dateVal[2]) || dateVal[2].indexOf("e") >= 0){
		alert(_nm +" Date: The year is invalid !!!");
		return false;
	}
	if(dateVal[1].length == 0 || isNaN(dateVal[1])|| dateVal[1].indexOf("e")>= 0){
		alert(_nm + " Date: The day is invalid !!!");
		return false;
	}
	if(dateVal[0].length == 0 || isNaN(dateVal[0])|| dateVal[0].indexOf("e")>= 0 ){
		alert(_nm + " Date: The month is invalid !!!");
		return false;
	}
	
	var m = parseInt(dateVal[0]);
	var d = parseInt(dateVal[1]);
	var y = parseInt(dateVal[2]);
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
	return true;
 }
 
 function isNumber(obj) {
 	var tempVal 
	if(!isNull(obj)){
		var value = obj.value;
		if (!isNaN(value) && !(value.indexOf("-") >= 0)){
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
				if(parseInt(valString) != 0) {
					return true;
				}
			}
		}
	}
	return false;
}

function isNull(obj) {
 	var value = obj.value;
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

function addEditPayments(obj){
	var i;
	var paymentObj;
	var lastValueObj;
	var lastVal=0.0;
	var total = 0.0;
         
	//if(document.forms[0].payments.length != null) {
        if(true){
             var count;
               if(document.forms[0].payments.length == null)
                 count = 1
                else
		 count = document.forms[0].payments.length;
		for(i=0;i<count;i++)
		{
                        if(count==1)
    		        {
                          paymentObj  = document.forms[0].payments;
                          lastValueObj = document.forms[0].lastValue;
                        } else  {     
			   paymentObj = document.forms[0].payments[i];
			  lastValueObj = document.forms[0].lastValue[i];
                        }
	if(paymentObj == obj)
        {
	   if(!isEmpty(obj.value) && (obj.value.length>=0))
           {
		//if(isNumber(obj) && isNumber(lastValueObj))
                if(true)
		{
		  var val;
                  if(!isNaN(obj.value))		
		    val = parseFloat(obj.value);
						if(isNaN(val)){
							val = 0.0;
						}
						if(isNaN(lastValueObj.value)){
							lastValueObj.value = 0.0;
						}
						
						lastVal = parseFloat(lastValueObj.value);
						total = parseFloat(document.forms[0].totalPayment.value);
var totVal = total  - lastVal + val;
			var totValues = new String(totVal);
tolValues = totValues.substring(totValues.indexOf(".") + 2)
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
			document.forms[0].totalPayment.value=totValues;
                        if(count != 1)
			  document.forms[0].lastValue[i].value = val;
		        else
                           document.forms[0].lastValue.value = val;		
					}
				}
				else{
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
				document.forms[0].totalPayment.value=totValues;
                              if(count!=1)
				 document.forms[0].lastValue[i].value = val;
                              else
                                  document.forms[0].lastValue.value = val; 
				}
			}
		}
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


