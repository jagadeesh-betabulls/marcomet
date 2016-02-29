package com.marcomet.environment;

/**********************************************************************
Description:	This Class will hold and organize site specific information
	
**********************************************************************/

public class SiteHostSettings{

	private String siteHostId;
	private String siteHostContactId;
	private String siteHostCompanyId;
	private String innerFrameSetHeight;
	private String outerFrameSetHeight;
	private String domainName;	
	private String siteHostRoot;
	private double marcometGlobalFee;
	private double siteHostGlobalMarkup;
	private double defaultCreditLimit;
	private String cCommerce;
	private int buyerMinderFilter;
	private String allowGuestLogin;
	private String guestEID;	
	private int validateSiteNumberFlag;
	private int useSiteNumbersFlag;
	private String siteClientRefCode;
	private String siteMcClient;
	private String usePropertyProductFilter;
	private String useCC;
	private String useACH;
	private String useOnAccount;
	private String usePrepayByCheck;
	private String allowDeferredACH;
	private String useFullShipCharge;
	private String hideShippingOptions;
	private String shippingOptionsDefault;
	private String requireSiteValidation;
	private String useWarehouseHandling;
	private String siteName;
	private String siteType;
	private String siteFieldLabel1;
	private String siteFieldLabel2;
	private String siteFieldLabel3;
	private String showTaxID;
	private String siteTarget;
	
	public final int getBuyerMinderFilter(){
		return buyerMinderFilter;
	}
	public final String getCCommerce(){
		return cCommerce;
	}
	public final String getDomainName(){
		return domainName;
	}
	public final String getInnerFrameSetHeight() {
		return innerFrameSetHeight;
	}
	public final String getOuterFrameSetHeight(){
		return outerFrameSetHeight;
	}
	public final String getSiteHostCompanyId(){
		return siteHostCompanyId;
	}
	public final String getSiteHostContactId(){
		return siteHostContactId;
	}
	public final double getSiteHostGlobalMarkup(){
		return siteHostGlobalMarkup;
	}
	public final String getSiteHostId(){
		return siteHostId;
	}
	public final String getSiteHostRoot(){
		return siteHostRoot;
	}
	public final int getValidateSiteNumberFlag() {
		return validateSiteNumberFlag;
	}
	public final int getUseSiteNumbersFlag() {
		return useSiteNumbersFlag;
	}
	public final String getSiteClientRefCode(){
		return siteClientRefCode;
	}
	public final String getSiteMcClient(){
		return siteMcClient;
	}
	
	
	
	public final void setBuyerMinderFilter(int temp){
		buyerMinderFilter = temp;
	}
	public final void setCCommerce(String temp){
		cCommerce = temp;
	}
	public final void setDomainName(String temp){
		domainName = temp;
	}
	public final void setInnerFrameSetHeight(String temp){
		innerFrameSetHeight = temp;
	}
	public final double setMarcometGlobalFee(){
		return marcometGlobalFee;
	}
	public final void setMarcometGlobalFee(double temp){
		marcometGlobalFee = temp;
	}
	public final void setOuterFrameSetHeight(String temp){
		outerFrameSetHeight = temp;
	}
	public final void setSiteHostCompanyId(String temp){
		siteHostCompanyId = temp;
	}
	public final void setSiteHostContactId(String temp){
		siteHostContactId = temp;
	}
	public final void setSiteHostGlobalMarkup(double temp){
		siteHostGlobalMarkup = temp;
	}
	public final void setSiteHostId(String temp){
		siteHostId = temp;	
	}
	public final void setSiteHostRoot(String temp){
		siteHostRoot = temp;
	}
	public final void setValidateSiteNumberFlag(int temp) {
		validateSiteNumberFlag = temp;
	}
	public final void setUseSiteNumbersFlag(int temp) {
		useSiteNumbersFlag = temp;
	}
	public final void setSiteClientRefCode(String temp){
		siteClientRefCode = temp;
	}
	public final void setSiteMcClient(String temp){
		siteMcClient = temp;
	}
	
	public String getGuestEID() {
		return guestEID;
	}

