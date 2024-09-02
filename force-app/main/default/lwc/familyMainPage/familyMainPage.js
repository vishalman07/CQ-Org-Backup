import { LightningElement, wire } from 'lwc';
import logo from '@salesforce/resourceUrl/CampQuality';
import logout from '@salesforce/label/c.CQ_Logout';
import profile from '@salesforce/label/c.CQ_Profile';
import home from '@salesforce/label/c.CQ_Home';
import contact from '@salesforce/label/c.CQ_Contact_Us';
import mobileHome from '@salesforce/label/c.CQ_mobile_nav_Home';
import mobileMyProfile from '@salesforce/label/c.CQ_mobile_nav_my_profile';
import mobileContactUs from '@salesforce/label/c.CQ_mobile_nav_contact_us';
import event from '@salesforce/label/c.CQ_Event';
import retreats from '@salesforce/label/c.CQ_nav_Retreats';
import resource from '@salesforce/label/c.CQ_Resources';
import faq from '@salesforce/label/c.CQ_nav_FAQ';
import myfamilyprofile from '@salesforce/label/c.CQ_My_Family_Profile';
import avtarUser from '@salesforce/apex/FamilyPortalLoginController.avtarUser';
import { CurrentPageReference } from "lightning/navigation";




export default class FamilyMainPage extends LightningElement {
  campQualityLogo = logo;

  label = {
    logout,
    profile,
    event,
    faq,
    retreats,
    resource,
    home,
    contact,
    mobileHome,
    mobileMyProfile,
    mobileContactUs,
    myfamilyprofile,

  }

  showCross = false;
  showDropDown = false;
  renderHomePg = true;
  renderProfilePg = false;
  renderContactPg = false
  eventPage = false;
  retreatsPage = false;
  resourcesPage = false;
  faqPage = false;
  homeClass = 'slds-context-bar__item slds-is-active';
  profileClass = 'slds-context-bar__item ';
  contactUsClass = 'slds-context-bar__item ';
  currentUserName;
  currentEmail;

  avtar;


