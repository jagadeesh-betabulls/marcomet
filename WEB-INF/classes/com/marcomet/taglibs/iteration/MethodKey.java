package com.marcomet.taglibs.iteration;

public class MethodKey {

	String mMethodName;
	Class  mObjectClass;
	Class  mParamClass;

	int mHashCode;

	public MethodKey(String _methodName, Class  _objectClass, Class  _paramClass) {

		mMethodName     = _methodName;
		mObjectClass    = _objectClass;
		mParamClass     = _paramClass;

		mHashCode = _methodName.hashCode() + _objectClass.hashCode() + (null != _paramClass ? _paramClass.hashCode() : 0);
	}

	public boolean equals(Object obj) {

		if(obj instanceof MethodKey) {
			MethodKey other = (MethodKey)obj;
			if(mMethodName.equals(other.mMethodName) && mObjectClass.equals(other.mObjectClass)) {
				if(null == mParamClass) {
					if(null == other.mParamClass) {
						return true;
					}
				} else if(mParamClass.equals(other.mParamClass)) {
					return true;
				}
			}
		}

		return false;

	}

	public int hashCode() {
		return mHashCode;
	}

}
