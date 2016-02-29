package com.marcomet.catalog;

public class JobSpecObject {

	private int specId, catSpecId, contactId, siteHostId;
	private String value;
	private double price, cost, escrowPercentage, mu, fee;
	private boolean proxyEnabled;

	public JobSpecObject(int specId, int catSpecId, String specValue, double cost, double escrowPercentage, int contactId, int siteHostId, boolean proxyEnabled) {
		this.specId = specId;
		this.catSpecId = catSpecId;
		this.value = specValue;
		this.cost = cost;
		this.escrowPercentage = escrowPercentage;
		this.contactId = contactId;
		this.siteHostId = siteHostId;
		this.proxyEnabled = proxyEnabled;
	}
	public int getCatSpecId() {
		return catSpecId;
	}
	public double getCost() {
		return cost;
	}
	public double getEscrowPercentage() {
		return escrowPercentage;
	}
	public double getFee() {
		return fee;
	}
	public double getMu() {
		return mu;
	}
	public double getPrice() throws Exception {
		try {
			price = CatalogCalculator.getPrice(cost, contactId, siteHostId, proxyEnabled, this);
		} catch (Exception ex) {
			throw new Exception("An error occured calculating the spec price " + ex.getMessage());
		}
		return price;
	}
	public int getSpecId() {
		return specId;
	}
	public String getValue() {
		return value;
	}
	public void setCatSpecId(int catSpecId) {
		this.catSpecId = catSpecId;
	}
	public void setCost(double cost) {
		this.cost = cost;
	}
	public void setFee(double fee) {
		this.fee = fee;
	}
	public void setMu(double mu) {
		this.mu = mu;
	}
	public void setPrice(double price) {
		this.price = price;
	}
	public void setSpecId(int specId) {
		this.specId = specId;
	}
	public void setValue(String specValue) {
		this.value = specValue;
	}
}
