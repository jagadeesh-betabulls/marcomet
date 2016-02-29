function updateAllShipPrices(marcometMarkup, change, markup, edit,shipPricePolicy,shipCostPolicy,capHandlingFeeFlag,subvendor_handling,maxSVHandling,shipAdjust,editor,stdShipPrice,jobPrice) {
	var maxSubVendorHandling=parseFloat(subvendor_handling);
	var pricePercent=.1;
	var shipPercent=.2;
	if (shipPricePolicy==("0")){
			if(capHandlingFeeFlag==("1")){
				if (document.forms[0].svhandling.value>0 && document.forms[0].svhandling.value > maxSubVendorHandling){
					alert('The maximum allowable handling fee for this shipment is $'+maxSVHandling+'. Your handling has been adjusted accordingly.');
					document.forms[0].svhandling.value=maxSVHandling;
					document.forms[0].svhandling.value.focus;
				}
			}
			var handling = Math.round(document.forms[0].handling.value*100)/100;
	        var allowance=Math.round(document.forms[0].allowance.value*100)/100;
	        var svhandling = Math.round(document.forms[0].svhandling.value*100)/100;
	        var price = Math.round(document.forms[0].cost.value * 100)/100+handling+svhandling+allowance;
			if (shipAdjust=='true'){
				if (price>0){
		        	alert("Are you sure you want to enter a positive adjustment? This will increase the shipping cost owed to vendor.");
		    	}
			}
			if (allowance>0){
		        alert("Are you sure you want to enter a positive allowance amount? This will increase the shipping price billed to the customer."); 
		    }
	        document.forms[0].price.value= roundCurrency(price);
	        document.forms[0].allowance.value=allowance;
	        
	        if (document.forms[0].handling.value>(pricePercent*jobPrice)){
				handling=Math.round(( )*100)/100;
				document.forms[0].handling.value=handling;
				price = Math.round(document.forms[0].cost.value * 100)/100 +handling+svhandling+allowance;
	        	alert("The Handling Charge exceeds "+(pricePercent*100)+"% of the job price, it will be reduced accordingly.");
			}
			if (document.forms[0].handling.value > (price*shipPercent)) {
				handling=Math.round((document.forms[0].cost.value + document.forms[0].svhandling.value + allowance) * (shipPercent/(1-shipPercent))*100)/100;
				document.forms[0].handling.value=handling;
				price = Math.round(document.forms[0].cost.value * 100)/100 +handling+svhandling+allowance;
	        	alert("The Handling Charge exceeds "+(shipPercent*100)+"% of the shipping price, it will be reduced accordingly.");
				//(document.forms[0].cost.value-handling)*shipPercent;
			}
			document.forms[0].price.value= roundCurrency(price);
			document.getElementById('price').innerHTML= formatCurrency(Math.round(price * 100) / 100);
	//If shipping is included in the price the allowance will equal the cost values to negate the shipping price
	}else if (shipPricePolicy==("1") ){
			if(capHandlingFeeFlag==("1")){
				if (document.forms[0].svhandling.value>0 && document.forms[0].svhandling.value > maxSubVendorHandling){
					alert('The maximum allowable handling fee for this shipment is $'+maxSVHandling+'. Your handling has been adjusted accordingly.');
					document.forms[0].svhandling.value=maxSVHandling;
					document.forms[0].svhandling.value.focus;
				}
			}
			var handling = (document.forms[0].handling.value*100/100);
	        var svhandling = (document.forms[0].svhandling.value*100/100);
			if(editor=='true'){
				var allowance = ((document.forms[0].overrideAllowance.checked)? (document.forms[0].allowance.value*100/100):0-((document.forms[0].cost.value * 100)/100 +handling+svhandling));
				if (allowance>0){
		        	alert("Are you sure you want to enter a positive allowance amount? This will increase the shipping price billed to the customer."); 
		    	}
			}else{
				var allowance = 0-((document.forms[0].cost.value * 100/100) +handling+svhandling);
			}
	        var price = (document.forms[0].cost.value * 100/100) +handling+svhandling+allowance;
	        var costStr= (document.forms[0].cost.value * 100/100) +handling+svhandling;
			if (shipAdjust=='true' && price>0){
		        	alert("Are you sure you want to enter a positive adjustment? This will increase the shipping cost owed to vendor.");
	        }
	        document.getElementById('price').innerHTML= formatCurrency((price * 100 / 100));
	        document.forms[0].price.value= roundCurrency(price);
	        document.forms[0].allowance.value=allowance;
			if(shipCostPolicy==("1") && costStr > 0){
				alert("Shipping Cost is to be included in this job, please double-check the cost and handling fees.");
			}
	
	//If price policy sets a flat rate for pricing the allowance will be the difference between actual cost and the flat rate
	}else if (shipPricePolicy==("2") ){
			if(capHandlingFeeFlag==("1")){
				if (document.forms[0].svhandling.value>0 && document.forms[0].svhandling.value > maxSubVendorHandling){
					alert('The maximum allowable handling fee for this shipment is $'+maxSVHandling+'. Your handling has been adjusted accordingly.');
					document.forms[0].svhandling.value=maxSVHandling;
					document.forms[0].svhandling.value.focus;
				}
			}
			var handling = (document.forms[0].handling.value*100/100);
		    var svhandling = (document.forms[0].svhandling.value*100/100);
 //If the user is an editor they have the ability to override the default allowance which would negate any costs applied
			if(editor=='true'){
		        var allowance = ((document.forms[0].overrideAllowance.checked)?(document.forms[0].allowance.value*100/100): 0 - ((document.forms[0].cost.value * 100/100) +handling+svhandling-stdShipPrice));
				if (allowance>0){
			        alert("Are you sure you want to enter a positive allowance amount? This will increase the shipping price billed to the customer."); 
			    }
			}else{
				var allowance = 0-((document.forms[0].cost.value * 100/100) +handling+svhandling-stdShipPrice);
			}
	        var price = (document.forms[0].cost.value * 100/100) +handling+svhandling+allowance;
			if (shipAdjust=='true' && price>0){
		        alert("Are you sure you want to enter a positive adjustment? This will increase the shipping cost owed to vendor.");
	        }
	        document.getElementById('price').innerHTML= formatCurrency((price * 100 / 100));
	        document.forms[0].price.value= roundCurrency(price);
	        document.forms[0].allowance.value=allowance;
	}
}