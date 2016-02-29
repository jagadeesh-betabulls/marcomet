package com.marcomet.shipping;

import java.util.ArrayList;

public class UPSRatingServiceResponseContainer {
  public UPSRatingServiceResponseContainer() {
  }

  public class UPSResponse {
    public UPSResponse() {
    }

    public class TransactionReference {
      public String customerContext;
      public String xpciVersion;
    }

    public class Error {
      public String errorSeverity;
      public String errorCode;
      public String errorDescription;
      public String minimumRetrySeconds;
      public ArrayList errorDigests = new ArrayList();

      public class ErrorLocation {
        public String errorLocationElementName;
        public String errorLocationAttributeName;
      }
      public ArrayList errorLocations = new ArrayList();
    }
    //
    private TransactionReference transactionReference = new TransactionReference();
    private ArrayList errors = new ArrayList();
    private String responseStatusCode;
    private String responseStatusDescription;

    public TransactionReference getTransactionReference() {
      return transactionReference;
    }

    public void setTransactionReference(TransactionReference transactionReference) {
      this.transactionReference = transactionReference;
    }

    public ArrayList getErrors() {
      return errors;
    }

    public void setErrors(ArrayList errors) {
      this.errors = errors;
    }

    public String getResponseStatusCode() {
      return responseStatusCode;
    }

    public void setResponseStatusCode(String responseStatusCode) {
      this.responseStatusCode = responseStatusCode;
    }

    public String getResponseStatusDescription() {
      return responseStatusDescription;
    }

    public void setResponseStatusDescription(String responseStatusDescription) {
      this.responseStatusDescription = responseStatusDescription;
    }
  }

  public class UPSRatedShipment {
    public UPSRatedShipment() {
    }

    public class Service {
      public String code;
      public String description;
    }

    public class BillingWeight {
      public class UnitOfMeasurement {
        public String code;
        public String description;
      }
      public UnitOfMeasurement unitOfMeasurement = new UnitOfMeasurement();
      public String weight;
    }

    public class TransportationCharges {
      public String currencyCode;
      public String monetaryValue;
    }

    public class ServiceOptionsCharges {
      public String currencyCode;
      public String monetaryValue;
    }

    public class HandlingChargeAmount {
      public String currencyCode;
      public String monetaryValue;
    }

    public class TotalCharges {
      public String currencyCode;
      public String monetaryValue;
    }

    public class NegotiatedRates {
      public class NetSummaryCharges {
        public class GrandTotal {
          public String currencyCode;
          public String monetaryValue;
        }
        public GrandTotal grandTotal = new GrandTotal();
      }
      public NetSummaryCharges netSummaryCharges = new NetSummaryCharges();
    }

    public class RatedPackage {
      public RatedPackage() {
      }

      public class RPTransportationCharges {
        public String currencyCode;
        public String monetaryValue;
      }

      public class RPServiceOptionsCharges {
        public String currencyCode;
        public String monetaryValue;
      }

      public class RPTotalCharges {
        public String currencyCode;
        public String monetaryValue;
      }

      public class RPBillingWeight {
        public class UnitOfMeasurement {
          public String code;
          public String description;
        }
        public UnitOfMeasurement unitOfMeasurement = new UnitOfMeasurement();
        public String weight;
      }
      private RPTransportationCharges transportationCharges = new RPTransportationCharges();
      private RPServiceOptionsCharges serviceOptionsCharges = new RPServiceOptionsCharges();
      private RPTotalCharges totalCharges = new RPTotalCharges();
      private RPBillingWeight billingWeight = new RPBillingWeight();
      private String weight;

      public RPBillingWeight getBillingWeight() {
        return billingWeight;
      }

      public void setBillingWeight(RPBillingWeight billingWeight) {
        this.billingWeight = billingWeight;
      }

      public RPServiceOptionsCharges getServiceOptionsCharges() {
        return serviceOptionsCharges;
      }

      public void setServiceOptionsCharges(RPServiceOptionsCharges serviceOptionsCharges) {
        this.serviceOptionsCharges = serviceOptionsCharges;
      }

