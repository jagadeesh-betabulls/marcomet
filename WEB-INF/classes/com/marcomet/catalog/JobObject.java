package com.marcomet.catalog;

/**********************************************************************
Description:	This class contains all the meta data for jobs during
the order process

8/9/13 updated with subvendorReferenceData
 **********************************************************************/
import java.util.*;

public class JobObject {

  private String subvendorReferenceData, jobName,  shippingType,  promoCode,  gridLabel,  preBuiltFile,  preBuiltFileURL,  preBuiltPDFFile,  preBuiltPDFFileURL,  priorJobId, productId,productName,promoProdMessage;
  private int id,  vendorId,  vendorContactId,  vendorCompanyId,  jobTypeId,  serviceTypeId,  shipmentId,  quantity,  shipPricePolicy,  shipPriceSource,discountType,discountIncludesShipping;
  private double escrowPercentage,  siteHostMarkup,  marcometFee,  shippingPrice,  discount,  percentageOfShipment,salesTax,discountPercentage;
  private Hashtable jobSpecs;
  private Hashtable gridCosts;
  private boolean rfq = false;

  public JobObject() {
    jobSpecs = new Hashtable();
  } 

  public JobObject(String jobName, int id, int vendorId, int vendorContactId, int vendorCompanyId, int jobTypeId, int serviceTypeId, double escrowPercentage, double siteHostMarkup, double marcometFee, double shippingPrice, String shippingType, String promoCode, double discount, String gridLabel, int quantity,String subvendorReferenceData) {
    this.jobName = jobName;
    this.id = id;
    this.vendorId = vendorId;
    this.vendorContactId = vendorContactId;
    this.vendorCompanyId = vendorCompanyId;
    this.jobTypeId = jobTypeId;
    this.serviceTypeId = serviceTypeId;
    this.escrowPercentage = escrowPercentage;
    this.siteHostMarkup = siteHostMarkup;
    this.marcometFee = marcometFee;
    this.shippingPrice = shippingPrice;
    this.shippingType = shippingType;
    this.promoCode = promoCode;
    this.gridLabel = gridLabel;
    this.quantity = quantity;
    this.discount = discount;
    this.subvendorReferenceData = subvendorReferenceData;
    this.jobSpecs = new Hashtable();
  }

  public void addJobSpec(JobSpecObject jso) {

    //set cost to zero if this job is an rfq
    if (rfq && jso.getCost() >= 0) {
      jso.setCost(0);
    }

    if (jobSpecs == null) {
      jobSpecs = new Hashtable();
    }

    int specId = jso.getSpecId();
    jobSpecs.put(new Integer(specId).toString(), jso);

  }
  // JobSpecs hashtable manipulation methods

  public void addJobSpec(JobSpecObject jso, int catalogPage) {

    //set cost to zero if this job is an rfq
    if (rfq && jso.getCost() >= 0) {
      jso.setCost(0);
    }

    if (jobSpecs == null) {
      jobSpecs = new Hashtable();
    }

    int specId = jso.getSpecId();

    if (specId == 88888) {
      // We have a cost from a grid, check if the price needs to be added to an already existing grid price spec (88888)
      if (gridCosts == null) {
        gridCosts = new Hashtable();
      }

      gridCosts.put(new Integer(catalogPage), jso);

      double cost = 0;
      for (Enumeration e = gridCosts.elements(); e.hasMoreElements();) {
        JobSpecObject tempJso = (JobSpecObject) e.nextElement();
        cost = cost + tempJso.getCost();
      }

      jso.setCost(cost);
      jobSpecs.put(new Integer(specId).toString(), jso);

    }
    else {
      jobSpecs.put(new Integer(specId).toString(), jso);
    }

  }

  public double getEscrowDollarAmount() {
    double escrowPercentage = this.getEscrowPercentage();
    double jobPrice = this.getPrice();
    double escrowDollarAmount = jobPrice * escrowPercentage;
    return escrowDollarAmount;
  }
  // Job cost data

  public double getEscrowPercentage() {
    return escrowPercentage;
  }

  public int getId() {
    return id;
  }

  public String getJobName() {
    return jobName;
  }

  public Hashtable getJobSpecs() {
    return (Hashtable) jobSpecs.clone();
  }

  public int getJobTypeId() {
    return jobTypeId;
  }

  public double getMarcometFee() {
    return marcometFee;
  }

  public double getPercentageOfShipment() {
    return percentageOfShipment;
  }

  public int getShipmentId() {
    return shipmentId;
  }

  public double getShippingPrice() {
    return shippingPrice;
  }

  public String getShippingType() {
    return shippingType;
  }

  public double getPrice() {
    double jobPrice = 0;
    Hashtable h = this.getJobSpecs();
    for (Enumeration e = h.elements(); e.hasMoreElements();) {
      double specPrice = 0;
      try {
        specPrice = ((JobSpecObject) e.nextElement()).getPrice();
      }
      catch (Exception ex) {
        System.err.println("the calculations of jobspecs are blowing up: " + ex.getMessage());
      }
      jobPrice = jobPrice + specPrice;
    }
    return jobPrice;
  }

  public int getServiceTypeId() {
    return serviceTypeId;
  }

  public double getSiteHostMarkup() {
    return siteHostMarkup;
  }

  public int getVendorCompanyId() {
    return vendorCompanyId;
  }

