import { LightningElement, wire, track } from 'lwc';
import logo from '@salesforce/resourceUrl/CampQuality';
import logout from '@salesforce/label/c.CQ_Logout';
import profile from '@salesforce/label/c.CQ_Profile';
import home from '@salesforce/label/c.CQ_Home';
import contact from '@salesforce/label/c.CQ_Contact_Us';
import mobileHome from '@salesforce/label/c.CQ_mobile_nav_Home';
import mobileMyProfile from '@salesforce/label/c.CQ_mobile_nav_my_profile';
import mobileContactUs from '@salesforce/label/c.CQ_mobile_nav_contact_us';
import incidents from '@salesforce/label/c.CQ_nav_Incident';
import event from '@salesforce/label/c.CQ_Volunteer_Nav_Heading';
import newsUpdate from '@salesforce/label/c.CQ_News_Update';
import resource from '@salesforce/label/c.CQ_Resource_Nav_Head';
import checkIncidentAccess from '@salesforce/apex/CommunityLoginController.checkIncidentAccess';
import avtarUser from '@salesforce/apex/CommunityLoginController.avtarUser';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { CurrentPageReference } from "lightning/navigation";
import loadHeadTag from '@salesforce/resourceUrl/LoadHeadTag';
import { loadStyle , loadScript } from 'lightning/platformResourceLoader';

export default class VolunteerMainPage extends LightningElement {

  // Importing the Camp Quality logo
  campQualityLogo = logo;
  // Labels used in the component
  label = {
    logout,
    profile,
    event,
    newsUpdate,
    resource,
    home,
    contact,
    mobileHome,
    mobileMyProfile,
    mobileContactUs,
    incidents
  }

  showCross = false;
  showDropDown = false;
  renderHomePg = true;
  renderProfilePg = false;
  renderContactPg = false
  eventPage = false;
  newsPage = false;
  resourcesPage = false;
  homeClass = 'slds-context-bar__item slds-is-active';
  profileClass = 'slds-context-bar__item ';
  contactUsClass = 'slds-context-bar__item ';
  currentUserName;
  currentEmail;
  incidentPage = false;
  showIncident = true;
  avtar;
  @track userId;
  parameters = {};
  storeSessionUserId;
  setSesForEveDetail;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {

 
    if (currentPageReference) {
      const urlValue = currentPageReference.state.c__userId;
      if (urlValue) {
        sessionStorage.setItem('userId', urlValue);
        this.storeSessionUserId = urlValue;
        this.displayAvator();
        this.callNewsParameter();
      } else if (sessionStorage.getItem('userId') != undefined) {   
        this.storeSessionUserId = sessionStorage.getItem(('userId'))    
        this.displayAvator();
        this.callNewsParameter();
      }
      else {
        this.parameters = this.getQueryParameters();
        if (this.parameters.Id != undefined || this.parameters.Id != '') {
          this.setSesForEveDetail = sessionStorage.setItem('urlParameter', this.parameters.Id);
          this.sessionPage = sessionStorage.setItem('urlParameterPage', this.parameters.page);
        }
        window.open("/volunteer/login", '_self');
      }
    }
  }

  connectedCallback(){
    this.loadMrOrangeStyles();
              Promise.all([
            loadScript(this, loadHeadTag + '/volunteerHeadJs.js')
          ])
            .then(() => {
                // Stylesheet loaded successfully
                console.log('Head Tag Loaded');
            })
            .catch(error => {
                // Handle error if stylesheet fails to load
                console.error('Error loading Load stylesheet: ', error);
            });

  }

  loadMrOrangeStyles() {
    if (location.origin.includes('partial')) {
        loadStyle(this, partialFont + '/campqualityCss/partialFont.css')
            .then(() => {
                // Stylesheet loaded successfully
                console.log('font lodded');
            })
            .catch(error => {
                // Handle error if stylesheet fails to load
                console.error('Error loading MrOrange stylesheet: ', error);
            });
    }
    else {
        loadStyle(this, partialFont + '/campqualityCss/productionFont.css')
            .then(() => {
                // Stylesheet loaded successfully
                console.log('font lodded');
            })
            .catch(error => {
                // Handle error if stylesheet fails to load
                console.error('Error loading MrOrange stylesheet: ', error);
            });
    }
}

  
  displayAvator() {
    avtarUser({ reocrdId: this.storeSessionUserId })
      .then(data => {
        this.currentUserName = data.Contact.Name;
        this.currentEmail = data.Email;
        this.avtar = data.Contact.FirstName.substring(0, 1) + data.Contact.LastName.substring(0, 1);;
      })
      .catch(error => {
        console.log('SEE here in console --->' + JSON.stringify(error));
      })
  }

  logoutLink() {
    sessionStorage.clear();
    window.open("/volunteer/login", '_self');
  }

  // Method to handle the dropdown menu visibility
  handleDropDown() {
    this.showDropDown = !this.showDropDown;
    this.showCross = !this.showCross;
  }

  // Method to handle focus out of the dropdown
  handleDropdownFocusout() {
    console.log('focusOut')
  }

  clickLogo() {
    window.open('/volunteer?page=home', '_self');
  }

  // Method to navigate to the home page
  homerender() {

    //Redirect to Home Page
    this.renderHomePg = true;
    this.renderProfilePg = false;
    this.renderContactPg = false;
    this.incidentPage = false;
    this.eventPage = false;
    this.newsPage = false;
    this.resourcesPage = false;
    window.open('/volunteer?page=home', '_self');

  }

  //Render/Redirect to profile page
  profilerender() {
    this.profileClass = 'slds-context-bar__item slds-is-active';
    this.contactUsClass = 'slds-context-bar__item';
    this.homeClass = 'slds-context-bar__item';
    this.renderProfilePg = true;
    this.renderHomePg = false;
    this.renderContactPg = false;
    this.incidentPage = false;
    this.eventPage = false;
    this.newsPage = false;
    this.resourcesPage = false;
    window.open('/volunteer/?page=profile', '_self');

  }

