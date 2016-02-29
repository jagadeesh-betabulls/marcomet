package com.marcomet.catalog;

/**********************************************************************
Description:	This class contains all the meta data for orders during
the order process 

History:
Date		Author			Description
----		------			-----------
6/11/2001	Thomas Dietrich	Created
7/20/2001	Brian Murphy	Retooled for new catalog process 

 **********************************************************************/
import java.util.*;

public class ShoppingCart {

  private Vector projects,  shipments;
  private Hashtable jobSpecs;
  private int siteHostContactId;
  private int shippingLocationId;

  public ShoppingCart() {
    projects = new Vector();
    shipments = new Vector();
    jobSpecs = new Hashtable();
  }
  // JobSpecs hashtable manipulation methods

  public void addJobSpec(JobSpecObject jso) {
    if (jobSpecs == null) {
      jobSpecs = new Hashtable();
    }
    int specId = jso.getSpecId();
    jobSpecs.put(new Integer(specId).toString(), jso);
  }
  // Projects vector manipulation methods

  public void addProject(ProjectObject po) {
    projects.addElement(po);
  }

  public void addShipment(ShipmentObject so) {
    if (shipments == null) {
      shipments = new Vector();
    }
    shipments.addElement(so);
  }

  public ProjectObject getCurrentProject() {
    if (projects.size() > 0) {
      return (ProjectObject) projects.lastElement();
    }
    else {
      return null;
    }
  }

  public ShipmentObject getCurrentShipment() {
    if (shipments.size() > 0) {
      return (ShipmentObject) shipments.lastElement();
    }
    else {
      return null;
    }
  }

  //get a job by specific id
  public JobObject getJob(int id) {
    //loop through projects
    for (Enumeration e0 = projects.elements(); e0.hasMoreElements();) {
      Vector jobs = ((ProjectObject) e0.nextElement()).getJobs();
      //loop through jobs
      for (Enumeration e1 = jobs.elements(); e1.hasMoreElements();) {
        JobObject jo = (JobObject) e1.nextElement();
        //if match return job object
        if (jo.getId() == id) {
          return jo;
        }
      }
    }

    return null;
  }

  public JobSpecObject getJobSpec(int specId) {
    return (JobSpecObject) jobSpecs.get((new Integer(specId)).toString());
  }

  public Hashtable getJobSpecs() {
    return (Hashtable) jobSpecs.clone();
  }

  public double getOrderEscrowTotal() {
    double orderEscrowTotal = 0;
    for (Enumeration e0 = projects.elements(); e0.hasMoreElements();) {
      Vector jobs = ((ProjectObject) e0.nextElement()).getJobs();
      for (Enumeration e1 = jobs.elements(); e1.hasMoreElements();) {
        double jobEscrowAmount = ((JobObject) e1.nextElement()).getEscrowDollarAmount();
        orderEscrowTotal = orderEscrowTotal + jobEscrowAmount;
      }
    }
    return orderEscrowTotal;
  }
  // Methods to get at the important dollar amounts

  public double getOrderPrice() {
    double orderPrice = 0;
    for (Enumeration e0 = projects.elements(); e0.hasMoreElements();) {
      Vector jobs = ((ProjectObject) e0.nextElement()).getJobs();
      for (Enumeration e1 = jobs.elements(); e1.hasMoreElements();) {
        double jobPrice = ((JobObject) e1.nextElement()).getPrice();
        orderPrice = orderPrice + jobPrice;
      }
    }
    return orderPrice;
  }

  public double getShippingPrice() {
    double shippingPrice = 0;
    for (Enumeration e0 = projects.elements(); e0.hasMoreElements();) {
      Vector jobs = ((ProjectObject) e0.nextElement()).getJobs();
      for (Enumeration e1 = jobs.elements(); e1.hasMoreElements();) {
        double jobPrice = ((JobObject) e1.nextElement()).getShippingPrice();
        shippingPrice = shippingPrice + jobPrice;
      }
    }
    return shippingPrice;
  }

  public double getDiscount() {
    double discount = 0;
    for (Enumeration e0 = projects.elements(); e0.hasMoreElements();) {
      Vector jobs = ((ProjectObject) e0.nextElement()).getJobs();
      for (Enumeration e1 = jobs.elements(); e1.hasMoreElements();) {
        double jobDiscount = ((JobObject) e1.nextElement()).getDiscount();
        discount = discount + jobDiscount;
      }
    }
    return discount;
  }

  public Vector getProjects() {
    return (Vector) projects.clone();
  }

  public ShipmentObject getShipment(int id) {
    for (int x = 0; x < shipments.size(); x++) {
      ShipmentObject tempShipment = (ShipmentObject) shipments.elementAt(x);
      if (tempShipment.getId() == id) {
        return tempShipment;
      }
    }
    return null;
  }

  public Vector getShipments() {
    return (Vector) shipments.clone();
  }

  public int getShipmentSize() {
    return shipments.size();
  }

  public int getSiteHostContactId() {
    return siteHostContactId;
  }

  public void removeJobSpec(int specId) {
    jobSpecs.remove(new Integer(specId).toString());
  }

  public void removeProject(int index) {
    projects.removeElementAt(index);
  }

  public void removeShipment(int index) {
    shipments.removeElementAt(index);
  }

  public void setSiteHostContactId(int siteHostContactId) {
    this.siteHostContactId = siteHostContactId;
  }

public int getShippingLocationId() {
	return shippingLocationId;
}

public void setShippingLocationId(int shippingLocationId) {
	this.shippingLocationId = shippingLocationId;
}
}
