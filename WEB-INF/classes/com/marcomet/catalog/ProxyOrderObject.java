package com.marcomet.catalog;

public class ProxyOrderObject {

	boolean proxyEnabled;
	int proxyContactId;
	int proxyCompanyId;

	public ProxyOrderObject(boolean proxyEnabled, int proxyContactId, int proxyCompanyId) {
		this.proxyEnabled = proxyEnabled;
		this.proxyContactId = proxyContactId;
		this.proxyCompanyId = proxyCompanyId;
	}
	public int getProxyCompanyId() {
		return proxyCompanyId;
	}
	public int getProxyContactId() {
		return proxyContactId;
	}
	public boolean isProxyEnabled() {
		return proxyEnabled;
	}
	public void setProxyEnabled(boolean proxyEnabled) {
		this.proxyEnabled = proxyEnabled;
	}
}
