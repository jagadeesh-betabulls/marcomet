package com.marcomet.catalog;

import com.marcomet.tools.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class RemoveJobServlet extends HttpServlet {

  public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

    ShoppingCart cart = (ShoppingCart) request.getSession().getAttribute("shoppingCart");
    boolean jobRemoved = false;

    if (cart != null) {
      Vector shipments = cart.getShipments();
      for (int i = 0; i < shipments.size(); i++) {
        ShipmentObject so = (ShipmentObject) shipments.elementAt(i);
        Vector jobs = so.getJobs();
        for (int j = 0; j < jobs.size(); j++) {
          JobObject jo = (JobObject) jobs.elementAt(j);
          if (jo.getId() == Integer.parseInt((String) request.getParameter("jobId"))) {
            so.removeJob(j);
            jobRemoved = true;
            break;
          }
        }
        if (so.getJobs().size() == 0) {
          cart.removeShipment(i);
        }
        if (jobRemoved) {
          break;
        }
      }
    }

    ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
    rpcs.printNextPage(this, request, response);
  }
}