  // //Render/Redirect to incident page
  incidentrender() {
    this.profileClass = 'slds-context-bar__item slds-is-active';
    this.contactUsClass = 'slds-context-bar__item';
    this.homeClass = 'slds-context-bar__item';
    this.renderHomePg = false;
    this.renderProfilePg = false;
    this.renderContactPg = false;
    this.incidentPage = true;
    this.eventPage = false;
    this.newsPage = false;
    this.resourcesPage = false;
    window.open('/volunteer/?page=incident', '_self');

  }

  //Render/Redirect to event page
  eventrender() {
    this.renderProfilePg = false;
    this.renderHomePg = false;
    this.renderContactPg = false;
    this.incidentPage = false;
    this.eventPage = true;
    this.newsPage = false;
    this.resourcesPage = false;
    window.open('/volunteer/?page=event', '_self');
  }

  // //Render/Redirect to news and update page
  newsrender() {
    this.renderProfilePg = false;
    this.renderHomePg = false;
    this.renderContactPg = false;
    this.incidentPage = false;
    this.eventPage = false;
    this.newsPage = true;
    this.resourcesPage = false;
    window.open('/volunteer/?page=news', '_self');
  }

  // //Render/Redirect to resource page
  resourcesrender() {
    this.renderProfilePg = false;
    this.renderHomePg = false;
    this.renderContactPg = false;
    this.incidentPage = false;
    this.eventPage = false;
    this.newsPage = false;
    this.resourcesPage = true;
    window.open('/volunteer/?page=resource', '_self');
  }

  // //Render/Redirect to contact page
  contactRender() {
    this.renderContactPg = true;
    this.renderHomePg = false;
    this.renderProfilePg = false;
    this.incidentPage = false;
    this.eventPage = false;
    this.newsPage = false;
    this.resourcesPage = false;
    window.open('/volunteer/?page=contactus', '_self');
  }
  // // Method to toggle the user dropdown
  dropdownUserClass = 'dropdown-content_User'; // Initial state is hidden
  toggleDropdownuser() {
    this.dropdownUserClass = this.dropdownUserClass === 'dropdown-content_User' ? 'dropdown-content_User show ' : 'dropdown-content_User';
  }

  // Wired method to check incident access
  @wire(checkIncidentAccess)
  incidentAccess({ error, data }) {
    if (data == 'No access') {
      // this.callNewsParameter();
      this.showIncident = false;
    }
    else if (error) {
      // this.callNewsParameter();
      this.error = error;
    }
  }


  callNewsParameter() {
    this.parameters = this.getQueryParameters();
    if (this.parameters.p != undefined && this.parameters.s != undefined) {
      this.newsrender();
      setTimeout(() => {
        let news = this.template.querySelector('c-community-news-page');
        news.openPage(this.parameters.s, this.parameters.p);
      }, 100);
    }
    else if (this.parameters.page != undefined && this.parameters.page == 'profile') {
      // this.profilerender();
      this.renderProfilePg = true;
      this.renderHomePg = false;
      this.renderContactPg = false;
      this.incidentPage = false;
      this.eventPage = false;
      this.newsPage = false;
      this.resourcesPage = false;

    }
    else if (this.parameters.page != undefined && this.parameters.page == 'contactus') {
      // this.contactRender();
      this.renderContactPg = true;
      this.renderHomePg = false;
      this.renderProfilePg = false;
      this.incidentPage = false;
      this.eventPage = false;
      this.newsPage = false;
      this.resourcesPage = false;

    }
    else if (this.parameters.page != undefined && this.parameters.page == 'incident') {
      // this.incidentrender();
      this.renderProfilePg = false;
      this.renderHomePg = false;
      this.renderContactPg = false;
      this.incidentPage = true;
      this.eventPage = false;
      this.newsPage = false;
      this.resourcesPage = false;
      // window.open('/volunteer/volunteerhomepage?page=incident' , '_self');
    }
    else if (this.parameters.page != undefined && this.parameters.page == 'resource' && this.parameters.p == undefined) {
      this.renderProfilePg = false;
      this.renderHomePg = false;
      this.renderContactPg = false;
      this.incidentPage = false;
      this.eventPage = false;
      this.newsPage = false;
      this.resourcesPage = true;
      // window.open('/volunteer/volunteerhomepage?page=resource' , '_self');
    }
    else if (this.parameters.page != undefined && this.parameters.page == 'news') {
      this.renderProfilePg = false;
      this.renderHomePg = false;
      this.renderContactPg = false;
      this.incidentPage = false;
      this.eventPage = false;
      this.newsPage = true;
      this.resourcesPage = false;
      // window.open('/volunteer/volunteerhomepage?page=news' , '_self');
    }
    else if (this.parameters.page != undefined && this.parameters.page == 'event') {
      this.renderProfilePg = false;
      this.renderHomePg = false;
      this.renderContactPg = false;
      this.incidentPage = false;
      this.eventPage = true;
      this.newsPage = false;
      this.resourcesPage = false;
      // window.open('/volunteer/volunteerhomepage?page=event' , '_self');

    }
    else if (this.parameters.page != undefined && this.parameters.page == 'home') {


      // setTimeout(() => {
      // this.template.querySelector('c-community-home-page').homePageHandle();
      // }, 200);
    }
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
                user_type: 'volunter'
            }
        }, function(successResponse) {
            console.log('FullStory identity set successfully:', successResponse);
        }, function(errorResponse) {
            console.error('Error setting FullStory identity:', errorResponse);
        });
  }
}