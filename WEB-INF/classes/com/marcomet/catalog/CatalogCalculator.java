package com.marcomet.catalog;

/**********************************************************************
Description:	This class contains the necessary arithmetic for the catalog system.

History:
	Date		Author			Description
	----		------			-----------
	8/10/01		Brian Murphy	Created
	
**********************************************************************/

import java.sql.*;
import java.util.*;
import java.text.DecimalFormat;
import com.marcomet.jdbc.DBConnect;


public class CatalogCalculator {

	public static double getPrice(double cost, int contactId, int siteHostId, boolean proxyEnabled) throws Exception {

		double price = 0;

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();

			double mu = 0; double fee = 0;
			double siteHostMarkup = 0; double marcometMarkup = 0;

			String query0 = "SELECT marcomet_global_fee, site_host_global_markup FROM site_hosts WHERE id = " + siteHostId;
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);
			if (rs0.next()) {
				siteHostMarkup = rs0.getDouble("site_host_global_markup");
				marcometMarkup = rs0.getDouble("marcomet_global_fee");

				if (!proxyEnabled) {
					String hostQuery = "SELECT cont.id FROM site_hosts sh, companies comp, contacts cont WHERE sh.company_id = comp.id AND comp.id = cont.companyid AND sh.id = " + siteHostId;
					Statement st1 = conn.createStatement();
					ResultSet rs1 = st1.executeQuery(hostQuery);
					int siteHostContactId = -1;
					if (rs1.next()) {
						siteHostContactId = rs1.getInt("id");
						if (siteHostContactId == contactId) siteHostMarkup = 0;
					}
				}
					
				mu = cost * siteHostMarkup;
				fee = (cost + (cost * siteHostMarkup)) * ((1 / (1 - marcometMarkup)) - 1);				
			}

			price = cost + mu + fee;

			DecimalFormat precisionTwo = new DecimalFormat("0.##");
			String formattedPrice = precisionTwo.format(price);
			price = Double.parseDouble(formattedPrice);
  	
		} catch (SQLException ex) {
			throw new Exception("getPrice sql error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return price;

	}
	public static double getPrice(double cost, int contactId, int siteHostId, boolean proxyEnabled, JobSpecObject jso) throws Exception {

		double price = 0;
	
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			double mu = 0; double fee = 0;
			double siteHostMarkup = 0; double marcometMarkup = 0;

			String query0 = "SELECT marcomet_global_fee, site_host_global_markup FROM site_hosts WHERE id = " + siteHostId;
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);
			if (rs0.next()) {
				siteHostMarkup = rs0.getDouble("site_host_global_markup");
				marcometMarkup = rs0.getDouble("marcomet_global_fee");

				if (!proxyEnabled) {
					String hostQuery = "SELECT cont.id FROM site_hosts sh, companies comp, contacts cont WHERE sh.company_id = comp.id AND comp.id = cont.companyid AND sh.id = " + siteHostId;
					Statement st1 = conn.createStatement();
					ResultSet rs1 = st1.executeQuery(hostQuery);
					int siteHostContactId = -1;
					if (rs1.next()) {
						siteHostContactId = rs1.getInt("id");
						if (siteHostContactId == contactId) siteHostMarkup = 0;
					}
				}

				mu = cost * siteHostMarkup;
				fee = (cost + (cost * siteHostMarkup)) * ((1 / (1 - marcometMarkup)) - 1);				
			}

			price = cost + mu + fee;
			jso.setMu(mu);
			jso.setFee(fee);

			DecimalFormat precisionTwo = new DecimalFormat("0.##");
			String formattedPrice = precisionTwo.format(price);
			price = Double.parseDouble(formattedPrice);
  	
		} catch (SQLException ex) {
			throw new Exception("getPrice sql error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return price;
	}
	
	public static double getPriceForGrid(double cost, double siteHostMarkup, double marcometMarkup) throws Exception {

		double mu = cost * siteHostMarkup;
		double fee = (cost + (cost * siteHostMarkup)) * ((1 / (1 - marcometMarkup)) - 1);				
		double price = cost + mu + fee;

		DecimalFormat precisionTwo = new DecimalFormat("0.##");
		String formattedPrice = precisionTwo.format(price);
		price = Double.parseDouble(formattedPrice);

		return price;

	}
}
