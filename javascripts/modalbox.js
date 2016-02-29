var ajaxRequest;

if(!window.AjaxModalBox){
  var AjaxModalBox = new Object();
}

AjaxModalBox.Methods = {
  initialized: false,

  options: {
    title: "AjaxModalBox Window", //default window title
    width: 500,                   //default window width
    height: 200,                  //default window height
    method: "get",                //default ajax method
    params: {},                   //parameters for the ajax request
    servletUrl: "",               //requested Url
    showClose: true               //show 'CLOSE' to close modal window
  },

  _options: new Object,

  setOptions: function(options){
    Object.extend(this.options, options || {});
  },

  init: function(options){
    Object.extend(this._options, this.options);
    this.setOptions(options);

    this.mbOverlay = new Element("div", {id:'mb_overlay', opacity:'0'});

    this.mbWindow = new Element("div", {id:'mb_window', style:'display: none'}).update(
      this.mbFrame = new Element("div", {id:'mb_frame'}).update(
        this.mbHeader = new Element("div", {id:'mb_header'}).update(
          this.mbCaption = new Element("div", {id:'mb_caption'})
        )
      )
    );

    this.mbClose = new Element("a", {id:'mb_close', href: '#'}).update("<span>CLOSE</span>");
    if(this.options.showClose){
      this.mbHeader.insert({'bottom':this.mbClose});
    }

    this.mbContent = new Element("div", {id:'mb_content'});
    this.mbFrame.insert({'bottom':this.mbContent});

    this.mbBody = $(document.body);
    this.mbBody.insert({'top':this.mbWindow});
    this.mbBody.insert({'top':this.mbOverlay});

    this.initScrollX = window.pageXOffset || document.body.scrollLeft || document.documentElement.scrollLeft;
		this.initScrollY = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop;

    this.hideObserver = this.hide.bindAsEventListener(this);
		this.kbdObserver = this.kbHandler.bindAsEventListener(this);
    //this.initObservers();
    $(this.mbClose).observe("click", this.hideObserver);

    this.initialized = true;
  },

  open: function(content, options){
    if(this.mbWindow != undefined && this.mbWindow.style.display != 'none'){
      AjaxModalBox.close(this.options);
    }

    if(!this.initialized){
      this.init(options);
    }

    this.content = content;
    this.setOptions(options);

    if(this.options.title){
      $(this.mbCaption).update(this.options.title);
    } else{
      $(this.mbHeader).hide();
      $(this.mbCaption).hide();
    }

    if(Prototype.Browser.IE && !navigator.appVersion.match(/\b7.0\b/)) {
      window.scrollTo(0,0);
      this.prepareIE("100%", "hidden");
    }
    $(this.mbWindow).setStyle({width: this.options.width + "px", height: this.options.height + "px"});
    $(this.mbWindow).setStyle({left: Math.round((Element.getWidth(document.body) - Element.getWidth(this.mbWindow)) / 2 ) + "px"});
    $(this.mbOverlay).setStyle({opacity: .65});
    $(this.mbWindow).show();
    $(this.mbWindow).setStyle({left: Math.round((Element.getWidth(document.body) - Element.getWidth(this.mbWindow)) / 2 ) + "px"});
    this.loadContent();
    this.setWidthAndPosition = this.setWidthAndPosition.bindAsEventListener(this);
    Event.observe(window, "resize", this.setWidthAndPosition);
    this.event("onShow");
  },

  close: function(options){
    if(this.initialized || document.getElementById("mb_window") != undefined){
      if(options && typeof options.element != 'function'){
        Object.extend(this.options, options);
      }
      this.event("beforeHide");
      $(this.mbWindow).hide();

      //this.removeObservers();
      $(this.mbClose).stopObserving("click", this.hideObserver);
      Event.stopObserving(window, "resize", this.setWidthAndPosition );

      $(this.mbOverlay).setStyle({opacity: ''});
      $(this.mbOverlay).hide();
      //$(this.mbOverlay).remove();
      //$(this.mbWindow).remove();

      if(Prototype.Browser.IE && !navigator.appVersion.match(/\b7.0\b/)) {
        this.prepareIE("", "");
        window.scrollTo(this.initScrollX, this.initScrollY);
      }

      if(typeof this.content == 'object') {
        if(this.content.id && this.content.id.match(/mbB_/)) {
          this.content.id = this.content.id.replace(/mb_/, "");
        }
        this.content.select('*[id]').each(function(el){ el.id = el.id.replace(/mb_/, ""); });
      }

      this.initialized = false;
      this.event("afterHide");
      this.setOptions(this._options);
      $(this.mbContent).setStyle({overflow: '', height: ''});
    } else throw("AjaxModalBox is not initialized.");
  },

  loadContent: function(){
    if(this.event("beforeLoad") != false) {
      if(typeof this.content == 'string'){
        var htmlRegExp = new RegExp(/<\/?[^>]+>/gi);
        if(htmlRegExp.test(this.content)){
          $(this.mbContent).hide().update("");
          var stripContent = this.content.stripScripts();
          setTimeout(function(){
            this.mbContent.update(stripContent);
          }.bind(this),1);
          this.putContent(function(){
            this.content.extractScripts().map(function(script){
              return eval(script.replace("<!--", "").replace("// -->", ""));
            }.bind(window));
          }.bind(this));
        }
      } else if(typeof this.content == 'object'){
        $(this.mbContent).hide().update("");
        var htmlObject = this.content.cloneNode(true);
        if(this.content.id){
          this.content.id = "mb_" + this.content.id;
        }
        $(this.content).select('*[id').each(function(el){el.id = "mb_" + el.id;});
        this.mbContent.appendChild(htmlObject);
        this.mbContent.down().show();
        if(Prototype.Browser.IE){
          $$("#mb_content select").invoke('setStyle', {'visibility': ''});
        }
        this.putContent();
      } else {
        AjaxModalBox.close();
        throw('AjaxModalBox Parameters Error: Please specify correct HTML element (plain HTML or object)');
      }
    }
  },

  putContent: function(callback){
		if(this.options.height == this._options.height) {
			setTimeout(function() {
				AjaxModalBox.resize(0, $(this.mbContent).getHeight() - $(this.mbWindow).getHeight() + $(this.mbHeader).getHeight(), {
					afterResize: function(){
						this.mbContent.show().makePositioned();
						setTimeout(function(){
							if(callback != undefined){
								callback();
                this.event("afterLoad");
              }
						}.bind(this),1);
					}.bind(this)
				});
			}.bind(this), 1);
		} else {
			$(this.mbWindow).setStyle({width: this.options.width + "px", height: this.options.height + "px"});
			this.mbContent.setStyle({overflow: 'auto', height: $(this.mbWindow).getHeight() - $(this.mbHeader).getHeight() - 13 + 'px'});
			this.mbContent.show();
			setTimeout(function(){
				if(callback != undefined)
					callback();
          this.event("afterLoad");
			}.bind(this),1);
		}
    this.mbContent.setStyle({display: ''});
  },

  hide: function(event) {
		event.stop();
		if(event.element().id == 'mb_overlay'){
      return false;
    }
		this.close();
	},

  kbHandler: function(event) {
		var node = event.element();
		switch(event.keyCode) {
//			case Event.KEY_TAB:
//				event.stop();
//
//				/* Switching currFocused to the element which was focused by mouse instead of TAB-key. Fix for #134 */
//				if(node != this.focusableElements[this.currFocused])
//					this.currFocused = this.focusableElements.toArray().indexOf(node);
//
//				if(!event.shiftKey) { //Focusing in direct order
//					if(this.currFocused == this.focusableElements.length - 1) {
//						this.focusableElements.first().focus();
//						this.currFocused = 0;
//					} else {
//						this.currFocused++;
//						this.focusableElements[this.currFocused].focus();
//					}
//				} else { // Shift key is pressed. Focusing in reverse order
//					if(this.currFocused == 0) {
//						this.focusableElements.last().focus();
//						this.currFocused = this.focusableElements.length - 1;
//					} else {
//						this.currFocused--;
//						this.focusableElements[this.currFocused].focus();
//					}
//				}
//				break;
			case Event.KEY_ESC:
				if(this.active) this.hide(event);
				break;
			case 32:
				this.preventScroll(event);
				break;
			case 0: // For Gecko browsers compatibility
				if(event.which == 32) this.preventScroll(event);
				break;
			case Event.KEY_UP:
			case Event.KEY_DOWN:
			case Event.KEY_PAGEDOWN:
			case Event.KEY_PAGEUP:
			case Event.KEY_HOME:
			case Event.KEY_END:
				// Safari operates in slightly different way. This realization is still buggy in Safari.
				if(Prototype.Browser.WebKit && !["textarea", "select"].include(node.tagName.toLowerCase()))
					event.stop();
				else if( (node.tagName.toLowerCase() == "input" && ["submit", "button"].include(node.type)) || (node.tagName.toLowerCase() == "a") )
					event.stop();
				break;
		}
	},

  preventScroll: function(event) { // Disabling scrolling by "space" key
		if(!["input", "textarea", "select", "button"].include(event.element().tagName.toLowerCase()))
			event.stop();
	},

  setWidthAndPosition: function () {
		$(this.mbWindow).setStyle({width: this.options.width + "px"});
		$(this.mbWindow).setStyle({left: Math.round((Element.getWidth(document.body) - Element.getWidth(this.mbWindow)) / 2 ) + "px"});
	},

  resize: function(byWidth, byHeight, options) {
		var wHeight = $(this.mbWindow).getHeight();
		var wWidth = $(this.mbWindow).getWidth();
		var hHeight = $(this.mbHeader).getHeight();
		var cHeight = $(this.mbContent).getHeight();
		var newHeight = ((wHeight - hHeight + byHeight) < cHeight) ? (cHeight + hHeight - wHeight) : byHeight;
		if(options) this.setOptions(options);
			this.mbWindow.setStyle({width: wWidth + byWidth + "px", height: wHeight + newHeight + "px"});
			setTimeout(function() {
        this.event("_afterResize");
				this.event("afterResize");
			}.bind(this), 1);
	},

  loadAfterResize: function() {
		$(this.mbWindow).setStyle({width: this.options.width + "px", height: this.options.height + "px"});
		$(this.mbWindow).setStyle({left: Math.round((Element.getWidth(document.body) - Element.getWidth(this.mbWindow)) / 2 ) + "px"});
		this.loadContent();
	},

  event: function(eventName) {
		if(this.options[eventName]) {
			var returnValue = this.options[eventName](); // Executing callback
			this.options[eventName] = null; // Removing callback after execution
			if(returnValue != undefined)
				return returnValue;
			else
				return true;
		}
		return true;
	},

  prepareIE: function(height, overflow){
		$$('html, body').invoke('setStyle', {width: height, height: height, overflow: overflow});
		$$("select").invoke('setStyle', {'visibility': overflow});
	},

  activate: function(options){
		this.setOptions(options);
		this.active = true;
		$(this.mbClose).observe("click", this.hideObserver);
		$(this.mbOverlay).observe("click", this.hideObserver);
		$(this.mbClose).show();
	},

	deactivate: function(options) {
		this.setOptions(options);
		this.active = false;
		$(this.mbClose).stopObserving("click", this.hideObserver);
		$(this.mbOverlay).stopObserving("click", this.hideObserver);
		$(this.mbClose).hide();
	},

  initObservers: function(){
		$(this.mbClose).observe("click", this.hideObserver);
		$(this.mbOverlay).observe("click", this.hideObserver);
		if(Prototype.Browser.IE)
			Event.observe(document, "keydown", this.kbdObserver);
		else
			Event.observe(document, "keypress", this.kbdObserver);
	},

	removeObservers: function(){
		$(this.mbClose).stopObserving("click", this.hideObserver);
		$(this.mbOverlay).stopObserving("click", this.hideObserver);
		if(Prototype.Browser.IE)
			Event.stopObserving(document, "keydown", this.kbdObserver);
		else
			Event.stopObserving(document, "keypress", this.kbdObserver);
	},

  submit: function(options){ //submit thru ajax request
    if(options){
      Object.extend(this.options.params, options);
    }

    if(window.XMLHttpRequest){
      //Mozilla, Netscape.
      ajaxRequest = new XMLHttpRequest();
    }
    else if(window.ActiveXObject){
      //Internet Explorer.
      ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
    }

    ajaxRequest.open(this.options.method.toLowerCase(), this.options.servletUrl, true);
    ajaxRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
    ajaxRequest.send(Object.toQueryString(this.options.params));
		ajaxRequest.onreadystatechange = function(){
      if(ajaxRequest.readyState == 4){
        if(ajaxRequest.status == 200){
          eval(ajaxRequest.responseText);
          AjaxModalBox.close();
				}
			}
		};
  }
};

Object.extend(AjaxModalBox, AjaxModalBox.Methods);