  storeSessionUserId;
  setSesForEveDetail;
  sessionPage;
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      const urlValue = currentPageReference.state.c__userId;
      console.log('----urlValue----' + urlValue);
      if (urlValue) {
        console.log('urlValue2---' + urlValue);
        sessionStorage.setItem('OTP', urlValue);
        this.storeSessionUserId = urlValue;
        this.displayAvator();
        this.callParameter();
      } else if (sessionStorage.getItem('OTP') != undefined) {
        this.storeSessionUserId = sessionStorage.getItem('OTP');
        this.displayAvator();
        this.callParameter();

      }
      else {
        this.parameters = this.getQueryParameters();
        if (this.parameters.Id != undefined || this.parameters.Id != '') {
          this.setSesForEveDetail = sessionStorage.setItem('urlParameter', this.parameters.Id);
          this.sessionPage = sessionStorage.setItem('urlParameterPage', this.parameters.page);
        }

        var currentUrl = window.location.href;
        console.log('Line 258 main page --- + ' + currentUrl);
        sessionStorage.setItem('allUpdateYes', currentUrl);
        window.open("/family/login", '_self');


      }
    }
  }
  connectedCallback() {
    var lwr_forms = window.frames[0].window.document.querySelectorAll('.subscribe');
    lwr_forms.forEach(lwr_form_function);
    function lwr_form_function(item) {
      item.addEventListener('submit', function (event) {
        window.dataLayer.push({
          'event': 'formSubmit',
          'FormTarget': event.target["target"],
          'FormId': event.target.id,
          'FormClass': event.target.className,
          'FormUrl': event.target.src,
          'FormElement': event.target,
          'FormText': event.target.innerText
        });
      });
    }
    setTimeout(() => {
      this.loadHeadtagScript();

    }, 2000);
    // //   // loadScript(this, LoadHeadTag + '/LoadHeadTag.js')
    // Promise.all([
    //   loadScript(this, loadHeadTag + '/familyHeadJS.js')
    // ])
    //   .then(() => {
    //     // Stylesheet loaded successfully
    //     console.log('Head Tag Loaded');
    //   })
    //   .catch(error => {
    //     // Handle error if stylesheet fails to load
    //     console.error('Error loading Load stylesheet: ', error);
    //   });

    // // // }, 1000);

  }

  getQueryParameters() {
    var params = {};
    var search = location.search.substring(1);
    if (search) {
      params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
        return key === "" ? value : decodeURIComponent(value)
      });
    }
    return params;
  }

  currentUserConId;
  displayAvator() {
    avtarUser({ reocrdId: this.storeSessionUserId })
      .then(data => {
        //  this.currentUserName = data.Name;
        this.currentUserName = data.Contact.Name;
        this.currentEmail = data.Email;
        this.currentUserConId = data.ContactId;
        this.avtar = data.Contact.FirstName.substring(0, 1) + data.Contact.LastName.substring(0, 1);



      })
      .catch(error => {
        console.log('SEE here in console --->' + JSON.stringify(error));
      })
  }





  logoutLink() {
    sessionStorage.clear();
    window.open("/family/login", '_self');
  }

  clickOnLogo() {
    window.open('/family?page=home', '_self');
  }

  handleDropDown() {
    this.showDropDown = !this.showDropDown;
    this.showCross = !this.showCross;
  }
  // Method to navigate to the home page
  homerender() {
    // Set class for styling
    this.contactUsClass = 'slds-context-bar__item';
    this.profileClass = 'slds-context-bar__item ';
    this.homeClass = 'slds-context-bar__item slds-is-active';
    //Redirect to Home Page
    this.renderHomePg = true;
    this.renderProfilePg = false;
    this.renderContactPg = false;
    this.eventPage = false;
    this.resourcesPage = false;
    this.faqPage = false;
    this.retreatsPage = false;
  }

  //Render/Redirect to profile page
  profilerender() {
    this.profileClass = 'slds-context-bar__item slds-is-active';
    this.contactUsClass = 'slds-context-bar__item';
    this.homeClass = 'slds-context-bar__item';
    this.renderProfilePg = true;
    this.renderHomePg = false;
    this.renderContactPg = false;
    this.eventPage = false;
    this.resourcesPage = false;
    this.faqPage = false;
    this.retreatsPage = false;
    window.open('/family?page=profile', '_self');
  }

  eventrender() {
    this.renderProfilePg = false;
    this.renderHomePg = false;
    this.renderContactPg = false;
    this.eventPage = true;
    this.resourcesPage = false;
    this.faqPage = false;
    this.retreatsPage = false;
    window.open('/family?page=event', '_self');
  }

  //Render/Redirect to news and update page
  retreatsrender() {
    this.renderProfilePg = false;
    this.renderHomePg = false;
    this.renderContactPg = false;
    this.eventPage = false;
    this.retreatsPage = true;
    this.faqPage = false;
    this.resourcesPage = false;
    window.open('/family?page=retreat', '_self');
  }

  //Render/Redirect to resource page
  resourcesrender() {
    this.renderProfilePg = false;
    this.renderHomePg = false;
    this.renderContactPg = false;
    this.eventPage = false;
    this.resourcesPage = true;
    this.faqPage = false;
    this.retreatsPage = false;
    window.open('/family/?page=resource', '_self');
  }

  faqrender() {
    this.renderProfilePg = false;
    this.renderHomePg = false;
    this.renderContactPg = false;
    this.eventPage = false;
    this.resourcesPage = false;
    this.faqPage = true;
    this.retreatsPage = false;
    window.open('/family/?page=faq', '_self');
  }

  //Render/Redirect to contact page
  contactRender() {
    this.contactUsClass = 'slds-context-bar__item slds-is-active';
    this.profileClass = 'slds-context-bar__item ';
    this.homeClass = 'slds-context-bar__item';
    this.renderContactPg = true;
    this.renderHomePg = false;
    this.renderProfilePg = false;
    this.incidentPage = false;
    this.eventPage = false;
    this.newsPage = false;
    this.faqPage = false;
    this.resourcesPage = false;
    window.open('/family/?page=contactus', '_self');
  }

  dropdownUserClass = 'dropdown-content_User'; // Initial state is hidden
  toggleDropdownuser() {
    this.dropdownUserClass = this.dropdownUserClass === 'dropdown-content_User' ? 'dropdown-content_User show ' : 'dropdown-content_User';
  }


  parameters = {};

  callParameter() {
    this.parameters = this.getQueryParameters();
    if (this.parameters.p != undefined && this.parameters.s != undefined) {
      this.newsrender();
    }
    else if (this.parameters.page != undefined && this.parameters.page == 'profile') {
      this.renderProfilePg = true;
      this.renderHomePg = false;
      this.renderContactPg = false;
      this.eventPage = false;
      this.resourcesPage = false;
      this.faqPage = false;
      this.retreatsPage = false;
    }
    else if (this.parameters.page != undefined && this.parameters.page == 'contactus') {
      this.renderContactPg = true;
      this.renderHomePg = false;
      this.renderProfilePg = false;
      this.eventPage = false;
      this.resourcesPage = false;
      this.faqPage = false;
      this.retreatsPage = false;
    }
    else if (this.parameters.page != undefined && this.parameters.page == 'resource' && this.parameters.p == undefined) {
      this.renderProfilePg = false;
      this.renderHomePg = false;
      this.renderContactPg = false;
      this.eventPage = false;
      this.resourcesPage = true;
      this.faqPage = false;
      this.retreatsPage = false;
    }
    else if (this.parameters.page != undefined && this.parameters.page == 'retreat') {
      this.renderProfilePg = false;
      this.renderHomePg = false;
      this.renderContactPg = false;
      this.eventPage = false;
      this.retreatsPage = true;
      this.faqPage = false;
      this.resourcesPage = false;
    }
    else if (this.parameters.page != undefined && this.parameters.page == 'faq') {
      this.renderProfilePg = false;
      this.renderHomePg = false;
      this.renderContactPg = false;
      this.eventPage = false;
      this.retreatsPage = false;
      this.faqPage = true;
      this.resourcesPage = false;
    }
    else if (this.parameters.page != undefined && this.parameters.page == 'event') {
      this.renderProfilePg = false;
      this.renderHomePg = false;
      this.renderContactPg = false;
      this.eventPage = true;
      this.resourcesPage = false;
      this.faqPage = false;
      this.retreatsPage = false;
    }
    else if (this.parameters.page != undefined && this.parameters.page == 'home') {
      this.renderHomePg = true;
      this.renderProfilePg = false;
      this.renderContactPg = false;
      this.eventPage = false;
      this.resourcesPage = false;
      this.faqPage = false;
      this.retreatsPage = false;
    }
  }
  loadHeadtagScript() {
    window['_fs_host'] = 'fullstory.com';
    window['_fs_script'] = 'edge.fullstory.com/s/fs.js';
    window['_fs_org'] = 'o-1ZA501-na1';
    window['_fs_namespace'] = 'FS';

    !function (m, n, e, t, l, o, g, y) {
      var s, f, a = function (h) {
        return !(h in m) || (m.console && m.console.log && m.console.log('FullStory namespace conflict. Please set window["_fs_namespace"].'), !1)
      }(e);

      function p(b) {
        var h, d = [];

        function j() {
          h && (d.forEach((function (b) {
            var d;
            try {
              d = b[h[0]] && b[h[0]](h[1])
            } catch (h) {
              return void (b[3] && b[3](h))
            }
            d && d.then ? d.then(b[2], b[3]) : b[2] && b[2](d)
          })), d.length = 0)
        }

        function r(b) {
          return function (d) {
            h || (h = [b, d], j())
          }
        }
        return b(r(0), r(1)), {
          then: function (b, h) {
            return p((function (r, i) {
              d.push([b, h, r, i]), j()
            }))
          }
        }
      }
      a && (g = m[e] = function () {
        var b = function (b, d, j, r) {
          function i(i, c) {
            h(b, d, j, i, c, r)
          }
          r = r || 2;
          var c, u = /Async$/;
          return u.test(b) ? (b = b.replace(u, ""), "function" == typeof Promise ? new Promise(i) : p(i)) : h(b, d, j, c, c, r)
        };

        function h(h, d, j, r, i, c) {
          return b._api ? b._api(h, d, j, r, i, c) : (b.q && b.q.push([h, d, j, r, i, c]), null)
        }
        return b.q = [], b
      }(), y = function (b) {
        function h(h) {
          "function" == typeof h[4] && h[4](new Error(b))
        }
        var d = g.q;
        if (d) {
          for (var j = 0; j < d.length; j++) h(d[j]);
          d.length = 0, d.push = h
        }
      }, function () {
        (o = n.createElement(t)).async = !0;
        o.crossOrigin = "anonymous";
        o.src = "https://" + l;
        o.onerror = function () {
          y("Error loading " + l);
          console.error("FullStory script failed to load.");
        };
        var b = n.getElementsByTagName(t)[0];
        b && b.parentNode ? b.parentNode.insertBefore(o, b) : n.head.appendChild(o)
      }(), function () {
        function b() { }

        function h(b, h, d) {
          g(b, h, d, 1)
        }

        function d(b, d, j) {
          h("setProperties", {
            type: b,
            properties: d
          }, j)
        }

        function j(b, h) {
          d("user", b, h)
        }

        function r(b, h, d) {
          j({
            uid: b
          }, d), h && j(h, d)
        }
        g.identify = r;
        g.setUserVars = j;
        g.identifyAccount = b;
        g.clearUserCookie = b;
        g.setVars = d;
        g.event = function (b, d, j) {
          h("trackEvent", {
            name: b,
            properties: d
          }, j)
        };
        g.anonymize = function () {
          r(!1)
        };
        g.shutdown = function () {
          h("shutdown")
        };
        g.restart = function () {
          h("restart")
        };
        g.log = function (b, d) {
          h("log", {
            level: b,
            msg: d
          })
        };
        g.consent = function (b) {
          h("setIdentity", {
            consent: !arguments.length || b
          })
        }
      }(), s = "fetch", f = "XMLHttpRequest", g._w = {}, g._w[f] = m[f], g._w[s] = m[s], m[s] && (m[s] = function () {
        return g._w[s].apply(this, arguments)
      }), g._v = "2.0.0")
    }(window, document, window._fs_namespace, "script", window._fs_script);

    console.log('userId=>' + this.currentUserConId);

    FS('setIdentity', {
      uid: this.currentUserConId,
      properties: {
        displayName: this.currentUserName,
        user_type: 'family'
      }
    }, function (successResponse) {
      console.log('FullStory identity set successfully:', successResponse);
    }, function (errorResponse) {
      console.error('Error setting FullStory identity:', errorResponse);
    });
  }
}