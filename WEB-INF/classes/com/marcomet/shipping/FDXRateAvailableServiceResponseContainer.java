package com.marcomet.shipping;

import java.util.ArrayList;

public class FDXRateAvailableServiceResponseContainer {
  public FDXRateAvailableServiceResponseContainer() {
  }

  public class FDXReplyHeader {
    public FDXReplyHeader() {
    }

    public class Error {
      public String code;
      public String message;
    }

    public class Entry {
      public Entry() {
      }

      public class EstimatedCharges {
        public EstimatedCharges() {
        }

        public class DiscountedCharges {
          public String baseCharge;
          public String totalDiscount;
          public String totalSurcharge;
          public String netCharge;
          public String earnedDiscount;
        }
        //
        public String dimWeightUsed;
        public String billedWeight;
        public DiscountedCharges discountedCharges = new DiscountedCharges();

        public String getBilledWeight() {
          return billedWeight;
        }

        public void setBilledWeight(String billedWeight) {
          this.billedWeight = billedWeight;
        }

        public String getDimWeightUsed() {
          return dimWeightUsed;
        }

        public void setDimWeightUsed(String dimWeightUsed) {
          this.dimWeightUsed = dimWeightUsed;
        }

        public DiscountedCharges getDiscountedCharges() {
          return discountedCharges;
        }

        public void setDiscountedCharges(DiscountedCharges discountedCharges) {
          this.discountedCharges = discountedCharges;
        }
      }
      //
      private String service;
      private String packaging;
      private EstimatedCharges estimatedCharges = new EstimatedCharges();
      private String signatureOption;

      public EstimatedCharges getEstimatedCharges() {
        return estimatedCharges;
      }

      public void setEstimatedCharges(EstimatedCharges estimatedCharges) {
        this.estimatedCharges = estimatedCharges;
      }

      public String getPackaging() {
        return packaging;
      }

      public void setPackaging(String packaging) {
        this.packaging = packaging;
      }

      public String getService() {
        return service;
      }

      public void setService(String service) {
        this.service = service;
      }

      public String getSignatureOption() {
        return signatureOption;
      }

      public void setSignatureOption(String signatureOption) {
        this.signatureOption = signatureOption;
      }
    }
    //
    private Error errors = new Error();
    private ArrayList entries = new ArrayList();

    public ArrayList getEntries() {
      return entries;
    }

    public void setEntries(ArrayList entries) {
      this.entries = entries;
    }

    public Error getErrors() {
      return errors;
    }

    public void setErrors(Error errors) {
      this.errors = errors;
    }
  }
  //
  private FDXReplyHeader fdxReplyHeader = new FDXReplyHeader();

  public FDXReplyHeader getFdxReplyHeader() {
    return fdxReplyHeader;
  }

  public void setFdxReplyHeader(FDXReplyHeader fdxReplyHeader) {
    this.fdxReplyHeader = fdxReplyHeader;
  }
}