  public int getVendorContactId() {
    return vendorContactId;
  }

  public int getVendorId() {
    return vendorId;
  }

  public String getPromoCode() {
	    return promoCode;
	  }
  
  public String getSubvendorReferenceData() {
	    return subvendorReferenceData;
	  }

  public double getDiscount() {
    return discount;
  }

  public boolean isRFQ() {
    return rfq;
  }

  public void removeJobSpec(int specId) {
    jobSpecs.remove(new Integer(specId).toString());
  }

  public void setAsRFQ() {
    rfq = true;
    for (Enumeration eKeys = jobSpecs.keys(); eKeys.hasMoreElements();) {
      JobSpecObject jso = (JobSpecObject) jobSpecs.get(eKeys.nextElement());
      this.addJobSpec(jso);
    }
  }

  public void setEscrowPercentage(double escrowPercentage) {
    this.escrowPercentage = escrowPercentage;
  }

  public void setId(int id) {
    this.id = id;
  }

  public void setJobName(String jobName) {
	    this.jobName = jobName;
	  }
  public void setSubvendorReferenceData(String subvendorReferenceData) {
	    this.subvendorReferenceData = subvendorReferenceData;
	  }
  
  public void setJobTypeId(int jobTypeId) {
    this.jobTypeId = jobTypeId;
  }

  public void setMarcometFee(double marcometFee) {
    this.marcometFee = marcometFee;
  }

  public void setPercentageOfShipment(double shipmentPercentage) {
    this.percentageOfShipment = shipmentPercentage;
  }

  public void setShipmentId(int shipmentId) {
    this.shipmentId = shipmentId;
  }

  public void setShippingPrice(double shippingPrice) {
    this.shippingPrice = shippingPrice;
  }

  public void setShippingType(String shippingType) {
    this.shippingType = shippingType;
  }

  public void setServiceTypeId(int serviceTypeId) {
    this.serviceTypeId = serviceTypeId;
  }

  public void setSiteHostMarkup(double siteHostMarkup) {
    this.siteHostMarkup = siteHostMarkup;
  }

  public void setVendorCompanyId(int vendorCompanyId) {
    this.vendorCompanyId = vendorCompanyId;
  }

  public void setVendorContactId(int vendorContactId) {
    this.vendorContactId = vendorContactId;
  }

  public void setVendorId(int vendorId) {
    this.vendorId = vendorId;
  }

  public void setPromoCode(String promoCode) {
    this.promoCode = promoCode;
  }

  public void setDiscount(double discount) {
    this.discount = discount;
  }

  public String getGridLabel() {
    return gridLabel;
  }

  public void setGridLabel(String gridLabel) {
    this.gridLabel = gridLabel;
  }

  public int getQuantity() {
    return quantity;
  }

  public void setQuantity(int quantity) {
    this.quantity = quantity;
  }

  public int getShipPricePolicy() {
    return shipPricePolicy;
  }

  public void setShipPricePolicy(int shipPricePolicy) {
    this.shipPricePolicy = shipPricePolicy;
  }

  public int getShipPriceSource() {
    return shipPriceSource;
  }

  public void setShipPriceSource(int shipPriceSource) {
    this.shipPriceSource = shipPriceSource;
  }

  public void setPreBuiltFile(String preBuiltFile) {
    this.preBuiltFile = preBuiltFile;
  }

  public String getPreBuiltFile() {
    return preBuiltFile;
  }

  public void setPreBuiltFileURL(String preBuiltFileURL) {
    this.preBuiltFileURL = preBuiltFileURL;
  }

  public String getPreBuiltFileURL() {
    return preBuiltFileURL;
  }

  public String getPreBuiltPDFFileURL() {
    return preBuiltPDFFileURL;
  }

  public void setPreBuiltPDFFileURL(String preBuiltPDFFileURL) {
    this.preBuiltPDFFileURL = preBuiltPDFFileURL;
  }

  public String getPreBuiltPDFFile() {
    return preBuiltPDFFile;
  }

  public void setPreBuiltPDFFile(String preBuiltPDFFile) {
    this.preBuiltPDFFile = preBuiltPDFFile;
  }

  public String getPriorJobId() {
    return priorJobId;
  }

  public void setPriorJobId(String priorJobId) {
    this.priorJobId = priorJobId;
  }

public double getSalesTax() {
	return salesTax;
}

public void setSalesTax(double salesTax) {
	this.salesTax = salesTax;
}

public String getProductId() {
	return productId;
}

public void setProductId(String productId) {
	this.productId = productId;
}
public void setProductId(int productId) {
	this.productId = productId+"";
}

public String getProductName() {
	return productName;
}

public void setProductName(String productName) {
	this.productName = productName;
}

public double getDiscountPercentage() {
	return discountPercentage;
}

public void setDiscountPercentage(double discountPercentage) {
	this.discountPercentage = discountPercentage;
}

public int getDiscountType() {
	return discountType;
}

public void setDiscountType(int discountType) {
	this.discountType = discountType;
}

public int getDiscountIncludesShipping() {
	return discountIncludesShipping;
}

public void setDiscountIncludesShipping(int discountIncludesShipping) {
	this.discountIncludesShipping = discountIncludesShipping;
}

public String getPromoProdMessage() {
	return promoProdMessage;
}

public void setPromoProdMessage(String promoProdMessage) {
	this.promoProdMessage = promoProdMessage;
}

}