      public RPTotalCharges getTotalCharges() {
        return totalCharges;
      }

      public void setTotalCharges(RPTotalCharges totalCharges) {
        this.totalCharges = totalCharges;
      }

      public RPTransportationCharges getTransportationCharges() {
        return transportationCharges;
      }

      public void setTransportationCharges(RPTransportationCharges transportationCharges) {
        this.transportationCharges = transportationCharges;
      }

      public String getWeight() {
        return weight;
      }

      public void setWeight(String weight) {
        this.weight = weight;
      }
    }
    private Service service = new Service();
    private BillingWeight billingWeight = new BillingWeight();
    private TransportationCharges transportationCharges = new TransportationCharges();
    private ServiceOptionsCharges serviceOptionsCharges = new ServiceOptionsCharges();
    private HandlingChargeAmount handlingChargeAmount = new HandlingChargeAmount();
    private TotalCharges totalCharges = new TotalCharges();
    private NegotiatedRates negotiatedRates = new NegotiatedRates();
    private String ratedShipmentWarning;
    private String guaranteedDaysToDelivery;
    private String scheduledDeliveryTime;
    private ArrayList ratedPackages = new ArrayList();

    public NegotiatedRates getNegotiatedRates() {
      return negotiatedRates;
    }

    public void setNegotiatedRates(NegotiatedRates negotiatedRates) {
      this.negotiatedRates = negotiatedRates;
    }

    public BillingWeight getBillingWeight() {
      return billingWeight;
    }

    public void setBillingWeight(BillingWeight billingWeight) {
      this.billingWeight = billingWeight;
    }

    public String getGuaranteedDaysToDelivery() {
      return guaranteedDaysToDelivery;
    }

    public void setGuaranteedDaysToDelivery(String guaranteedDaysToDelivery) {
      this.guaranteedDaysToDelivery = guaranteedDaysToDelivery;
    }

    public HandlingChargeAmount getHandlingChargeAmount() {
      return handlingChargeAmount;
    }

    public void setHandlingChargeAmount(HandlingChargeAmount handlingChargeAmount) {
      this.handlingChargeAmount = handlingChargeAmount;
    }

    public ArrayList getRatedPackages() {
      return ratedPackages;
    }

    public void setRatedPackages(ArrayList ratedPackages) {
      this.ratedPackages = ratedPackages;
    }

    public String getRatedShipmentWarning() {
      return ratedShipmentWarning;
    }

    public void setRatedShipmentWarning(String ratedShipmentWarning) {
      this.ratedShipmentWarning = ratedShipmentWarning;
    }

    public String getScheduledDeliveryTime() {
      return scheduledDeliveryTime;
    }

    public void setScheduledDeliveryTime(String scheduledDeliveryTime) {
      this.scheduledDeliveryTime = scheduledDeliveryTime;
    }

    public Service getService() {
      return service;
    }

    public void setService(Service service) {
      this.service = service;
    }

    public ServiceOptionsCharges getServiceOptionsCharges() {
      return serviceOptionsCharges;
    }

    public void setServiceOptionsCharges(ServiceOptionsCharges serviceOptionsCharges) {
      this.serviceOptionsCharges = serviceOptionsCharges;
    }

    public TotalCharges getTotalCharges() {
      return totalCharges;
    }

    public void setTotalCharges(TotalCharges totalCharges) {
      this.totalCharges = totalCharges;
    }

    public TransportationCharges getTransportationCharges() {
      return transportationCharges;
    }

    public void setTransportationCharges(TransportationCharges transportationCharges) {
      this.transportationCharges = transportationCharges;
    }
  }
  //
  private UPSResponse upsResponse = new UPSResponse();
  private ArrayList upsRatedShipments = new ArrayList();

  public ArrayList getUPSRatedShipments() {
    return upsRatedShipments;
  }

  public void setUPSRatedShipments(ArrayList upsRatedShipments) {
    this.upsRatedShipments = upsRatedShipments;
  }

  public UPSResponse getUPSResponse() {
    return upsResponse;
  }

  public void setUPSResponse(UPSResponse upsResponse) {
    this.upsResponse = upsResponse;
  }
}