	public void setGuestEID(String guestEID) {
		this.guestEID = guestEID;
	}
	public String getAllowGuestLogin() {
		return allowGuestLogin;
	}
	public void setAllowGuestLogin(String allowGuestLogin) {
		this.allowGuestLogin = allowGuestLogin;
	}
	public String getUsePropertyProductFilter() {
		return usePropertyProductFilter;
	}
	public void setUsePropertyProductFilter(String usePropertyProductFilter) {
		this.usePropertyProductFilter = usePropertyProductFilter;
	}
	public String getUseCC() {
		return useCC;
	}
	public void setUseCC(String useCC) {
		this.useCC = useCC;
	}
	public String getUseACH() {
		return useACH;
	}
	public void setUseACH(String useACH) {
		this.useACH = useACH;
	}
	public String getUseOnAccount() {
		return useOnAccount;
	}
	public void setUseOnAccount(String useOnAccount) {
		this.useOnAccount = useOnAccount;
	}
	public String getUsePrepayByCheck() {
		return usePrepayByCheck;
	}
	public void setUsePrepayByCheck(String usePrepayByCheck) {
		this.usePrepayByCheck = usePrepayByCheck;
	}
	public String getAllowDeferredACH() {
		return allowDeferredACH;
	}
	public void setAllowDeferredACH(String allowDeferredACH) {
		this.allowDeferredACH = allowDeferredACH;
	}
	public String getUseFullShipCharge() {
		return useFullShipCharge;
	}
	public void setUseFullShipCharge(String useFullShipCharge) {
		this.useFullShipCharge = useFullShipCharge;
	}
	public String getHideShippingOptions() {
		return hideShippingOptions;
	}
	public void setHideShippingOptions(String hideShippingOptions) {
		this.hideShippingOptions = hideShippingOptions;
	}
	public String getShippingOptionsDefault() {
		return shippingOptionsDefault;
	}
	public void setShippingOptionsDefault(String shippingOptionsDefault) {
		this.shippingOptionsDefault = shippingOptionsDefault;
	}
	public String getRequireSiteValidation() {
		return requireSiteValidation;
	}
	public void setRequireSiteValidation(String requireSiteValidation) {
		this.requireSiteValidation = requireSiteValidation;
	}
	public String getUseWarehouseHandling() {
		return useWarehouseHandling;
	}
	public void setUseWarehouseHandling(String useWarehouseHandling) {
		this.useWarehouseHandling = useWarehouseHandling;
	}
	public double getMarcometGlobalFee() {
		return marcometGlobalFee;
	}
	public String getSiteName() {
		return siteName;
	}
	public void setSiteName(String siteName) {
		this.siteName = siteName;
	}
	public String getSiteType() {
		return siteType;
	}
	public void setSiteType(String siteType) {
		this.siteType = siteType;
	}
	public String getSiteFieldLabel1() {
		return siteFieldLabel1;
	}
	public void setSiteFieldLabel1(String siteFieldLabel1) {
		this.siteFieldLabel1 = siteFieldLabel1;
	}
	public String getSiteFieldLabel2() {
		return siteFieldLabel2;
	}
	public void setSiteFieldLabel2(String siteFieldLabel2) {
		this.siteFieldLabel2 = siteFieldLabel2;
	}
	public String getSiteFieldLabel3() {
		return siteFieldLabel3;
	}
	public void setSiteFieldLabel3(String siteFieldLabel3) {
		this.siteFieldLabel3 = siteFieldLabel3;
	}
	public double getDefaultCreditLimit() {
		return defaultCreditLimit;
	}
	public void setDefaultCreditLimit(double defaultCreditLimit) {
		this.defaultCreditLimit = defaultCreditLimit;
	}
	public String getShowTaxID() {
		return showTaxID;
	}
	public void setShowTaxID(String showTaxID) {
		this.showTaxID = showTaxID;
	}
	public String getSiteTarget() {
		return siteTarget;
	}
	public void setSiteTarget(String siteTarget) {
		this.siteTarget = siteTarget;
	}

}
